import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categorias;
  final String categoriaSeleccionada;
  final Function(String) onSelectCategory;

  const CategoryFilter({
    super.key,
    required this.categorias,
    required this.categoriaSeleccionada,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final cat = categorias[index];
          final isSelected = cat == categoriaSeleccionada;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey[200],
              onSelected: (_) => onSelectCategory(cat),
            ),
          );
        },
      ),
    );
  }
}