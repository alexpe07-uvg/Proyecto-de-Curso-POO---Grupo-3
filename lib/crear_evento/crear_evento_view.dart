import 'package:flutter/material.dart';

class CrearEventoUVGPage extends StatefulWidget {
  const CrearEventoUVGPage({super.key});

  @override
  State<CrearEventoUVGPage> createState() => _CrearEventoUVGPageState();
}

class _CrearEventoUVGPageState extends State<CrearEventoUVGPage> {
  // Variables para almacenar la selección
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  // Componente nativo para fecha
  Future<void> _abrirSelectorFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      helpText: 'Selecciona el día del evento',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  // Componente nativo para hora
  Future<void> _abrirSelectorHora(BuildContext context) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
      helpText: 'Selecciona la hora del evento',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );

    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeUVG = Color(0xFF006837);

    // Formateo visual del texto de los botones
    final String textoFecha = _fechaSeleccionada == null
        ? 'Elegir fecha'
        : '${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/${_fechaSeleccionada!.year}';

    final String textoHora = _horaSeleccionada == null
        ? 'Elegir hora'
        : _horaSeleccionada!.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UVGMatches - Crear Evento',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: verdeUVG,
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos de la actividad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Publica un evento para conectar con la comunidad del campus.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Nombre del evento
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del evento',
                hintText: 'Ej. Torneo Relámpago Smash / Tarde de estudio',
                prefixIcon: Icon(Icons.campaign_outlined, color: verdeUVG),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Ubicación en campus
            const TextField(
              decoration: InputDecoration(
                labelText: 'Lugar en campus',
                hintText: 'Ej. Edificio CIT - Nivel 3, Plaza Paiz, Cafetería',
                prefixIcon: Icon(Icons.place_outlined, color: verdeUVG),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Categoría
            DropdownButtonFormField<String>(
              value: 'Deportes',
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category_outlined, color: verdeUVG),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Deportes', child: Text('Deportes y Actividad Física')),
                DropdownMenuItem(value: 'Estudio', child: Text('Grupo de Estudio / Académico')),
                DropdownMenuItem(value: 'Gaming', child: Text('Gaming / Juegos de mesa')),
                DropdownMenuItem(value: 'Social', child: Text('Social / Convivio')),
              ],
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),

            // Selectores nativos de Fecha y Hora
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirSelectorFecha(context),
                    icon: Icon(
                      Icons.calendar_today,
                      color: _fechaSeleccionada != null ? verdeUVG : Colors.grey[700],
                      size: 18,
                    ),
                    label: Text(
                      textoFecha,
                      style: TextStyle(
                        color: _fechaSeleccionada != null ? verdeUVG : Colors.black87,
                        fontWeight: _fechaSeleccionada != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: _fechaSeleccionada != null ? verdeUVG : Colors.grey[400]!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirSelectorHora(context),
                    icon: Icon(
                      Icons.access_time,
                      color: _horaSeleccionada != null ? verdeUVG : Colors.grey[700],
                      size: 18,
                    ),
                    label: Text(
                      textoHora,
                      style: TextStyle(
                        color: _horaSeleccionada != null ? verdeUVG : Colors.black87,
                        fontWeight: _horaSeleccionada != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: _horaSeleccionada != null ? verdeUVG : Colors.grey[400]!,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Capacidad
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cupo máximo de personas',
                hintText: 'Ej. 6',
                prefixIcon: Icon(Icons.group_outlined, color: verdeUVG),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Descripción
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción o detalles',
                hintText: 'Cuéntales de qué trata, qué deben llevar o a quién va dirigido...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Botón publicar (maqueta)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text(
                  'Publicar en UVGMatches',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: verdeUVG,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón cancelar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}