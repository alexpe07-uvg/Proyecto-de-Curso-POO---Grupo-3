import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../crear_log_in/crear_log_in_controller.dart';
import '../models/item_feed.dart';

class FeedCard extends StatefulWidget {
  final ItemFeed item;
  const FeedCard({super.key, required this.item});
  @override State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  late final List<Comentario> comentarios = List.from(widget.item.comentarios);
  bool inscrito = false;
  Future<void> _eliminarEvento() async {
    final confirmar = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Eliminar evento'),
      content: const Text('¿Seguro que deseas eliminar este evento?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
      ],
    ));
    if (confirmar != true || !mounted) return;
    final token = CrearLogInController.token;
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (token == null || baseUrl.isEmpty) return;
    final respuesta = await http.delete(Uri.parse('$baseUrl/eventos/${widget.item.id}'), headers: {'Authorization': 'Bearer $token'});
    if (!mounted) return;
    if (respuesta.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(datos['error']?.toString() ?? 'No se pudo eliminar')));
    }
  }
  @override Widget build(BuildContext context) {
    final item = widget.item; final evento = item.tipo == TipoItem.evento;
    return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(child: Icon(evento ? Icons.event : Icons.article)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.autor, style: const TextStyle(fontWeight: FontWeight.bold)), Text(evento ? 'Evento' : 'Publicación')])), Chip(label: Text(item.categoria))]),
      const SizedBox(height: 12), Text(item.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(item.descripcion),
      if (evento) ...[
        const Divider(height: 24),
        Text('🕒 ${_formatearFecha(item.fechaEvento)}'),
        Text('📍 ${item.ubicacion ?? ''}'),
        if (item.dificultad != null) Text('⚡ Dificultad: ${item.dificultad}'),
        if (item.esCreador) TextButton.icon(onPressed: _eliminarEvento, icon: const Icon(Icons.delete_outline, color: Colors.red), label: const Text('Eliminar evento')),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton.icon(onPressed: () => _abrirComentarios(context), icon: const Icon(Icons.forum_outlined), label: Text('Comentarios (${comentarios.length})')),
          const SizedBox(width: 8),
          FilledButton.icon(onPressed: () => setState(() => inscrito = !inscrito), icon: Icon(inscrito ? Icons.check : Icons.person_add_alt_1), label: Text(inscrito ? 'Inscrito' : 'Inscribirme')),
        ]),
      ],
    ])));
  }
  String _formatearFecha(String? valor) {
    final fecha = DateTime.tryParse(valor ?? '');
    if (fecha == null) return valor ?? '';
    final local = fecha.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} - ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
  void _abrirComentarios(BuildContext context) => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _ComentariosSheet(comentarios: comentarios, onChanged: () => setState(() {})));
}

class _ComentariosSheet extends StatefulWidget {
  final List<Comentario> comentarios; final VoidCallback onChanged;
  const _ComentariosSheet({required this.comentarios, required this.onChanged});
  @override State<_ComentariosSheet> createState() => _ComentariosSheetState();
}
class _ComentariosSheetState extends State<_ComentariosSheet> {
  final input = TextEditingController();
  void agregar() { final t = input.text.trim(); if (t.isEmpty) return; widget.comentarios.add(Comentario(autor: 'Tú', texto: t)); input.clear(); widget.onChanged(); setState(() {}); }
  @override void dispose() { input.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => SafeArea(child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: SizedBox(height: MediaQuery.of(context).size.height * .7, child: Column(children: [const Padding(padding: EdgeInsets.all(16), child: Text('Comentarios del evento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Expanded(child: widget.comentarios.isEmpty ? const Center(child: Text('Aún no hay comentarios.')) : ListView(children: widget.comentarios.map((c) => _ComentarioTile(comentario: c, onChanged: () { widget.onChanged(); setState(() {}); })).toList())), Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: TextField(controller: input, onSubmitted: (_) => agregar(), decoration: const InputDecoration(hintText: 'Escribe un comentario...', border: OutlineInputBorder()))), IconButton(onPressed: agregar, icon: const Icon(Icons.send))]))])));
}
class _ComentarioTile extends StatelessWidget {
  final Comentario comentario; final VoidCallback onChanged;
  const _ComentarioTile({required this.comentario, required this.onChanged});
  Future<void> responder(BuildContext context) async { final c = TextEditingController(); final t = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Responder comentario'), content: TextField(controller: c), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Responder'))])); c.dispose(); if (t != null && t.isNotEmpty) { comentario.respuestas.add(Comentario(autor: 'Tú', texto: t)); onChanged(); } }
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(comentario.autor, style: const TextStyle(fontWeight: FontWeight.bold)), Text(comentario.texto), TextButton.icon(onPressed: () => responder(context), icon: const Icon(Icons.reply, size: 16), label: const Text('Responder')), ...comentario.respuestas.map((r) => Padding(padding: const EdgeInsets.only(left: 18), child: Text('${r.autor}: ${r.texto}')))])));
}
