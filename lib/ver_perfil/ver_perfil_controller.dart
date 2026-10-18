import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crear_perfil_model.dart';

class VerPerfilController {
  final VerPerfilModel perfil;
  final ImagePicker _imagePicker = ImagePicker();

  VerPerfilController(this.perfil);

  // Cargar los datos guardados del perfil
  Future<void> cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();

    perfil.nombre =
        prefs.getString('perfil_nombre') ?? perfil.nombre;

    perfil.rutaFotoPerfil = prefs.getString('perfil_foto');
  }

  // Cambiar el nombre del usuario
  Future<void> cambiarNombre(String nuevoNombre) async {
    final nombre = nuevoNombre.trim();

    if (nombre.isEmpty) {
      throw ArgumentError('El nombre no puede estar vacío');
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('perfil_nombre', nombre);
    perfil.cambiarNombre(nombre);
  }

  // Seleccionar y guardar una nueva foto
  Future<bool> cambiarFotoPerfil() async {
    final XFile? imagen = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (imagen == null) {
      return false;
    }

    final directorio = await getApplicationDocumentsDirectory();

    final carpeta = Directory(
      '${directorio.path}/fotos_perfil',
    );

    await carpeta.create(recursive: true);

    final extension = imagen.path.split('.').last.toLowerCase();

    final rutaNueva =
        '${carpeta.path}/perfil_${DateTime.now().microsecondsSinceEpoch}.$extension';

    final archivo = await File(imagen.path).copy(rutaNueva);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil_foto', archivo.path);

    final rutaAnterior = perfil.rutaFotoPerfil;
    perfil.cambiarFoto(archivo.path);

    if (rutaAnterior != null && rutaAnterior != archivo.path) {
      final anterior = File(rutaAnterior);

      if (await anterior.exists()) {
        try {
          await anterior.delete();
        } catch (_) {
          // La nueva foto ya está guardada.
        }
      }
    }

    return true;
  }

  // Eliminar la foto del perfil
  Future<void> eliminarFotoPerfil() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('perfil_foto');

    final rutaAnterior = perfil.rutaFotoPerfil;
    perfil.cambiarFoto(null);

    if (rutaAnterior != null) {
      final archivo = File(rutaAnterior);

      if (await archivo.exists()) {
        try {
          await archivo.delete();
        } catch (_) {
          // El perfil ya no utiliza esa fotografía.
        }
      }
    }
  }
}
