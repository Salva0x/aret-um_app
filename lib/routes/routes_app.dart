import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/my_reservations_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/admin_management_screen.dart';
import '../screens/management_users_tab.dart';
import '../screens/management_events_tab.dart';
import '../screens/management_spaces_tab.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/home': (context) => const HomeScreen(),
    '/calendar': (context) => const CalendarScreen(),
    '/reservations': (context) => const MyReservationsScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/admin': (context) => const AdminManagementScreen(),
    '/management/users': (context) => const ManagementUsersTabState(),
    '/management/events': (context) => const ManagementEventsTabState(),
    '/management/spaces': (context) => const ManagementSpacesTabState(),
  };
}
