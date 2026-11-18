import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../crear_log_in/crear_log_in_controller.dart';
import 'crear_evento_model.dart';

class CrearEventoController extends ChangeNotifier {
  bool _cargando = false;
  bool _cerrado = false;

  bool get cargando => _cargando;

  void cancelar(BuildContext context) {
    Navigator.pop(context);
  }

  void _actualizarCarga(bool valor) {
    _cargando = valor;
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    super.dispose();
  }

  Future<void> publicarEvento(
    BuildContext context,
    CrearEventoModel nuevoEvento,
  ) async {
    if (_cargando) return;

    final token = CrearLogInController.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión nuevamente.')),
      );
      return;
    }

    _actualizarCarga(true);

    try {
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:3000',
      );

      final respuesta = await http
          .post(
            Uri.parse('$baseUrl/eventos'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(nuevoEvento.toMap()),
          )
          .timeout(const Duration(seconds: 15));

      final datos = jsonDecode(
        utf8.decode(respuesta.bodyBytes),
      ) as Map<String, dynamic>;

      if (respuesta.statusCode != 201) {
        throw Exception(datos['error'] ?? 'No se pudo guardar el evento');
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Evento guardado con exito!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      _actualizarCarga(false);
    }
  }
}