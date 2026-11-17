import 'package:flutter/material.dart';
import '../../theme/app_animations.dart';

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
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final fondoSeleccionado = esOscuro
        ? const Color(0xFF8CE029)
        : const Color(0xFF165B29);
    final textoSeleccionado = esOscuro
        ? const Color(0xFF12361B)
        : Colors.white;
    final fondoInactivo = esOscuro
        ? const Color(0xFF15361D)
        : const Color(0xFFE7F9CE);
    final textoInactivo = esOscuro
        ? const Color(0xFFC8F299)
        : const Color(0xFF165B29);
    final bordeChip = esOscuro
        ? const Color(0xFF286335)
        : const Color(0xFF72BF1D);

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
            child: ReboteAlPresionar(
              escalaPresionado: 0.9,
              child: AnimatedScale(
                scale: isSelected ? 1.04 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: ChoiceChip(
                  showCheckmark: false,
                  side: BorderSide(color: bordeChip, width: 1.1),
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? textoSeleccionado : textoInactivo,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: fondoSeleccionado,
                  backgroundColor: fondoInactivo,
                  onSelected: (_) => onSelectCategory(cat),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}