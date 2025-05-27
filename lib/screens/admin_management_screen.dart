import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'package:areteum_app/screens/management_spaces_tab.dart';
import 'package:areteum_app/screens/management_users_tab.dart';
import 'package:areteum_app/screens/management_events_tab.dart';
import 'package:areteum_app/widgets/footer.dart';
import 'package:areteum_app/widgets/custom_search_delegate.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = -1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Admin'),
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
          // Pestañas
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10.0),
              ),
              indicatorPadding: const EdgeInsets.all(2.0),
              labelColor: theme.colorScheme.onPrimary,
              unselectedLabelColor: theme.textTheme.bodyMedium?.color
                  ?.withAlpha((0.7 * 255).round()),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Espacios'),
                Tab(text: 'Usuarios'),
                Tab(text: 'Eventos'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBarView(
                controller: _tabController,
                children: const [
                  ManagementSpacesTabState(),
                  ManagementUsersTabState(),
                  ManagementEventsTabState(),
                ],
              ),
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
