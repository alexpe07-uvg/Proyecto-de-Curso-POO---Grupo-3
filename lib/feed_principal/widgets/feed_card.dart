import 'package:flutter/material.dart';
import '../models/item_feed.dart';

class FeedCard extends StatelessWidget {
  final ItemFeed item;

  const FeedCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final esEvento = item.tipo == TipoItem.evento;

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
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      child: Icon(
                        esEvento ? Icons.event : Icons.article,
                        color: Theme.of(context).primaryColor,
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
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    item.categoria,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  backgroundColor: _getColorByCategory(item.categoria),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            if (esEvento) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.orange),
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
                  const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text(
                    item.ubicacion ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColorByCategory(String category) {
    switch (category) {
      case 'Tecnología':
        return Colors.blue;
      case 'Deportes':
        return Colors.green;
      case 'Académico':
        return Colors.purple;
      case 'Social':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}