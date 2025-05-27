import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:areteum_app/widgets/footer.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'package:areteum_app/widgets/custom_search_delegate.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isAdmin = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<DateTime, List<dynamic>> _events = {};
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _loadEventsForMonth();
    _selectedDay = _focusedDay;
  }

  void _checkIfAdmin() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (mounted && userData.exists) {
          final role = userData.get('role');
          if (role == 'admin') {
            setState(() {
              isAdmin = true;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          debugPrint("Error al verificar rol de admin: $e");
        }
      }
    }
  }

  void _loadEventsForMonth() async {
    final firstDayOfMonth = DateTime.utc(
      _focusedDay.year,
      _focusedDay.month,
      1,
    );
    final lastDayOfMonth = DateTime.utc(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
      23,
      59,
      59,
    );

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('events')
              .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
              .where('date', isLessThanOrEqualTo: lastDayOfMonth)
              .get();

      if (!mounted) return;

      final Map<DateTime, List<dynamic>> newEvents = {};
      for (var doc in snapshot.docs) {
        var date = (doc['date'] as Timestamp).toDate();
        final normalizedDate = DateTime.utc(date.year, date.month, date.day);
        if (!newEvents.containsKey(normalizedDate)) {
          newEvents[normalizedDate] = [];
        }
        newEvents[normalizedDate]!.add(doc);
      }
      setState(() {
        _events = newEvents;
      });
    } catch (e) {
      if (mounted) {
        debugPrint("Error al cargar eventos: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar eventos: ${e.toString()}')),
        );
      }
    }
  }

  void _createEvent(DateTime selectedDate) {
    if (!isAdmin) return;

    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController taughtByController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController maxCapacityController = TextEditingController(
      text: '25',
    );

    final ThemeData theme = Theme.of(context);
    final Color dialogButtonColor = theme.colorScheme.primary;
    final Color dialogBackgroundColor = theme.scaffoldBackgroundColor;
    final Color dialogTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;

    final ButtonStyle dialogButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: dialogButtonColor,
      foregroundColor: theme.colorScheme.onPrimary,
    );
    final ButtonStyle dialogCancelButtonStyle = TextButton.styleFrom(
      foregroundColor: dialogTextColor.withAlpha((0.7 * 255).round()),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            'Crear Evento/Curso',
            style: TextStyle(color: dialogTextColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Evento/Curso',
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Detalle del Evento/Curso',
                  ),
                ),
                TextField(
                  controller: taughtByController,
                  decoration: const InputDecoration(labelText: 'Impartido por'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación/Sala',
                  ),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Hora del Evento (ej: 10:00 AM)',
                  ),
                ),
                TextField(
                  controller: maxCapacityController,
                  decoration: const InputDecoration(
                    labelText: 'Capacidad Máxima',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: dialogCancelButtonStyle,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: dialogButtonStyle,
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    timeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El título y la hora son obligatorios.'),
                    ),
                  );
                  return;
                }
                int maxCapacity =
                    int.tryParse(maxCapacityController.text) ?? 25;

                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                try {
                  await FirebaseFirestore.instance.collection('events').add({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'date': Timestamp.fromDate(selectedDate),
                    'createdBy': _auth.currentUser?.uid,
                    'taughtBy': taughtByController.text,
                    'location': locationController.text,
                    'time': timeController.text,
                    'participants': [],
                    'availableSlots': maxCapacity,
                    'maxCapacity': maxCapacity,
                  });

                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Evento creado')),
                  );
                  navigator.pop();
                  _loadEventsForMonth();
                } catch (e) {
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error al crear evento: ${e.toString()}'),
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
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
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDate = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents =
        _selectedDay != null
            ? _getEventsForDay(_selectedDay!)
            : _getEventsForDay(_focusedDay);

    final ThemeData theme = Theme.of(context);
    final Color primaryAppColor = theme.colorScheme.primary;
    final Color eventCardColor = const Color(
      0xFF5D7B6F,
    ); // Color específico para tarjetas de evento
    final Color currentBackgroundColor = theme.scaffoldBackgroundColor;
    final Color currentTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return Scaffold(
      backgroundColor: currentBackgroundColor,
      appBar: AppBar(
        title: const Text('Calendario'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            }
          },
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Crear Evento',
              onPressed: () {
                _createEvent(_selectedDay ?? _focusedDay);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2040, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _loadEventsForMonth();
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: primaryAppColor.withAlpha((0.5 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: primaryAppColor,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: eventCardColor.withAlpha(
                      (0.7 * 255).round(),
                    ), // 70% opacidad
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(
                    color:
                        Colors
                            .redAccent, // Color específico para fines de semana
                    fontSize: 11,
                  ),
                  defaultTextStyle: TextStyle(
                    fontSize: 11,
                    color: currentTextColor,
                  ),
                  outsideDaysVisible: false,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    color: currentTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    size: 20,
                    color: currentTextColor,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: currentTextColor,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: currentTextColor.withAlpha((0.7 * 255).round()),
                  ),
                  weekendStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.redAccent,
                  ),
                ),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
                eventLoader: _getEventsForDay,
                rowHeight: 40,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cursos y Eventos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: currentTextColor,
                    ),
                  ),
                  if (_selectedDay != null)
                    Text(
                      '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: currentTextColor.withAlpha((0.7 * 255).round()),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child:
                  selectedEvents.isEmpty
                      ? Center(
                        child: Text(
                          'No hay eventos para este día.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          var eventDoc = selectedEvents[index];
                          var eventData =
                              eventDoc.data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 5.0,
                            ),
                            elevation: 2,
                            color: eventCardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                eventData['title'] ?? 'Sin título',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eventData['description'] ??
                                        'Sin descripción',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Hora: ${eventData['time'] ?? 'N/A'} • Lugar: ${eventData['location'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => EventDetailScreen(
                                          eventId: eventDoc.id,
                                        ),
                                  ),
                                ).then((_) => _loadEventsForMonth());
                              },
                            ),
                          );
                        },
                      ),
            ),
            const Footer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            _selectedIndex < 0
                ? 0
                : _selectedIndex, // Muestra "Inicio" si no hay selección
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
