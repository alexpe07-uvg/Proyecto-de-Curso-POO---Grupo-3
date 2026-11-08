import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../crear_log_in/crear_log_in_controller.dart';
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
  int get _cupoMaximo => widget.item.cupoMaximo ?? 10;

  @override
  void initState() {
    super.initState();
    _comentarios = List<Comentario>.from(widget.item.comentarios);
    _cargarDatosPersistentes();
  }

  Future<void> _cargarDatosPersistentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _inscrito
                ? '¡Te has inscrito a ${widget.item.titulo}!'
                : 'Has cancelado tu inscripción.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _abrirComentarios() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ComentariosSheet(
        comentarios: _comentarios,
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
    final miNombre = CrearLogInController.usuario?['nombre'] as String?;
    final esOrganizador = miNombre != null &&
        miNombre.trim().toLowerCase() == item.autor.trim().toLowerCase();
    final cupoLleno = _cupoOcupado >= _cupoMaximo;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    item.fechaEvento ?? '',
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
                        ],
                      ),
                    )
                  else if (_inscrito)
                    OutlinedButton.icon(
                      onPressed: _toggleInscripcion,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Inscrito'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: esquema.primary,
                        side: BorderSide(color: esquema.primary),
                      ),
                    )
                  else if (cupoLleno)
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.block, size: 18),
                      label: const Text('Cupo lleno'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _toggleInscripcion,
                      icon: const Icon(Icons.how_to_reg, size: 18),
                      label: const Text('Inscribirme'),
                    ),
                  TextButton.icon(
                    onPressed: _abrirComentarios,
                    icon: const Icon(Icons.forum_outlined, size: 18),
                    label: Text('Comentarios (${_comentarios.length})'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComentariosSheet extends StatefulWidget {
  final List<Comentario> comentarios;
  final ValueChanged<Comentario> onAgregar;
  final VoidCallback onGuardar;

  const _ComentariosSheet({
    required this.comentarios,
    required this.onAgregar,
    required this.onGuardar,
  });

  @override
  State<_ComentariosSheet> createState() => _ComentariosSheetState();
}

class _ComentariosSheetState extends State<_ComentariosSheet> {
  final _controlador = TextEditingController();

  void _publicar() {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;

    final miNombre =
        CrearLogInController.usuario?['nombre'] as String? ?? 'Tú';

    widget.onAgregar(Comentario(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      autor: miNombre,
      texto: texto,
      fecha: DateTime.now(),
    ));
    _controlador.clear();
    setState(() {});
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
                  child: widget.comentarios.isEmpty
                      ? const Center(
                          child:
                              Text('Aún no hay comentarios. ¡Sé el primero!'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: widget.comentarios.length,
                          itemBuilder: (_, i) => _ComentarioTile(
                            comentario: widget.comentarios[i],
                            onResponder: (respuesta) => setState(() {
                              widget.comentarios[i].respuestas.add(respuesta);
                              widget.onGuardar();
                            }),
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
                        onPressed: _publicar,
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
