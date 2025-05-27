import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:areteum_app/widgets/footer.dart';
import 'home_screen.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:areteum_app/widgets/custom_search_delegate.dart'
    as search_delegate_widget;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  int _selectedIndex = 2; // 0: Inicio, 1: Buscar, 2: Perfil

  String name = '';
  String email = '';
  String phone = '';
  String nif = '';
  String registrationDateFormatted = '';
  String profileImageUrl = '';

  bool isEditing = false;
  bool isLoading = true;
  bool isUploadingImage = false;
  bool isProcessingAction = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nifController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool showChangePasswordFields = false;

  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    nifController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    User? user = _auth.currentUser;
    if (user == null) {
      _handleLoadError("Usuario no autenticado.");
      return;
    }

    try {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      if (!mounted) return;

      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>?;
        setState(() {
          name = data?['name'] ?? 'N/A';
          email = data?['email'] ?? 'N/A';
          phone = data?['phone'] ?? '';
          nif = data?['nif'] ?? '';
          profileImageUrl = data?['profileImageUrl'] ?? '';

          if (data?['registrationDate'] is Timestamp) {
            DateTime parsedDate =
                (data!['registrationDate'] as Timestamp).toDate();
            registrationDateFormatted = DateFormat(
              'dd/MM/yyyy',
            ).format(parsedDate);
          } else {
            registrationDateFormatted = 'N/A';
          }
          nameController.text = name;
          phoneController.text = phone;
          nifController.text = nif;
        });
      } else {
        _handleLoadError("No se encontraron datos de usuario.");
      }
    } catch (e) {
      _handleLoadError("Error al cargar datos: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _handleLoadError(String message) {
    if (!mounted) return;
    setState(() => isLoading = false);
    _showSnackBar(message, isError: true);
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        nameController.text = name;
        phoneController.text = phone;
        nifController.text = nif;
      } else {
        showChangePasswordFields = false;
        newPasswordController.clear();
      }
    });
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (isProcessingAction) {
      return;
    }

    setState(() => isProcessingAction = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'nif': nifController.text.trim(),
        });
        if (!mounted) return;
        setState(() {
          name = nameController.text.trim();
          phone = phoneController.text.trim();
          nif = nifController.text.trim();
          isEditing = false;
        });
        _showSnackBarWithContext(
          scaffoldMessenger,
          "Perfil actualizado correctamente.",
        );
      } catch (e) {
        if (!mounted) return;
        _showSnackBarWithContext(
          scaffoldMessenger,
          "Error al guardar: ${e.toString()}",
          isError: true,
        );
      }
    }
    if (mounted) {
      setState(() => isProcessingAction = false);
    }
  }

  Future<void> _handleChangePassword() async {
    if (newPasswordController.text.trim().isEmpty) {
      _showSnackBar("La nueva contraseña no puede estar vacía.", isError: true);
      return;
    }
    if (newPasswordController.text.trim().length < 6) {
      _showSnackBar(
        "La contraseña debe tener al menos 6 caracteres.",
        isError: true,
      );
      return;
    }
    if (isProcessingAction) {
      return;
    }

    setState(() => isProcessingAction = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    User? user = _auth.currentUser;
    try {
      await user?.updatePassword(newPasswordController.text.trim());
      if (!mounted) return;
      _showSnackBarWithContext(
        scaffoldMessenger,
        "Contraseña cambiada correctamente.",
      );
      newPasswordController.clear();
      setState(() => showChangePasswordFields = false);
    } catch (e) {
      if (!mounted) return;
      _showSnackBarWithContext(
        scaffoldMessenger,
        "Error al cambiar contraseña: ${e.toString()}",
        isError: true,
      );
    }
    if (mounted) {
      setState(() => isProcessingAction = false);
    }
  }

  Future<void> _signOut() async {
    if (isProcessingAction) {
      return;
    }
    setState(() => isProcessingAction = true);
    final navigator = Navigator.of(context);

    await _auth.signOut();
    if (!mounted) return;
    await navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _pickAndUploadImage() async {
    if (isUploadingImage || isProcessingAction) {
      return;
    }

    setState(() => isUploadingImage = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (!mounted) return;
        setState(() => _pickedImageBytes = bytes);
        await _uploadImageToStorage(bytes);
      } else {
        if (!mounted) return;
        setState(() => isUploadingImage = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBarWithContext(
        scaffoldMessenger,
        "Error al seleccionar imagen: ${e.toString()}",
        isError: true,
      );
      setState(() => isUploadingImage = false);
    }
  }

  Future<void> _uploadImageToStorage(Uint8List imageBytes) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    User? user = _auth.currentUser;
    if (user == null) {
      _showSnackBarWithContext(
        scaffoldMessenger,
        "Usuario no autenticado para subir imagen.",
        isError: true,
      );
      if (mounted) {
        setState(() => isUploadingImage = false);
      }
      return;
    }

    String fileName =
        "profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    try {
      TaskSnapshot snapshot = await _storage
          .ref('profile_images/$fileName')
          .putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).set({
        'profileImageUrl': downloadUrl,
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        profileImageUrl = downloadUrl;
        _pickedImageBytes = null;
      });
      _showSnackBarWithContext(
        scaffoldMessenger,
        'Imagen de perfil actualizada.',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBarWithContext(
        scaffoldMessenger,
        "Error al subir imagen: ${e.toString()}",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isUploadingImage = false);
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    if (isUploadingImage || isProcessingAction) {
      return;
    }

    setState(() {
      isUploadingImage = true;
      isProcessingAction = true;
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    User? user = _auth.currentUser;

    if (user == null) {
      _showSnackBarWithContext(
        scaffoldMessenger,
        "Usuario no autenticado.",
        isError: true,
      );
      if (mounted) {
        setState(() {
          isUploadingImage = false;
          isProcessingAction = false;
        });
      }
      return;
    }

    try {
      if (profileImageUrl.isNotEmpty &&
          profileImageUrl.contains('firebasestorage.googleapis.com')) {
        try {
          await _storage.refFromURL(profileImageUrl).delete();
        } catch (e) {
          debugPrint(
            "Error al eliminar de Storage (puede no existir o ser un error de permisos): $e",
          );
        }
      }
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': FieldValue.delete(),
      });

      if (!mounted) return;
      setState(() {
        profileImageUrl = '';
        _pickedImageBytes = null;
      });
      _showSnackBarWithContext(
        scaffoldMessenger,
        'Imagen de perfil eliminada.',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBarWithContext(
        scaffoldMessenger,
        "Error al eliminar imagen: ${e.toString()}",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
          isProcessingAction = false;
        });
      }
    }
  }

  void _showImageOptionsBottomSheet() {
    if (isUploadingImage || isProcessingAction) {
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFEAE7D6),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black87),
                title: const Text(
                  'Cambiar imagen',
                  style: TextStyle(color: Colors.black87),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadImage();
                },
              ),
              if (profileImageUrl.isNotEmpty || _pickedImageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: const Text(
                    'Eliminar imagen',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _deleteProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _showSnackBarWithContext(
    ScaffoldMessengerState messenger,
    String message, {
    bool isError = false,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (_selectedIndex == index && index != 1) {
      return;
    }

    setState(() => _selectedIndex = index);
    final navigator = Navigator.of(context);

    switch (index) {
      case 0: // Inicio
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1: // Buscar
        showSearch(
          context: context,
          delegate: search_delegate_widget.CustomSearchDelegate(),
        );
        break;
      case 2: // Perfil
        break;
    }
  }

  ImageProvider _getProfileImageProvider() {
    if (_pickedImageBytes != null) {
      return MemoryImage(_pickedImageBytes!);
    } else if (profileImageUrl.isNotEmpty) {
      return NetworkImage(profileImageUrl);
    } else {
      return const AssetImage('assets/perfil.png');
    }
  }

  InputDecoration _editableTextFieldDecoration(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColorDark,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildEditableDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    bool isEmail = false, // Usado para no permitir editar el email
    bool isDate = false, // Usado para no permitir editar la fecha de registro
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    const Color textFieldShadowColor = Color(0x339E9E9E);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child:
                isEditing && !isEmail && !isDate
                    ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: textFieldShadowColor,
                            spreadRadius: 0.5,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: controller,
                        decoration: _editableTextFieldDecoration(label),
                        keyboardType: keyboardType,
                        validator: validator,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    )
                    : Text(
                      value.isNotEmpty
                          ? value
                          : (isEmail
                              ? email
                              : (isDate
                                  ? registrationDateFormatted
                                  : 'No especificado')),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle mainButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFA4C3A2),
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: const Size(150, 40),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D6),
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: const Color(0xFFEAE7D6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFA4C3A2)),
              )
              : RefreshIndicator(
                onRefresh: _loadUserData,
                color: const Color(0xFFA4C3A2),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap:
                              isUploadingImage || isProcessingAction
                                  ? null
                                  : _showImageOptionsBottomSheet,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: _getProfileImageProvider(),
                              ),
                              if (isUploadingImage)
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              if (!isUploadingImage)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFA4C3A2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isEditing ? nameController.text : name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        _buildEditableDetailRow(
                          icon: Icons.badge_outlined,
                          label: "Nombre completo",
                          value: name,
                          controller: nameController,
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? "El nombre no puede estar vacío"
                                      : null,
                        ),
                        _buildEditableDetailRow(
                          icon: Icons.email_outlined,
                          label: "Correo electrónico",
                          value: email,
                          controller: TextEditingController(text: email),
                          isEmail: true,
                        ),
                        _buildEditableDetailRow(
                          icon: Icons.phone_outlined,
                          label: "Teléfono",
                          value: phone,
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildEditableDetailRow(
                          icon: Icons.credit_card_outlined,
                          label: "NIF / NIE",
                          value: nif,
                          controller: nifController,
                        ),
                        _buildEditableDetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: "Fecha de Registro",
                          value: registrationDateFormatted,
                          controller: TextEditingController(
                            text: registrationDateFormatted,
                          ),
                          isDate: true,
                        ),

                        const SizedBox(height: 20),

                        if (isEditing) ...[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save_outlined),
                            label: const Text("Guardar Cambios"),
                            style: mainButtonStyle,
                            onPressed:
                                isProcessingAction ? null : _saveProfileChanges,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed:
                                isProcessingAction
                                    ? null
                                    : () {
                                      setState(
                                        () =>
                                            showChangePasswordFields =
                                                !showChangePasswordFields,
                                      );
                                    },
                            child: Text(
                              showChangePasswordFields
                                  ? "Cancelar Cambio de Contraseña"
                                  : "Cambiar Contraseña",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                          if (showChangePasswordFields) ...[
                            const SizedBox(height: 8),
                            _buildEditableDetailRow(
                              icon: Icons.lock_outline,
                              label: "Nueva Contraseña",
                              value: '', // No se muestra valor previo
                              controller: newPasswordController,
                              validator: (v) {
                                if (v != null && v.isNotEmpty && v.length < 6) {
                                  return "Mínimo 6 caracteres";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed:
                                  isProcessingAction
                                      ? null
                                      : _handleChangePassword,
                              style: mainButtonStyle,
                              child: const Text("Confirmar Nueva Contraseña"),
                            ),
                          ],
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed:
                                isProcessingAction ? null : _toggleEditing,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black54,
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                            ),
                            child: const Text("Cancelar Edición"),
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text("Editar Perfil"),
                            style: mainButtonStyle,
                            onPressed:
                                isProcessingAction ? null : _toggleEditing,
                          ),
                        ],

                        const SizedBox(height: 24),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            "Cerrar Sesión",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          onPressed: isProcessingAction ? null : _signOut,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        backgroundColor: const Color(0xFFEAE7D6),
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
      persistentFooterButtons: const [Footer()],
    );
  }
}
