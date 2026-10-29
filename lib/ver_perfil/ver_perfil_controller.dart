import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../crear_log_in/crear_log_in_controller.dart';
import 'crear_perfil_model.dart';

class VerPerfilController {
  final VerPerfilModel perfil;
  final ImagePicker _picker = ImagePicker();
  VerPerfilController(this.perfil);

  Uri _url(String ruta) =>
      Uri.parse('${dotenv.env['API_BASE_URL'] ?? ''}$ruta');
  Map<String, String> get _headers {
    final token = CrearLogInController.token;
    if (token == null) throw Exception('Debes iniciar sesión nuevamente.');
    return {
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  void _aplicar(http.Response respuesta) {
    Map<String, dynamic> datos;
    try {
      datos =
          jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('El servidor devolvió una respuesta inválida.');
    }
    if (respuesta.statusCode != 200) {
      throw Exception(datos['error'] ?? 'No se pudo guardar el perfil');
    }
    perfil.nombre = datos['nombre'] as String;
    perfil.correo = datos['correo'] as String;
    perfil.carrera = datos['carrera'] as String? ?? '';
    final foto = datos['foto_url'] as String?;
    perfil.rutaFotoPerfil = foto == null
        ? null
        : _url('/').resolve(foto).toString();
    CrearLogInController.usuario = datos;
  }

  Future<void> cargarPerfil() async {
    _aplicar(
      await http
          .get(_url('/perfil'), headers: _headers)
          .timeout(const Duration(seconds: 15)),
    );
  }

  Future<void> cambiarNombre(String nuevoNombre) async {
    final nombre = nuevoNombre.trim();
    if (nombre.isEmpty || nombre.length > 100) {
      throw Exception('Escribe un nombre de 1 a 100 caracteres.');
    }
    _aplicar(
      await http
          .post(
            _url('/perfil/nombre'),
            headers: {..._headers, 'Content-Type': 'application/json'},
            body: jsonEncode({'nombre': nombre}),
          )
          .timeout(const Duration(seconds: 15)),
    );
  }

  Future<Uint8List?> seleccionarFoto() async {
    final imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (imagen == null) return null;
    if (await imagen.length() > 5 * 1024 * 1024) {
      throw Exception('La imagen no puede superar 5 MB.');
    }
    return imagen.readAsBytes();
  }

  Future<void> guardarFoto(Uint8List bytes) async {
    _aplicar(
      await http
          .post(
            _url('/perfil/foto'),
            headers: {..._headers, 'Content-Type': 'application/octet-stream'},
            body: bytes,
          )
          .timeout(const Duration(seconds: 30)),
    );
  }

  Future<void> eliminarFotoPerfil() async {
    _aplicar(
      await http
          .post(_url('/perfil/foto/eliminar'), headers: _headers)
          .timeout(const Duration(seconds: 15)),
    );
  }
}
