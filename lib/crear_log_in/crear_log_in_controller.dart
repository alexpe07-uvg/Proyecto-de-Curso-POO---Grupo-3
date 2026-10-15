import 'dart:convert';
import 'package:http/http.dart' as http;
import 'crear_log_in_model.dart';

class CrearLogInController {
  final CrearLogInModel model = CrearLogInModel();

  // Sesión temporal en memoria: se pierde al cerrar la app.
  static String? token;
  static Map<String, dynamic>? usuario;

  Future<void> login() async {
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:3000',
    );

    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
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
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:3000',
    );

    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/auth/registro'),
          headers: {'Content-Type': 'application/json'},
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
}
