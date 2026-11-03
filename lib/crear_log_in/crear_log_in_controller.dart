import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'crear_log_in_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CrearLogInController {
  final CrearLogInModel model = CrearLogInModel();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _fotoBytes;

  static String? token;
  static Map<String, dynamic>? usuario;
  static String? fotoPerfilLocal;

  Future<void> login() async {
    final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json', 'ngrok-skip-browser-warning': 'true',},
          body: jsonEncode({
            'email': model.email.trim(),
            'password': model.password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final datos =
        jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;

    if (respuesta.statusCode != 200) {
      throw Exception(datos['error'] ?? 'No se pudo iniciar sesión');
    }

    token = datos['token'] as String;
    usuario = datos['usuario'] as Map<String, dynamic>;
  }

  Future<void> registrar() async {
    final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/auth/registro'),
          headers: {'Content-Type': 'application/json', 'ngrok-skip-browser-warning': 'true',},
          body: jsonEncode({
            'email': model.email.trim(),
            'password': model.password,
            'alias': model.alias.trim(),
            'carrera': model.carrera,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final datos =
        jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;

    if (respuesta.statusCode != 201) {
      throw Exception(datos['error'] ?? 'No se pudo crear la cuenta');
    }
  }
  Future<bool> cambiarFotoPerfil() async {
    final XFile? imagen = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagen != null) {
      _fotoBytes = await imagen.readAsBytes();
      model.rutaFotoPerfil = imagen.path;
      fotoPerfilLocal = imagen.path;
      return true;
    }

    return false;
    }

  Future<bool> subirFotoRegistro() async {
    final bytes = _fotoBytes;
    if (bytes == null) return true;
    if (bytes.length > 5 * 1024 * 1024) return false;

    try {
      await login();

      final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

      final respuesta = await http
          .post(
            Uri.parse('$baseUrl/perfil/foto'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/octet-stream',
              'ngrok-skip-browser-warning': 'true',
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode != 200) return false;

      _fotoBytes = null;
      return true;
    } catch (_) {
      return false;
    } finally {
      token = null;
      usuario = null;
    }
  }
}
