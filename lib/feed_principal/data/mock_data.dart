import '../models/item_feed.dart';

final List<ItemFeed> mockItemsFeed = [
  ItemFeed(
    id: '1',
    titulo: 'Taller de Mario Bros',
    descripcion: 'Aprende Mario Bros desde cero.',
    categoria: 'Gaming / Juegos de mesa',
    tipo: TipoItem.evento,
    autor: 'Comité de Gaming UVG',
    fecha: DateTime.now().subtract(const Duration(hours: 3)),
    fechaEvento: '18 de Septiembre, 15:00 hrs',
    ubicacion: 'Laboratorio CIT-301',
  ),
  ItemFeed(
    id: '2',
    titulo: 'Clases avanzadas de GO y Otello',
    descripcion: 'Aprende estrategias avanzadas de GO y Otello.',
    categoria: 'Gaming / Juegos de mesa',
    tipo: TipoItem.publicacion,
    autor: 'Departamento de Matemáticas UVG',
    fecha: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ItemFeed(
    id: '3',
    titulo: 'Torneo Interuniversitario de Fútbol 7',
    descripcion: 'Inscripciones abiertas para todos los estudiantes. ¡Arma tu equipo y participa!',
    categoria: 'Deportes y Actividad Física',
    tipo: TipoItem.evento,
    autor: 'Deportes UVG',
    fecha: DateTime.now().subtract(const Duration(days: 2)),
    fechaEvento: '25 de Septiembre, 09:00 hrs',
    ubicacion: 'Cancha Principal',
  ),
  ItemFeed(
    id: '4',
    titulo: 'Convocatoria a Voluntariado',
    descripcion: 'Buscamos estudiantes entusiastas para apoyar en el torneo de FIFA.',
    categoria: 'Gaming / Juegos de mesa',
    tipo: TipoItem.publicacion,
    autor: 'Asociación de Estudiantes',
    fecha: DateTime.now().subtract(const Duration(days: 3)),
  ),
];