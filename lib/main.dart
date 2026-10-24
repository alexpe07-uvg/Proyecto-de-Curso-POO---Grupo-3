import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'crear_log_in/crear_log_in_view.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // 3. Asegura que Flutter esté inicializado antes de leer archivos
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 4. Carga el archivo .env
  await dotenv.load(fileName: ".env"); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UVG Matches',
      debugShowCheckedModeBanner: false,

      // Temas desacoplados
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Cambia automáticamente según la configuración del sistema

      // Pantalla inicial
      home: const CrearLogInView(),
    );
  }
}