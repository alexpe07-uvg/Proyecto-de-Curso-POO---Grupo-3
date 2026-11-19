import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'crear_log_in/crear_log_in_view.dart';
import 'theme/app_animations.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await dotenv.load(fileName: ".env"); 
  await ThemeController.inicializar();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.modoTema,
      builder: (context, modoActual, _) {
        return MaterialApp(
          title: 'UVG Matches',
          debugShowCheckedModeBanner: false,

          // Temas desacoplados
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: modoActual,

          // Pantalla inicial
          home: const SplashScreen(destino: CrearLogInView()),
        );
      },
    );
  }
}
