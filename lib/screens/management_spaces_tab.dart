import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagementSpacesTabState extends StatefulWidget {
  const ManagementSpacesTabState({super.key});

  @override
  State<ManagementSpacesTabState> createState() => _ManagementSpacesTabState();
}

class _ManagementSpacesTabState extends State<ManagementSpacesTabState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _spacesCollection;

  // Color para las tarjetas de espacios
  static const Color spaceCardColor = Color(0xFF5D7B6F);

  @override
  void initState() {
    super.initState();
    _spacesCollection = _firestore.collection('spaces');
  }

  void _addSpace() {
    final ThemeData theme = Theme.of(context);
    final Color dialogBackgroundColor = theme.scaffoldBackgroundColor;
    final Color dialogTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final Color primaryAppColor = theme.colorScheme.primary;

    final TextEditingController nameController = TextEditingController();
    final TextEditingController capacityController = TextEditingController();
    final TextEditingController statusController = TextEditingController(
      text: 'Disponible',
    ); // Valor por defecto

    final mainScaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            'Agregar Nueva Sala',
            style: TextStyle(color: dialogTextColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la Sala',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(
                    labelText: 'Capacidad',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(
                    labelText: 'Estado (Ej: Disponible, Mantenimiento)',
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
                if (nameController.text.isEmpty) {
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'El nombre de la sala no puede estar vacío.',
                      ),
                    ),
                  );
                  return;
                }
                int? capacity = int.tryParse(capacityController.text);
                if (capacity == null || capacity <= 0) {
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'La capacidad debe ser un número positivo.',
                      ),
                    ),
                  );
                  return;
                }

                final dialogNavigator = Navigator.of(dialogContext);

                try {
                  await _spacesCollection.add({
                    'name': nameController.text,
                    'capacity': capacity,
                    'status':
                        statusController.text.isNotEmpty
                            ? statusController.text
                            : 'Disponible',
                  });

                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Nueva sala agregada con éxito'),
                    ),
                  );
                  dialogNavigator.pop();
                } catch (error) {
                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al agregar sala: ${error.toString()}',
                      ),
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

  void _editSpace(DocumentSnapshot spaceDoc) {
    final ThemeData theme = Theme.of(context);
    final Color dialogBackgroundColor = theme.scaffoldBackgroundColor;
    final Color dialogTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final Color primaryAppColor = theme.colorScheme.primary;

    var spaceData = spaceDoc.data() as Map<String, dynamic>;

    final TextEditingController nameController = TextEditingController(
      text: spaceData['name'] as String?,
    );
    final TextEditingController capacityController = TextEditingController(
      text: (spaceData['capacity'] as num?)?.toString() ?? '0',
    );
    final TextEditingController statusController = TextEditingController(
      text: spaceData['status'] as String?,
    );

    final mainScaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text('Editar Sala', style: TextStyle(color: dialogTextColor)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la Sala',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(
                    labelText: 'Capacidad',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(
                    labelText: 'Estado',
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
                if (nameController.text.isEmpty) {
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'El nombre de la sala no puede estar vacío.',
                      ),
                    ),
                  );
                  return;
                }
                int? capacity = int.tryParse(capacityController.text);
                if (capacity == null || capacity <= 0) {
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'La capacidad debe ser un número positivo.',
                      ),
                    ),
                  );
                  return;
                }

                final dialogNavigator = Navigator.of(dialogContext);

                try {
                  await _spacesCollection.doc(spaceDoc.id).update({
                    'name': nameController.text,
                    'capacity': capacity,
                    'status':
                        statusController.text.isNotEmpty
                            ? statusController.text
                            : 'Disponible',
                  });

                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Sala actualizada con éxito')),
                  );
                  dialogNavigator.pop();
                } catch (error) {
                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al actualizar sala: ${error.toString()}',
                      ),
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

    return StreamBuilder<QuerySnapshot>(
      stream:
          _spacesCollection.orderBy('name').snapshots(), // Ordenar por nombre
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar salas: ${snapshot.error}',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No hay salas registradas.',
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
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text('Añadir Nueva Sala'),
                  onPressed: _addSpace,
                ),
              ],
            ),
          );
        }

        final spaces = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: spaces.length + 1,
          itemBuilder: (context, index) {
            if (index == spaces.length) {
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
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Añadir Nueva Sala'),
                    onPressed: _addSpace,
                  ),
                ),
              );
            }

            var spaceDoc = spaces[index];
            var spaceData = spaceDoc.data() as Map<String, dynamic>;
            String name = spaceData['name'] as String? ?? 'Sin Nombre';
            int capacity = (spaceData['capacity'] as num?)?.toInt() ?? 0;
            String status = spaceData['status'] as String? ?? 'No especificado';

            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              elevation: 3,
              color: spaceCardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Capacidad: $capacity • Estado: $status',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                      ),
                      tooltip: 'Editar Sala',
                      onPressed: () => _editSpace(spaceDoc),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white70,
                      ),
                      tooltip: 'Eliminar Sala',
                      onPressed: () {
                        final mainScaffoldMessenger = ScaffoldMessenger.of(
                          context,
                        );
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              backgroundColor: theme.scaffoldBackgroundColor,
                              title: Text(
                                'Confirmar Eliminación',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                              content: Text(
                                '¿Estás seguro de que quieres eliminar la sala "$name"?',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withAlpha((0.7 * 255).round()),
                                  ),
                                  child: const Text('Cancelar'),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error,
                                    foregroundColor: theme.colorScheme.onError,
                                  ),
                                  child: const Text('Eliminar'),
                                  onPressed: () async {
                                    final dialogNavigator = Navigator.of(
                                      dialogContext,
                                    );
                                    try {
                                      await _spacesCollection
                                          .doc(spaceDoc.id)
                                          .delete();
                                      if (!mounted) return;
                                      mainScaffoldMessenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Sala eliminada con éxito',
                                          ),
                                        ),
                                      );
                                    } catch (error) {
                                      if (!mounted) return;
                                      mainScaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error al eliminar sala: ${error.toString()}',
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
        );
      },
    );
  }
}
