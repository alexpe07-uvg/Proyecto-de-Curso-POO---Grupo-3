// Controller for the app.
class CrearEventoModel {
  // Add your controller logic here
  final String nombre;
  final String puntoEncuentro;
  final String categoria;
  final String dificultad;
  final DateTime fechaHora;
  final int cupoMaximo;
  final String descripcion;

  CrearEventoModel({
    required this.nombre,
    required this.puntoEncuentro,
    required this.categoria,
    required this.dificultad,
    required this.fechaHora,
    required this.cupoMaximo,
    required this.descripcion,
  });

  // codigo para base de datos
Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'ubicacion': puntoEncuentro,
      'categoria': categoria,
      'dificultad': dificultad,
      'fechaHora': fechaHora.toIso8601String(), // Formato estándar universal
      'cupoMaximo': cupoMaximo,
      'descripcion': descripcion,
    };
  }
}

