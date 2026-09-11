import 'package:flutter/material.dart';
import 'crear_evento/crear_evento_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Verde institucional brillante y vibrante
  static const Color verdeBrillante = Color.fromARGB(255, 7, 204, 37); // Verde neón/vibrante
  static const Color negroFondo = Color(0xFF0E0E0E);    // Negro casi puro
  static const Color negroSuperficie = Color(0xFF181818); // Para tarjetas o campos

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UVG Matches',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color.fromARGB(255, 7, 204, 37),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: negroFondo,
        // Forzamos el color primario exacto sin que Material 3 lo apague
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 7, 204, 37),
          onPrimary: Colors.black, // Texto negro sobre el botón verde para máxima legibilidad
          surface: negroSuperficie,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF181818),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: Color(0xFF222222), // O verdeBrillante con opacidad: Color(0x3300E676)
            width: 1,
          ),
        ),
      ),
        // Estilo de los campos de texto
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: negroSuperficie,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIconColor: const Color.fromARGB(255, 7, 204, 37),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: verdeBrillante, width: 1.8),
          ),
        ),
        // Botón Publicar brillante
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 7, 204, 37),
            foregroundColor: Colors.black, // Contraste limpio con letra negra
            elevation: 2,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),

      themeMode: ThemeMode.dark,


      // home: const CrearEventoView(), //- pantalla Mario
    );
  }
}