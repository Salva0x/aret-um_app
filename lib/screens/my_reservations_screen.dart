import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'event_detail_screen.dart';
import 'package:areteum_app/widgets/footer.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'package:areteum_app/widgets/custom_search_delegate.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;
  int _selectedIndex = -1;

  static const Color reservationCardColor = Color(0xFF5D7B6F);

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _fetchReservations();
    } else {
      // Manejar el caso en que el usuario no esté autenticado
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado.')),
        );
      }
    }
  }

  void _fetchReservations() async {
    if (_user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final snapshot =
          await _firestore
              .collection('events')
              .where('participants', arrayContains: _user!.uid)
              .orderBy(
                'date',
                descending: true,
              ) // Ordenar por fecha, más recientes primero
              .get();

      if (mounted) {
        setState(() {
          reservations =
              snapshot.docs.map((doc) {
                var data = doc.data();
                var date = (data['date'] as Timestamp).toDate();
                String time = data['time'] ?? 'No especificado';

                return {
                  'id': doc.id,
                  'title': data['title'] ?? 'Sin título',
                  'date': date,
                  'time': time,
                  'location': data['location'] ?? 'No especificada',
                };
              }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar las reservas: ${e.toString()}'),
          ),
        );
        debugPrint("Error fetching reservations: $e");
      }
    }
  }

  void _cancelReservation(String eventId) async {
    if (_user == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(eventRef);
        if (!snapshot.exists) {
          throw Exception("El evento no existe!");
        }
        transaction.update(eventRef, {
          'participants': FieldValue.arrayRemove([_user!.uid]),
          'availableSlots': FieldValue.increment(1),
        });
      });

      if (mounted) {
        _fetchReservations();
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Reserva cancelada con éxito.')),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error al cancelar la reserva: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _navigateToScreen(index);
      return;
    }
    _navigateToScreen(index);
  }

  void _navigateToScreen(int index) {
    final navigator = Navigator.of(context);

    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    switch (index) {
      case 0: // Inicio
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
        break;
      case 1: // Buscar
        showSearch(
          context: context,
          delegate: CustomSearchDelegate(initialQuery: ''),
        ).then((_) {});
        break;
      case 2: // Perfil
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      default:
        break;
    }
  }

  String _formatDateTime(DateTime date, String time) {
    // Formato de fecha: dd/MM/yyyy
    String formattedDate = DateFormat('dd/MM/yyyy', 'es_ES').format(date);
    return '$formattedDate • $time';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Reservas"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : reservations.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Aún no tienes ninguna reserva.\n¡Explora nuestros eventos y apúntate!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.textTheme.bodyMedium?.color?.withAlpha(
                              (0.7 * 255).round(),
                            ),
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reserva = reservations[index];
                        String displayDateTime = _formatDateTime(
                          reserva['date'],
                          reserva['time'],
                        );

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          color: reservationCardColor,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 16.0,
                            ),
                            title: Text(
                              reserva['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '📅 $displayDateTime',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '📍 ${reserva['location']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white70,
                              ),
                              onSelected: (value) {
                                if (value == 'ver') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => EventDetailScreen(
                                            eventId: reserva['id'],
                                          ),
                                    ),
                                  ).then(
                                    (_) => _fetchReservations(),
                                  ); // Recargar al volver
                                } else if (value == 'cancelar') {
                                  _cancelReservation(reserva['id']);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'ver',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.visibility_outlined,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Ver detalles'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'cancelar',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.cancel_outlined,
                                            size: 20,
                                            color: Colors.redAccent,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Cancelar reserva'),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          const Footer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex < 0 ? 0 : _selectedIndex,
        onTap: _onItemTapped,
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
}
