enum TipoItem { publicacion, evento }

class Comentario {
  final String autor;
  final String texto;
  final List<Comentario> respuestas;
  Comentario({required this.autor, required this.texto, List<Comentario>? respuestas}) : respuestas = respuestas ?? [];
  factory Comentario.fromJson(Map<String, dynamic> d) => Comentario(autor: d['autor'] as String? ?? 'Usuario', texto: d['texto'] as String? ?? d['contenido'] as String? ?? '', respuestas: (d['respuestas'] as List<dynamic>? ?? []).map((r) => Comentario.fromJson(r)).toList());
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
  final String? dificultad;
  final bool esCreador;
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
    this.dificultad,
    this.esCreador = false,
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
      dificultad: datos['dificultad'] as String?,
      esCreador: datos['esCreador'] == true || datos['esCreador'] == 1,
      comentarios: (datos['comentarios'] as List<dynamic>? ?? []).map((c) => Comentario.fromJson(c)).toList(),
    );
  }
}
