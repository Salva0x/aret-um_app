import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'calendar_screen.dart';

class ManagementEventsTabState extends StatefulWidget {
  const ManagementEventsTabState({super.key});

  @override
  State<ManagementEventsTabState> createState() => _ManagementEventsTabState();
}

class _ManagementEventsTabState extends State<ManagementEventsTabState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _eventsCollection;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  static const Color eventCardColor = Color(0xFF5D7B6F);

  @override
  void initState() {
    super.initState();
    _eventsCollection = _firestore.collection('events');
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchTerm = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimestamp(Timestamp timestamp) {
    try {
      return DateFormat('dd/MM/yyyy', 'es_ES').format(timestamp.toDate());
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  void _addEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarScreen()),
    );
  }

  void _editEvent(String eventId, QueryDocumentSnapshot event) {
    final ThemeData theme = Theme.of(context);
    final Color dialogBackgroundColor = theme.scaffoldBackgroundColor;
    final Color dialogTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final Color primaryAppColor = theme.colorScheme.primary;

    final TextEditingController titleController = TextEditingController(
      text: event['title'] as String?,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: event['description'] as String?,
    );
    final TextEditingController locationController = TextEditingController(
      text: event['location'] as String?,
    );
    final TextEditingController timeController = TextEditingController(
      text: event['time'] as String?,
    );
    final TextEditingController taughtByController = TextEditingController(
      text: event['taughtBy'] as String?,
    );

    final mainScaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            'Editar Evento',
            style: TextStyle(color: dialogTextColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título del Evento',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Hora del Evento',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                TextField(
                  controller: taughtByController,
                  decoration: InputDecoration(
                    labelText: 'Impartido por',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: dialogTextColor.withAlpha((0.7 * 255).round()),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAppColor,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('El título no puede estar vacío.'),
                    ),
                  );
                  return;
                }
                final dialogNavigator = Navigator.of(dialogContext);

                try {
                  await _eventsCollection.doc(eventId).update({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'location': locationController.text,
                    'time': timeController.text,
                    'taughtBy': taughtByController.text,
                  });

                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Evento actualizado con éxito'),
                    ),
                  );
                  dialogNavigator.pop();
                } catch (error) {
                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar: ${error.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar evento por título...',
              hintText: 'Escribe el título aquí',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              suffixIcon:
                  _searchTerm.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                      : null,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                _eventsCollection.orderBy('date', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar eventos: ${snapshot.error}',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // código para mensaje "No hay eventos"
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No hay eventos programados.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Añadir Nuevo Evento'),
                        onPressed: _addEvent,
                      ),
                    ],
                  ),
                );
              }

              List<DocumentSnapshot> events = snapshot.data!.docs;

              if (_searchTerm.isNotEmpty) {
                events =
                    events.where((doc) {
                      final eventData = doc.data() as Map<String, dynamic>;
                      final title = eventData['title'] as String? ?? '';
                      return title.toLowerCase().contains(
                        _searchTerm.toLowerCase(),
                      );
                    }).toList();
              }

              if (events.isEmpty && _searchTerm.isNotEmpty) {
                return Center(
                  child: Text(
                    'No se encontraron eventos con el título "$_searchTerm".',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (events.isEmpty &&
                  _searchTerm.isEmpty &&
                  snapshot.data!.docs.isNotEmpty) {}

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: events.length + 1,
                  itemBuilder: (context, index) {
                    if (index == events.length) {
                      // botón de añadir
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Añadir Nuevo Evento'),
                            onPressed: _addEvent,
                          ),
                        ),
                      );
                    }

                    var event = events[index];
                    var eventData = event.data() as Map<String, dynamic>;
                    String formattedDate =
                        eventData.containsKey('date') &&
                                eventData['date'] is Timestamp
                            ? _formatTimestamp(eventData['date'])
                            : 'Fecha no especificada';
                    String taughtBy =
                        eventData['taughtBy'] as String? ?? 'No especificado';
                    String title =
                        eventData['title'] as String? ?? 'Sin Título';

                    return Card(
                      // código de la tarjeta
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      elevation: 3,
                      color: eventCardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '📅 $formattedDate • 🧑‍🏫 $taughtBy',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                              ),
                              tooltip: 'Editar Evento',
                              onPressed:
                                  () => _editEvent(
                                    event.id,
                                    event as QueryDocumentSnapshot,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.white70,
                              ),
                              tooltip: 'Eliminar Evento',
                              onPressed: () {
                                // código de confirmación de eliminación
                                final mainScaffoldMessenger =
                                    ScaffoldMessenger.of(context);

                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      backgroundColor:
                                          theme.scaffoldBackgroundColor,
                                      title: Text(
                                        'Confirmar Eliminación',
                                        style: TextStyle(
                                          color:
                                              theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      content: Text(
                                        '¿Estás seguro de que quieres eliminar el evento "$title"?',
                                        style: TextStyle(
                                          color:
                                              theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withAlpha(
                                                  (0.7 * 255).round(),
                                                ),
                                          ),
                                          child: const Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.error,
                                            foregroundColor:
                                                theme.colorScheme.onError,
                                          ),
                                          child: const Text('Eliminar'),
                                          onPressed: () async {
                                            final dialogNavigator =
                                                Navigator.of(dialogContext);
                                            try {
                                              await _eventsCollection
                                                  .doc(event.id)
                                                  .delete();

                                              if (!mounted) return;
                                              mainScaffoldMessenger
                                                  .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Evento eliminado',
                                                      ),
                                                    ),
                                                  );
                                            } catch (error) {
                                              if (!mounted) return;
                                              mainScaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error al eliminar: ${error.toString()}',
                                                  ),
                                                ),
                                              );
                                            }
                                            dialogNavigator.pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
