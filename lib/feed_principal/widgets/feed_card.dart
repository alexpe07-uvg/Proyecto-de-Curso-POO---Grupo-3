import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../crear_log_in/crear_log_in_controller.dart';
import '../../theme/app_animations.dart';
import '../models/item_feed.dart';

class FeedCard extends StatefulWidget {
  final ItemFeed item;

  const FeedCard({super.key, required this.item});

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  late List<Comentario> _comentarios;
  bool _inscrito = false;
  int _cupoOcupado = 0;
  List<String> _inscritosNombres = [];
  bool _procesandoInscripcion = false;
  int _disparadorError = 0;
  int get _cupoMaximo => widget.item.cupoMaximo ?? 10;

  @override
  void initState() {
    super.initState();
    _sincronizarDesdeItem();
    _cargarDatosPersistentes();
  }

  @override
  void didUpdateWidget(covariant FeedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sincronizarDesdeItem();
  }

  void _sincronizarDesdeItem() {
    _comentarios = List<Comentario>.from(widget.item.comentarios);
    _inscrito = widget.item.inscrito;
    _cupoOcupado = widget.item.cupoOcupado;
    _inscritosNombres = List<String>.from(widget.item.inscritosNombres);
  }

  Future<void> _cargarDatosPersistentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (CrearLogInController.token != null) {
        await _guardarComentarios();
        await prefs.setInt('feed_cupo_ocupado_${widget.item.id}', _cupoOcupado);
        return;
      }

      // 1. Cargar comentarios guardados de este item
      final comentariosGuardados =
          prefs.getString('feed_comentarios_${widget.item.id}');
      if (comentariosGuardados != null) {
        final List<dynamic> listaJson = jsonDecode(comentariosGuardados);
        _comentarios = listaJson
            .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
            .toList();
      }

      // 2. Cargar cupo ocupado del evento
      final cupoGuardado = prefs.getInt('feed_cupo_ocupado_${widget.item.id}');
      if (cupoGuardado != null) {
        _cupoOcupado = cupoGuardado;
      }

