import 'package:flutter/material.dart';
import 'app_animations.dart';
import 'app_colors.dart';

class AppTheme {
  static const PageTransitionsTheme _transiciones = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: TransicionPaginaSuaveBuilder(),
      TargetPlatform.iOS: TransicionPaginaSuaveBuilder(),
      TargetPlatform.windows: TransicionPaginaSuaveBuilder(),
      TargetPlatform.macOS: TransicionPaginaSuaveBuilder(),
      TargetPlatform.linux: TransicionPaginaSuaveBuilder(),
    },
  );

  // Tema Claro (por respaldo)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.verdeBannerClaro,
        brightness: Brightness.light,
        primary: AppColors.verdeBosqueLogo,
        onPrimary: Colors.white,
        secondary: AppColors.verdeBannerClaro,
        onSecondary: AppColors.verdeBosqueLogo,
      ),
      pageTransitionsTheme: _transiciones,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.verdeBannerClaro,
        foregroundColor: AppColors.verdeBosqueLogo,
        elevation: 2,
        titleTextStyle: TextStyle(
          color: AppColors.verdeBosqueLogo,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: AppColors.verdeBosqueLogo),
        shape: Border(
          bottom: BorderSide(
            color: Color(0xFF72BF1D),
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdeBannerClaro,
          foregroundColor: AppColors.verdeBosqueLogo,
          elevation: 2,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // Tema Oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.negroFondo,
      pageTransitionsTheme: _transiciones,

      // Colores generales del sistema
      colorScheme: const ColorScheme.dark(
        primary: AppColors.verdeBannerClaro,
        onPrimary: AppColors.verdeBosqueLogo, // Letras negras sobre botones verdes
        surface: AppColors.negroSuperficie,
        onSurface: Colors.white,
      ),

      // Barra superior (AppBar)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.verdeBannerOscuro,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: AppColors.verdeBannerClaro),
        shape: Border(
          bottom: BorderSide(
            color: AppColors.bordeBannerOscuro,
            width: 1.5,
          ),
        ),
      ),

      // Cursor y selección de texto verde al escribir
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.verdeBrillante,
        selectionColor: Color(0x5507CC25),
        selectionHandleColor: AppColors.verdeBrillante,
      ),

      // Campos de texto (Login, Eventos, Perfil)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.negroSuperficie,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: AppColors.verdeBrillante,

        // Borde cuando no estás escribiendo en él
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.bordeInputInactivo),
        ),

        // CONTORNO VERDE CUANDO HACES CLIC Y ESCRIBES
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.verdeBrillante,
            width: 1.8,
          ),
        ),
      ),

      // BOTÓN DE INICIAR SESIÓN Y PUBLICAR (Verde con texto negro y negrita)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdeBrillante,
          foregroundColor: Colors.black,
          elevation: 2,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}