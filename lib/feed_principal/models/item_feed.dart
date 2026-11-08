enum TipoItem { publicacion, evento }

class Comentario {
  final String id;
  final String autor;
  final String texto;
  final DateTime fecha;
  final List<Comentario> respuestas;

  Comentario({
    required this.id,
    required this.autor,
    required this.texto,
    required this.fecha,
    List<Comentario>? respuestas,
  }) : respuestas = respuestas ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'autor': autor,
    'texto': texto,
    'fecha': fecha.toIso8601String(),
    'respuestas': respuestas.map((r) => r.toJson()).toList(),
  };

  factory Comentario.fromJson(Map<String, dynamic> datos) => Comentario(
    id: datos['id'].toString(),
    autor: datos['autor'] as String? ?? 'Usuario',
    texto: datos['texto'] as String? ?? datos['contenido'] as String? ?? '',
    fecha: DateTime.tryParse(datos['fecha'] as String? ?? '') ?? DateTime.now(),
    respuestas: (datos['respuestas'] as List<dynamic>? ?? [])
        .map((r) => Comentario.fromJson(r as Map<String, dynamic>))
        .toList(),
  );
}

class ItemFeed {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final TipoItem tipo;
  final String autor;
  final DateTime fecha;
  final String? fechaEvento;
  final String? ubicacion;
  final int? cupoMaximo;
  final List<Comentario> comentarios;

  ItemFeed({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.tipo,
    required this.autor,
    required this.fecha,
    this.fechaEvento,
    this.ubicacion,
    this.cupoMaximo,
    List<Comentario>? comentarios,
  }) : comentarios = comentarios ?? [];

  factory ItemFeed.fromJson(Map<String, dynamic> datos) {
    return ItemFeed(
      id: datos['id'].toString(),
      titulo: datos['titulo'] as String,
      descripcion: datos['descripcion'] as String,
      categoria: datos['categoria'] as String,
      tipo: datos['tipo'] == 'evento' ? TipoItem.evento : TipoItem.publicacion,
      autor: datos['autor'] as String,
      fecha: DateTime.parse(datos['fecha'] as String).toLocal(),
      fechaEvento: datos['fechaEvento'] as String?,
      ubicacion: datos['ubicacion'] as String?,
      cupoMaximo: datos['cupoMaximo'] != null
          ? int.tryParse(datos['cupoMaximo'].toString())
          : null,
      comentarios: (datos['comentarios'] as List<dynamic>? ?? [])
          .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