      // 3. Cargar estado de inscripción del usuario actual
      final usuarioKey = (CrearLogInController.usuario?['correo'] ??
              CrearLogInController.usuario?['id'] ??
              'invitado')
          .toString();
      final listaInscritos =
          prefs.getStringList('feed_inscripciones_$usuarioKey') ?? [];
      _inscrito = listaInscritos.contains(widget.item.id);

      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _guardarComentarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr =
          jsonEncode(_comentarios.map((c) => c.toJson()).toList());
      await prefs.setString('feed_comentarios_${widget.item.id}', jsonStr);
    } catch (_) {}
  }

  Future<void> _toggleInscripcion() async {
    if (_procesandoInscripcion) return;
    final token = CrearLogInController.token;
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    if (token != null && baseUrl.isNotEmpty) {
      setState(() => _procesandoInscripcion = true);
      try {
        final respuesta = await http
            .post(
              Uri.parse('$baseUrl/eventos/${widget.item.id}/inscripcion'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
                'ngrok-skip-browser-warning': 'true',
              },
            )
            .timeout(const Duration(seconds: 10));

        final datos =
            jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;

        if (respuesta.statusCode != 200) {
          if (mounted) {
            setState(() => _disparadorError++);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  datos['error']?.toString() ??
                      'No se pudo actualizar la inscripción.',
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        _inscrito = datos['inscrito'] == true;
        _cupoOcupado =
            int.tryParse(datos['cupoOcupado'].toString()) ?? _cupoOcupado;
        _inscritosNombres = (datos['inscritosNombres'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('feed_cupo_ocupado_${widget.item.id}', _cupoOcupado);

        if (mounted) {
          setState(() {});
        }
      } catch (_) {
        if (mounted) {
          setState(() => _disparadorError++);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo conectar con el servidor.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _procesandoInscripcion = false);
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usuarioKey = (CrearLogInController.usuario?['correo'] ??
            CrearLogInController.usuario?['id'] ??
            'invitado')
        .toString();
    final listaInscritos =
        prefs.getStringList('feed_inscripciones_$usuarioKey') ?? [];

    if (!_inscrito) {
      if (_cupoOcupado >= _cupoMaximo) {
        if (mounted) {
          setState(() => _disparadorError++);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lo sentimos, este evento ya alcanzó su cupo máximo.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
      _inscrito = true;
      _cupoOcupado++;
      if (!listaInscritos.contains(widget.item.id)) {
        listaInscritos.add(widget.item.id);
      }
    } else {
      _inscrito = false;
      if (_cupoOcupado > 0) _cupoOcupado--;
      listaInscritos.remove(widget.item.id);
    }

    await prefs.setStringList('feed_inscripciones_$usuarioKey', listaInscritos);
    await prefs.setInt('feed_cupo_ocupado_${widget.item.id}', _cupoOcupado);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _eliminarEvento() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text('¿Seguro que deseas eliminar este evento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    final token = CrearLogInController.token;
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (token == null || baseUrl.isEmpty) return;
    try {
      final respuesta = await http.delete(
        Uri.parse('$baseUrl/eventos/${widget.item.id}'),
        headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'},
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (respuesta.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento eliminado')));
        Navigator.pop(context, true);
      } else {
        final datos = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(datos['error']?.toString() ?? 'No se pudo eliminar')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo eliminar el evento')));
    }
  }

  Future<void> _abrirComentarios() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ComentariosSheet(
        eventoId: widget.item.id,
        comentarios: _comentarios,
        onActualizarLista: (lista) {
          setState(() => _comentarios = lista);
          _guardarComentarios();
        },
        onAgregar: (c) {
          setState(() => _comentarios.add(c));
          _guardarComentarios();
        },
        onGuardar: () {
          setState(() {});
          _guardarComentarios();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final esEvento = item.tipo == TipoItem.evento;
    final esquema = Theme.of(context).colorScheme;
    final esOrganizador = item.esCreador;
    final cupoLleno = _cupoOcupado >= _cupoMaximo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: EfectoErrorRojo(
        disparador: _disparadorError,
        radioBorde: 12,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: esquema.primary.withValues(alpha: 0.2),
                      child: Icon(
                        esEvento ? Icons.event : Icons.article,
                        color: esquema.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.autor,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          esEvento ? 'Evento' : 'Publicación',
                          style: TextStyle(fontSize: 12, color: esquema.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    item.categoria,
                    style: TextStyle(fontSize: 11, color: esquema.onPrimary),
                  ),
                  backgroundColor: esquema.primary,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              item.descripcion,
              style: TextStyle(fontSize: 14, color: esquema.onSurface),
            ),
            if (esEvento) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: esquema.primary),
                  const SizedBox(width: 6),
                  Text(
                    item.fechaEventoVisible,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: esquema.primary),
                  const SizedBox(width: 6),
                  Text(
                    item.ubicacion ?? '',
                    style: TextStyle(fontSize: 13, color: esquema.onSurfaceVariant),
                  ),
                ],
              ),
              if (item.dificultad != null && item.dificultad!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.speed, size: 16, color: esquema.primary),
                    const SizedBox(width: 6),
                    Text('Dificultad: ${item.dificultad}', style: TextStyle(fontSize: 13, color: esquema.onSurfaceVariant)),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 16,
                    color: cupoLleno ? Colors.orangeAccent : esquema.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cupoLleno
                        ? 'Cupo: $_cupoOcupado / $_cupoMaximo (Cupo lleno)'
                        : 'Cupo: $_cupoOcupado / $_cupoMaximo disponibles',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cupoLleno ? Colors.orangeAccent : esquema.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (_inscritosNombres.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.people_alt_outlined, size: 16, color: esquema.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Inscritos: ${_inscritosNombres.join(', ')}',
                        style: TextStyle(fontSize: 12, color: esquema.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (esOrganizador)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: esquema.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: esquema.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded, size: 16, color: esquema.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Tu evento',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: esquema.primary,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Eliminar evento',
                            onPressed: _eliminarEvento,
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    )
                  else if (!_inscrito && cupoLleno)
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.block, size: 18),
                      label: const Text('Cupo lleno'),
                    )
                  else
                    BotonInscripcionCartoon(
                      inscrito: _inscrito,
                      onPressed: _toggleInscripcion,
                    ),
                  ReboteAlPresionar(
                    child: TextButton.icon(
                      onPressed: _abrirComentarios,
                      icon: const Icon(Icons.forum_outlined, size: 18),
                      label: Text('Comentarios (${_comentarios.length})'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
        ),
      ),
    );
  }
}

class _ComentariosSheet extends StatefulWidget {
  final String eventoId;
  final List<Comentario> comentarios;
  final ValueChanged<List<Comentario>> onActualizarLista;
  final ValueChanged<Comentario> onAgregar;
  final VoidCallback onGuardar;

  const _ComentariosSheet({
    required this.eventoId,
    required this.comentarios,
    required this.onActualizarLista,
    required this.onAgregar,
    required this.onGuardar,
  });

  @override
  State<_ComentariosSheet> createState() => _ComentariosSheetState();
}

class _ComentariosSheetState extends State<_ComentariosSheet> {
  final _controlador = TextEditingController();
  late List<Comentario> _lista;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _lista = List<Comentario>.from(widget.comentarios);
    _cargarDesdeServidor();
  }

  Future<void> _cargarDesdeServidor() async {
    final token = CrearLogInController.token;
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (token == null || baseUrl.isEmpty) return;

    try {
      final respuesta = await http
          .get(
            Uri.parse('$baseUrl/eventos/${widget.eventoId}/comentarios'),
            headers: {
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(utf8.decode(respuesta.bodyBytes)) as List<dynamic>;
        final nuevos = datos
            .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
            .toList();
        if (mounted) {
          setState(() => _lista = nuevos);
          widget.onActualizarLista(nuevos);
        }
      }
    } catch (_) {}
  }

  Future<void> _enviarComentario(String texto, {String? padreId}) async {
    final limpio = texto.trim();
    if (limpio.isEmpty || _enviando) return;

    final token = CrearLogInController.token;
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    if (token != null && baseUrl.isNotEmpty) {
      setState(() => _enviando = true);
      try {
        final respuesta = await http
            .post(
              Uri.parse('$baseUrl/eventos/${widget.eventoId}/comentarios'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
                'ngrok-skip-browser-warning': 'true',
              },
              body: jsonEncode({
                'texto': limpio,
                'padreId': ?padreId,
              }),
            )
            .timeout(const Duration(seconds: 10));

        if (respuesta.statusCode == 201) {
          final datos =
              jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
          final listaJson = datos['comentarios'] as List<dynamic>? ?? [];
          final nuevos = listaJson
              .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
              .toList();
          if (padreId == null) _controlador.clear();
          if (mounted) {
            setState(() => _lista = nuevos);
            widget.onActualizarLista(nuevos);
          }
          return;
        }
      } catch (_) {
      } finally {
        if (mounted) setState(() => _enviando = false);
      }
    }

    final miNombre =
        CrearLogInController.usuario?['nombre'] as String? ?? 'Tú';
    final nuevo = Comentario(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      autor: miNombre,
      texto: limpio,
      fecha: DateTime.now(),
    );

    if (padreId == null) {
      widget.onAgregar(nuevo);
      _controlador.clear();
      if (mounted) setState(() => _lista = List<Comentario>.from(widget.comentarios));
    } else {
      final idx = _lista.indexWhere((c) => c.id == padreId);
      if (idx >= 0) {
        setState(() {
          _lista[idx].respuestas.add(nuevo);
        });
        widget.onActualizarLista(_lista);
      }
    }
  }

  void _publicar() {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;
    _enviarComentario(texto);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .72,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Comentarios del evento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _lista.isEmpty
                      ? const Center(
                          child:
                              Text('Aún no hay comentarios. ¡Sé el primero!'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _lista.length,
                          itemBuilder: (_, i) => _ComentarioTile(
                            comentario: _lista[i],
                            onResponder: (respuesta) {
                              _enviarComentario(
                                respuesta.texto,
                                padreId: _lista[i].id,
                              );
                            },
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controlador,
                          onSubmitted: (_) => _publicar(),
                          decoration: const InputDecoration(
                            hintText: 'Escribe un comentario...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _enviando ? null : _publicar,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ComentarioTile extends StatelessWidget {
  final Comentario comentario;
  final ValueChanged<Comentario> onResponder;

  const _ComentarioTile({
    required this.comentario,
    required this.onResponder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comentario.autor,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(comentario.texto),
            TextButton.icon(
              onPressed: () async {
                final control = TextEditingController();
                final texto = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Responder comentario'),
                    content: TextField(
                      controller: control,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu respuesta',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, control.text.trim()),
                        child: const Text('Responder'),
                      ),
                    ],
                  ),
                );
                control.dispose();
                if (texto != null && texto.isNotEmpty) {
                  final miNombre =
                      CrearLogInController.usuario?['nombre'] as String? ?? 'Tú';
                  onResponder(Comentario(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    autor: miNombre,
                    texto: texto,
                    fecha: DateTime.now(),
                  ));
                }
              },
              icon: const Icon(Icons.reply, size: 16),
              label: const Text('Responder'),
            ),
            ...comentario.respuestas.map((r) => Padding(
                  padding: const EdgeInsets.only(left: 18, top: 8),
                  child: Text('${r.autor}: ${r.texto}'),
                )),
          ],
        ),
      ),
    );
  }
}
