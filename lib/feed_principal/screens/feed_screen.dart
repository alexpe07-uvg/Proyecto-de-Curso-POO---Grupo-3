import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/item_feed.dart';
import '../widgets/category_filter.dart';
import '../widgets/feed_card.dart';
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _categoriaSeleccionada = 'Todos';

  final List<String> categorias = [
  'Todos',
  'Deportes y Actividad Física',
  'Gaming / Juegos de mesa',
  ];

  @override
  Widget build(BuildContext context) {
    final List<ItemFeed> itemsFiltrados = _categoriaSeleccionada == 'Todos'
        ? mockItemsFeed
        : mockItemsFeed.where((item) => item.categoria == _categoriaSeleccionada).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Principal de Publicaciones'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          CategoryFilter(
            categorias: categorias,
            categoriaSeleccionada: _categoriaSeleccionada,
            onSelectCategory: (nuevaCategoria) {
              setState(() {
                _categoriaSeleccionada = nuevaCategoria;
              });
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: itemsFiltrados.isEmpty
                ? const Center(
                    child: Text('No hay publicaciones en esta categoría.'),
                  )
                : ListView.builder(
                    itemCount: itemsFiltrados.length,
                    itemBuilder: (context, index) {
                      return FeedCard(item: itemsFiltrados[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add, color: Colors.black),
      onPressed: () async {
      // Navega hacia la pantalla de Crear Evento
      final nuevoEvento = await Navigator.pushNamed(context, '/crear_evento');
    
    // Si la pantalla retorna un nuevo evento, lo insertamos en la lista
      if (nuevoEvento != null && nuevoEvento is ItemFeed) {
      setState(() {
        mockItemsFeed.insert(0, nuevoEvento);
            });
          }
        },
      ),
    );
  }
}