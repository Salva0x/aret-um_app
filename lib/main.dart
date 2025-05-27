import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'routes/routes_app.dart';
import 'screens/event_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa los datos de formato de fecha para español
  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definición de colores consistentes para el tema
    const Color primaryAppColor = Color(0xFFA4C3A2);
    const Color backgroundAppColor = Color(0xFFEAE7D6);
    const Color textAppColor = Colors.black87;

    return MaterialApp(
      title: 'Aretéum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryAppColor,
        scaffoldBackgroundColor: backgroundAppColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryAppColor,
          primary: primaryAppColor,
          surface: backgroundAppColor,
          onPrimary: Colors.black,
          onSurface: textAppColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundAppColor,
          elevation: 0,
          iconTheme: IconThemeData(color: textAppColor),
          titleTextStyle: TextStyle(
            color: textAppColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryAppColor,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryAppColor),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: textAppColor),
          titleLarge: TextStyle(
            color: textAppColor,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: primaryAppColor),
          ),
          labelStyle: TextStyle(
            color: textAppColor.withAlpha((0.7 * 255).round()),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: backgroundAppColor,
          selectedItemColor: primaryAppColor,
          unselectedItemColor: Colors.grey.shade600,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: AppRoutes.routes,
      onGenerateRoute: (settings) {
        if (settings.name == '/event') {
          if (settings.arguments is Map<String, dynamic>) {
            final args = settings.arguments as Map<String, dynamic>;
            final eventId = args['eventId'] as String?;
            if (eventId != null) {
              return MaterialPageRoute(
                builder: (_) => EventDetailScreen(eventId: eventId),
              );
            }
          }
        }
        return null;
      },
    );
  }
}
