import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagementUsersTabState extends StatefulWidget {
  const ManagementUsersTabState({super.key});

  @override
  State<ManagementUsersTabState> createState() => _ManagementUsersTabState();
}

class _ManagementUsersTabState extends State<ManagementUsersTabState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _usersCollection;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  static const Color userCardColor = Color(0xFF5D7B6F);

  @override
  void initState() {
    super.initState();
    _usersCollection = _firestore.collection('users');
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

  void _addUser() {
    final ThemeData theme = Theme.of(context);
    final Color dialogBackgroundColor = theme.scaffoldBackgroundColor;
    final Color dialogTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final Color primaryAppColor = theme.colorScheme.primary;

    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController roleController = TextEditingController(
      text: 'user',
    );

    final mainScaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            'Agregar Nuevo Usuario',
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
                    labelText: 'Nombre Completo',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono (Opcional)',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                    labelText: 'Rol (Ej: user, admin)',
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
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Nombre y correo son obligatorios.'),
                    ),
                  );
                  return;
                }
                if (!emailController.text.contains('@') ||
                    !emailController.text.contains('.')) {
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Correo electrónico no válido.'),
                    ),
                  );
                  return;
                }

                final dialogNavigator = Navigator.of(dialogContext);

                try {
                  await _usersCollection.add({
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'role':
                        roleController.text.isNotEmpty
                            ? roleController.text.toLowerCase()
                            : 'user',
                    'status': 'Activo',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Nuevo usuario agregado a la base de datos',
                      ),
                    ),
                  );
                  dialogNavigator.pop();
                } catch (error) {
                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al agregar usuario: ${error.toString()}',
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

  void _editUser(DocumentSnapshot userDoc) {
    final ThemeData theme = Theme.of(context);
    final Color dialogBackgroundColor = theme.scaffoldBackgroundColor;
    final Color dialogTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final Color primaryAppColor = theme.colorScheme.primary;

    var userData = userDoc.data() as Map<String, dynamic>;

    final TextEditingController nameController = TextEditingController(
      text: userData['name'] as String?,
    );
    final TextEditingController emailController = TextEditingController(
      text: userData['email'] as String?,
    );
    final TextEditingController phoneController = TextEditingController(
      text: userData['phone'] as String?,
    );
    final TextEditingController roleController = TextEditingController(
      text: userData['role'] as String?,
    );
    final TextEditingController statusController = TextEditingController(
      text: userData['status'] as String? ?? 'Activo',
    );

    final mainScaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            'Editar Usuario',
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
                    labelText: 'Nombre Completo',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico (Generalmente no editable)',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                  readOnly: true,
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    labelStyle: TextStyle(
                      color: dialogTextColor.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  style: TextStyle(color: dialogTextColor),
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(
                    labelText: 'Estado (Ej: Activo, Inactivo)',
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
                    const SnackBar(content: Text('El nombre es obligatorio.')),
                  );
                  return;
                }

                final dialogNavigator = Navigator.of(dialogContext);

                try {
                  await _usersCollection.doc(userDoc.id).update({
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'role':
                        roleController.text.isNotEmpty
                            ? roleController.text.toLowerCase()
                            : 'user',
                    'status':
                        statusController.text.isNotEmpty
                            ? statusController.text
                            : 'Activo',
                  });

                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Usuario actualizado con éxito'),
                    ),
                  );
                  dialogNavigator.pop();
                } catch (error) {
                  if (!mounted) return;
                  mainScaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al actualizar usuario: ${error.toString()}',
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar usuario por nombre...',
              hintText: 'Escribe el nombre aquí',
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
            stream: _usersCollection.orderBy('name').snapshots(),
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
                    'Error al cargar usuarios: ${snapshot.error}',
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
                        'No hay usuarios registrados.',
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
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: const Text('Añadir Nuevo Usuario'),
                        onPressed: _addUser,
                      ),
                    ],
                  ),
                );
              }

              List<DocumentSnapshot> users = snapshot.data!.docs;

              // Filtrar usuarios
              if (_searchTerm.isNotEmpty) {
                users =
                    users.where((doc) {
                      final userData = doc.data() as Map<String, dynamic>;
                      final name = userData['name'] as String? ?? '';
                      return name.toLowerCase().contains(
                        _searchTerm.toLowerCase(),
                      );
                    }).toList();
              }

              if (users.isEmpty && _searchTerm.isNotEmpty) {
                return Center(
                  child: Text(
                    'No se encontraron usuarios con el nombre "$_searchTerm".',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (users.isEmpty &&
                  _searchTerm.isEmpty &&
                  snapshot.data!.docs.isNotEmpty) {}

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: users.length + 1,
                  itemBuilder: (context, index) {
                    if (index == users.length) {
                      // ... (botón de añadir sin cambios)
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
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: const Text('Añadir Nuevo Usuario'),
                            onPressed: _addUser,
                          ),
                        ),
                      );
                    }

                    var userDoc = users[index];
                    var userData = userDoc.data() as Map<String, dynamic>;
                    String name = userData['name'] as String? ?? 'Sin Nombre';
                    String email = userData['email'] as String? ?? 'Sin Correo';
                    String role = userData['role'] as String? ?? 'user';
                    String status =
                        userData['status'] as String? ?? 'Desconocido';

                    return Card(
                      // ... (código de la tarjeta sin cambios)
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      elevation: 3,
                      color: userCardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                          '$email\nRol: $role • Estado: $status',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                              ),
                              tooltip: 'Editar Usuario',
                              onPressed: () => _editUser(userDoc),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.white70,
                              ),
                              tooltip: 'Eliminar Usuario (Solo de Firestore)',
                              onPressed: () {
                                // ... (código de confirmación de eliminación sin cambios)
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
                                        '¿Estás seguro de que quieres eliminar al usuario "$name" de la base de datos Firestore? Esto NO elimina su cuenta de autenticación si existe.',
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
                                          child: const Text(
                                            'Eliminar de Firestore',
                                          ),
                                          onPressed: () async {
                                            final dialogNavigator =
                                                Navigator.of(dialogContext);
                                            try {
                                              await _usersCollection
                                                  .doc(userDoc.id)
                                                  .delete();
                                              if (!mounted) {
                                                return;
                                              }
                                              mainScaffoldMessenger.showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Usuario eliminado de Firestore',
                                                  ),
                                                ),
                                              );
                                            } catch (error) {
                                              if (!mounted) {
                                                return;
                                              }
                                              mainScaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error al eliminar usuario: ${error.toString()}',
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
