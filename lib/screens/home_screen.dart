import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:areteum_app/widgets/footer.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import 'package:areteum_app/widgets/custom_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String userRole = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (mounted) {
          setState(() {
            userName = userData.get('name') ?? 'Usuario';
            userRole = userData.get('role') ?? 'user';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            userName = 'Usuario';
            userRole = 'user';
          });
          debugPrint("Error al obtener datos del usuario: $e");
        }
      }
    }
  }

  void _signOut() async {
    final navigator = Navigator.of(context, rootNavigator: true);
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      await navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index && index != 1) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    final navigator = Navigator.of(context);
    switch (index) {
      case 0:
        if (ModalRoute.of(context)?.settings.name != '/') {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
        break;
      case 1:
        showSearch(
          context: context,
          delegate: CustomSearchDelegate(initialQuery: ''),
        );
        break;
      case 2:
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  // Widget reutilizable para crear los botones del menú principal
  Widget _buildMenuButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required ButtonStyle style,
    required TextStyle textStyle,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: style.copyWith(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.black),
              const SizedBox(height: 8),
              Text(label, style: textStyle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle mainButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFA4C3A2),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );

    const TextStyle buttonTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 13,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Image.asset('assets/logo.png', height: 150, width: 150),
                        const SizedBox(height: 12),
                        const Text(
                          "ARETÉUM",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D7B6F),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Bienvenido/a, $userName!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // Fila 1 de botones
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMenuButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CalendarScreen(),
                                  ),
                                );
                              },
                              icon: Icons.calendar_today,
                              label: "Calendario",
                              style: mainButtonStyle,
                              textStyle: buttonTextStyle,
                            ),
                            _buildMenuButton(
                              onPressed: () => _onItemTapped(2),
                              icon: Icons.person_outline,
                              label: "Mi Perfil",
                              style: mainButtonStyle,
                              textStyle: buttonTextStyle,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ), // Espacio entre filas de botones
                        // Fila 2 de botones
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMenuButton(
                              onPressed: () {
                                try {
                                  Navigator.pushNamed(context, '/reservations');
                                } catch (e) {
                                  debugPrint(
                                    "Error al navegar a /reservations: $e. Asegúrate que la ruta esté definida.",
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error al abrir mis reservas.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: Icons.event_available_outlined,
                              label: "Mis Reservas",
                              style: mainButtonStyle,
                              textStyle: buttonTextStyle,
                            ),
                            _buildMenuButton(
                              onPressed: _signOut,
                              icon: Icons.exit_to_app_outlined,
                              label: "Cerrar Sesión",
                              style: mainButtonStyle,
                              textStyle: buttonTextStyle,
                            ),
                          ],
                        ),

                        if (userRole == 'admin')
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 24,
                              left: 8,
                              right: 8,
                            ),
                            child: SizedBox(
                              // Para darle un ancho similar a los otros botones
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  try {
                                    Navigator.pushNamed(context, '/admin');
                                  } catch (e) {
                                    debugPrint(
                                      "Error al navegar a /admin: $e. Asegúrate que la ruta esté definida.",
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Error al acceder a gestión de admin.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: mainButtonStyle.copyWith(
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                                child: const Text(
                                  'Acceder a Gestión de Admin',
                                  style: buttonTextStyle,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF5D7B6F),
        unselectedItemColor: Colors.grey.shade700,
        backgroundColor: const Color(0xFFEAE7D6),
        type: BottomNavigationBarType.fixed,
        elevation: 2,
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
