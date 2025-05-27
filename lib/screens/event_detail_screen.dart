import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:areteum_app/widgets/footer.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'package:areteum_app/widgets/custom_search_delegate.dart'
    as search_delegate_widget;

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? eventData;
  Map<String, dynamic>? _eventDataMap;
  bool isUserRegistered = false;
  bool isLoading = true;
  int _selectedIndex = 0;

  static const Color backgroundColor = Color(0xFFEAE7D6);
  static const Color primaryButtonColor = Color(0xFFA4C3A2);
  static const Color textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
    // Inicializar formateador de fecha para español
    try {
      Intl.defaultLocale = 'es_ES';
    } catch (e) {
      debugPrint("Error al establecer el locale por defecto para Intl: $e");
    }
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      final eventSnapshot =
          await _firestore.collection('events').doc(widget.eventId).get();
      if (mounted) {
        if (eventSnapshot.exists) {
          setState(() {
            eventData = eventSnapshot;
            _eventDataMap = eventData!.data() as Map<String, dynamic>?;
            final participants = _eventDataMap?['participants'];
            if (participants is List) {
              isUserRegistered = participants.contains(
                FirebaseAuth.instance.currentUser?.uid,
              );
            } else {
              isUserRegistered = false;
            }
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            eventData = null;
            _eventDataMap = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Evento no encontrado.')),
            );
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          eventData = null;
          _eventDataMap = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el evento: ${e.toString()}')),
        );
        debugPrint("Error en _loadEventDetails: $e");
      }
    }
  }

  void _reservePlace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_eventDataMap == null || user == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (_eventDataMap!['availableSlots'] <= 0) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Aforo completo. Inténtelo en otro momento'),
        ),
      );
      return;
    }

    if (!isUserRegistered) {
      try {
        await _firestore.collection('events').doc(widget.eventId).update({
          'participants': FieldValue.arrayUnion([user.uid]),
          'availableSlots': FieldValue.increment(-1),
        });
        if (mounted) {
          setState(() {
            isUserRegistered = true;
            _eventDataMap!['availableSlots'] =
                _eventDataMap!['availableSlots'] - 1;
            if (_eventDataMap!['participants'] is List) {
              (_eventDataMap!['participants'] as List).add(user.uid);
            } else {
              _eventDataMap!['participants'] = [user.uid];
            }
          });
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Reserva realizada con éxito')),
          );
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error al reservar: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _cancelReservation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_eventDataMap == null || user == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (isUserRegistered) {
      try {
        await _firestore.collection('events').doc(widget.eventId).update({
          'participants': FieldValue.arrayRemove([user.uid]),
          'availableSlots': FieldValue.increment(1),
        });
        if (mounted) {
          setState(() {
            isUserRegistered = false;
            _eventDataMap!['availableSlots'] =
                _eventDataMap!['availableSlots'] + 1;
            if (_eventDataMap!['participants'] is List) {
              (_eventDataMap!['participants'] as List).remove(user.uid);
            }
          });
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Reserva cancelada')),
          );
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error al cancelar: ${e.toString()}')),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    try {
      final DateFormat formatter = DateFormat('dd MMMM yyyy, hh:mm a', 'es_ES');
      return formatter.format(date);
    } catch (e) {
      debugPrint(
        "Error formateando fecha (locale 'es_ES' podría no estar inicializado): $e",
      );
      final DateFormat fallbackFormatter = DateFormat('dd/MM/yyyy, hh:mm a');
      return fallbackFormatter.format(date);
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index && index != 1) {
      if (index == 0 && ModalRoute.of(context)?.settings.name != '/') {
      } else {
        return;
      }
    }
    _navigateToScreen(index);
  }

  void _navigateToScreen(int index) {
    final navigator = Navigator.of(context);

    if (index != 1) {
      setState(() {
        _selectedIndex = index;
      });
    }

    switch (index) {
      case 0: // Inicio
        // Asegura que siempre se vaya a HomeScreen y se limpie la pila
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
            settings: const RouteSettings(name: '/'),
          ),
          (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
        );
        break;
      case 1: // Buscar
        showSearch(
          context: context,
          delegate: search_delegate_widget.CustomSearchDelegate(
            initialQuery: '',
          ),
        ).then((_) {});
        break;
      case 2: // Perfil
        if (ModalRoute.of(context)?.settings.name != '/profile') {
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
              settings: const RouteSettings(name: '/profile'),
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryButtonColor),
        ),
      );
    }

    if (_eventDataMap == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: textColor),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'No se pudieron cargar los detalles del evento.',
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }

    final data = _eventDataMap!;
    final String title = data['title'] ?? 'Sin título';
    final Timestamp? timestamp = data['date'] as Timestamp?;
    final String formattedDate =
        timestamp != null
            ? _formatDate(timestamp.toDate())
            : 'Fecha no disponible';
    final String taughtBy = data['taughtBy'] ?? 'No especificado';
    final String location = data['location'] ?? 'No especificada';
    final String description = data['description'] ?? 'Sin descripción.';
    final int maxCapacity = data['maxCapacity'] ?? 0;
    final int availableSlots = data['availableSlots'] ?? 0;

    final ButtonStyle mainButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: primaryButtonColor,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    final ButtonStyle secondaryButtonStyle = TextButton.styleFrom(
      foregroundColor: primaryButtonColor,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: null,
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Fecha y hora:',
              formattedDate,
            ),
            _buildDetailRow(Icons.person_outline, 'Impartido por:', taughtBy),
            _buildDetailRow(Icons.location_on_outlined, 'Ubicación:', location),
            const SizedBox(height: 20),
            const Text(
              'Descripción del evento:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: textColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              Icons.people_alt_outlined,
              'Aforo máximo:',
              maxCapacity.toString(),
            ),
            _buildDetailRow(
              Icons.event_seat_outlined,
              'Plazas disponibles:',
              availableSlots.toString(),
            ),
            _buildDetailRow(
              isUserRegistered
                  ? Icons.check_circle_outline
                  : Icons.highlight_off_outlined,
              'Inscrito:',
              isUserRegistered ? 'Sí' : 'No',
              highlight: isUserRegistered,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      (isUserRegistered || availableSlots <= 0)
                          ? null
                          : _reservePlace,
                  style: mainButtonStyle,
                  child: const Text('Reservar plaza'),
                ),
                TextButton(
                  onPressed: isUserRegistered ? _cancelReservation : null,
                  style: secondaryButtonStyle,
                  child: const Text('Cancelar reserva'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Footer(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: backgroundColor,
        selectedItemColor: Theme.of(context).primaryColorDark,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textColor.withAlpha((0.8 * 255).round())),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor.withAlpha((0.9 * 255).round()),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: highlight ? primaryButtonColor : textColor,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
