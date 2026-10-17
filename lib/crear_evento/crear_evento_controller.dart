import 'package:flutter/material.dart';
import 'crear_evento_model.dart';

class CrearEventoController extends ChangeNotifier {
  bool _cargando = false;
  bool get cargando => _cargando;

  // Método exclusivo para descartar pantalla (botón Cancelar)
  void cancelar(BuildContext context) {
    Navigator.pop(context);
  }

  // Método para publicar y enviar el evento al Feed
  Future<void> publicarEvento(BuildContext context, CrearEventoModel nuevoEvento) async {
    _cargando = true;
    notifyListeners();

    try {
      // Simula el tiempo de conexión a la base de datos
      await Future.delayed(const Duration(seconds: 2));

      _cargando = false;
      notifyListeners();

      // Validación de ciclo de vida antes de usar context
      if (!context.mounted) return;

      // 1. Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '¡Evento publicado con éxito!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF00E676), width: 1.5),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // 2. Cierra la pantalla y envía el nuevo evento al Feed principal
      Navigator.pop(context, nuevoEvento);

    } catch (e) {
      _cargando = false;
      notifyListeners();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error al guardar el evento'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}