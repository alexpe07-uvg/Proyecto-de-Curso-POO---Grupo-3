import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Tema Claro (por respaldo)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.verdeBrillante,
    );
  }

  // Tema Oscuro idéntico al que tenías corriendo
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.negroFondo,

      // Colores generales del sistema
      colorScheme: const ColorScheme.dark(
        primary: AppColors.verdeBrillante,
        onPrimary: Colors.black, // Letras negras sobre botones verdes
        surface: AppColors.negroSuperficie,
        onSurface: Colors.white,
      ),

      // Barra superior (AppBar)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.negroSuperficie,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: AppColors.bordeAppBar,
            width: 1,
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