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
}