enum TipoItem { publicacion, evento }

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
  });

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
    );
  }
}
