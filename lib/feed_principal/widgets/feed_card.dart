import 'package:flutter/material.dart';
import '../models/item_feed.dart';

class FeedCard extends StatefulWidget {
  final ItemFeed item;

  const FeedCard({super.key, required this.item});

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  late final List<Comentario> _comentarios;

  @override
  void initState() {
    super.initState();
    _comentarios = List<Comentario>.from(widget.item.comentarios);
  }

  Future<void> _abrirComentarios() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ComentariosSheet(comentarios: _comentarios, onAgregar: (c) => setState(() => _comentarios.add(c))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final esEvento = item.tipo == TipoItem.evento;
    final esquema = Theme.of(context).colorScheme;

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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _abrirComentarios,
                  icon: const Icon(Icons.forum_outlined, size: 18),
                  label: Text('Comentarios (${_comentarios.length})'),
                ),
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
  const _ComentariosSheet({required this.comentarios, required this.onAgregar});
  @override
  State<_ComentariosSheet> createState() => _ComentariosSheetState();
}

class _ComentariosSheetState extends State<_ComentariosSheet> {
  final _controlador = TextEditingController();
  void _publicar() {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;
    widget.onAgregar(Comentario(id: DateTime.now().microsecondsSinceEpoch.toString(), autor: 'Tú', texto: texto, fecha: DateTime.now()));
    _controlador.clear();
    setState(() {});
  }
  @override
  void dispose() { _controlador.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .72,
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Comentarios del evento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const Divider(height: 1),
          Expanded(child: widget.comentarios.isEmpty ? const Center(child: Text('Aún no hay comentarios. ¡Sé el primero!')) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: widget.comentarios.length, itemBuilder: (_, i) => _ComentarioTile(comentario: widget.comentarios[i], onResponder: (respuesta) => setState(() => widget.comentarios[i].respuestas.add(respuesta)))),
          Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: TextField(controller: _controlador, onSubmitted: (_) => _publicar(), decoration: const InputDecoration(hintText: 'Escribe un comentario...', border: OutlineInputBorder()))), const SizedBox(width: 8), IconButton(onPressed: _publicar, icon: const Icon(Icons.send))])),
        ]),
      ),
    ),
  );
}

class _ComentarioTile extends StatelessWidget {
  final Comentario comentario;
  final ValueChanged<Comentario> onResponder;
  const _ComentarioTile({required this.comentario, required this.onResponder});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(comentario.autor, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(comentario.texto), TextButton.icon(onPressed: () async { final control = TextEditingController(); final texto = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Responder comentario'), content: TextField(controller: control, autofocus: true, decoration: const InputDecoration(hintText: 'Escribe tu respuesta')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, control.text.trim()), child: const Text('Responder'))])); control.dispose(); if (texto != null && texto.isNotEmpty) onResponder(Comentario(id: DateTime.now().microsecondsSinceEpoch.toString(), autor: 'Tú', texto: texto, fecha: DateTime.now())); }, icon: const Icon(Icons.reply, size: 16), label: const Text('Responder')), ...comentario.respuestas.map((r) => Padding(padding: const EdgeInsets.only(left: 18, top: 8), child: Text('${r.autor}: ${r.texto}')))])));
}
