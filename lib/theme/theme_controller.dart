import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> modoTema = ValueNotifier(ThemeMode.system);

  /// Carga la preferencia guardada por el usuario (o por defecto modo oscuro)
  static Future<void> inicializar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardado = prefs.getString('modo_tema');
      if (guardado == 'oscuro') {
        modoTema.value = ThemeMode.dark;
      } else if (guardado == 'claro') {
        modoTema.value = ThemeMode.light;
      } else {
        modoTema.value = ThemeMode.dark; // Por defecto el tema oscuro característico de UVG Matches
      }
    } catch (_) {
      modoTema.value = ThemeMode.dark;
    }
  }

  /// Alterna entre modo oscuro y claro y guarda la preferencia en SharedPreferences
  static Future<void> alternarTema(BuildContext context) async {
    final brilloActual = Theme.of(context).brightness;
    final esOscuro = brilloActual == Brightness.dark;
    final nuevoModo = esOscuro ? ThemeMode.light : ThemeMode.dark;

    modoTema.value = nuevoModo;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('modo_tema', esOscuro ? 'claro' : 'oscuro');
    } catch (_) {}
  }
}
