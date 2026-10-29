import 'package:flutter/material.dart';

import '../../ver_perfil/ver_perfil_view.dart';
import '../../crear_evento/crear_evento_view.dart';
import '../models/item_feed.dart';
import '../widgets/category_filter.dart';
import '../widgets/feed_card.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../crear_log_in/crear_log_in_controller.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _categoriaSeleccionada = 'Todos';

  List<ItemFeed> _items = [];
  bool _cargandoFeed = true;
  String? _errorFeed;

  Future<void> _cargarFeed() async {
    if (!mounted) return;

    setState(() {
      _cargandoFeed = true;
      _errorFeed = null;
    });

    try {
      final token = CrearLogInController.token;

      if (token == null) {
        throw Exception('Debes iniciar sesión nuevamente.');
      }

      final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

      final respuesta = await http
          .get(
            Uri.parse('$baseUrl/feed'),
            headers: {
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': 'true',
            },
          )
          .timeout(const Duration(seconds: 10));

      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

      if (respuesta.statusCode != 200) {
        throw Exception(
          (datos as Map<String, dynamic>)['error'] ??
              'No se pudieron cargar las publicaciones.',
        );
      }

      final items = (datos as List<dynamic>)
          .map((dato) => ItemFeed.fromJson(dato as Map<String, dynamic>))
          .toList();

      if (!mounted) return;

      setState(() {
        _items = items;
        _cargandoFeed = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _cargandoFeed = false;
        _errorFeed = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<String> categorias = ['Todos'];
  bool _cargandoCategorias = true;
  String? _errorCategorias;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarFeed();
  }

  Future<void> _cargarCategorias() async {
    setState(() {
      _cargandoCategorias = true;
      _errorCategorias = null;
    });

    try {
      final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

      final respuesta = await http
          .get(Uri.parse('$baseUrl/categorias'))
          .timeout(const Duration(seconds: 10));

      if (respuesta.statusCode != 200) {
        throw Exception('Respuesta HTTP ${respuesta.statusCode}');
      }

      final datos =
          jsonDecode(utf8.decode(respuesta.bodyBytes)) as List<dynamic>;

      final nombres = datos
          .map((dato) => (dato as Map<String, dynamic>)['nombre'] as String)
          .toList();

      if (!mounted) return;

      setState(() {
        categorias = ['Todos', ...nombres];
        if (!categorias.contains(_categoriaSeleccionada)) {
          _categoriaSeleccionada = 'Todos';
        }
        _cargandoCategorias = false;
      });
    } catch (error) {
      debugPrint('Error cargando categorías: $error');

      if (!mounted) return;

      setState(() {
        _cargandoCategorias = false;
        _errorCategorias = 'No se pudieron cargar las categorías.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ItemFeed> itemsFiltrados = _categoriaSeleccionada == 'Todos'
        ? _items
        : _items
              .where((item) => item.categoria == _categoriaSeleccionada)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Principal de Publicaciones'),
        centerTitle: true,
        elevation: 1,

        // ===== BOTÓN DE PERFIL AGREGADO =====
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VerPerfilView()),
              );
              if (mounted) await _cargarFeed();
            },
          ),
        ],

        // ===================================
      ),
      body: Column(
        children: [
          if (_cargandoCategorias) const LinearProgressIndicator(),

          if (_errorCategorias != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: Text(_errorCategorias!)),
                  TextButton(
                    onPressed: _cargarCategorias,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
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
            child: _cargandoFeed
                ? const Center(child: CircularProgressIndicator())
                : _errorFeed != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_errorFeed!),
                          TextButton(
                            onPressed: _cargarFeed,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : itemsFiltrados.isEmpty
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        tooltip: 'Crear evento',
        child: const Icon(Icons.add),
        onPressed: () async {
          final guardado = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const CrearEventoView()),
          );

          if (!mounted) return;

          if (guardado == true) {
            await _cargarFeed();
          }
        },
      ),
    );
  }
}
