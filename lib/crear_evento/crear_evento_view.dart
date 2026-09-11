import 'package:flutter/material.dart';

class CrearEventoView extends StatefulWidget {
  const CrearEventoView({super.key});

  @override
  State<CrearEventoView> createState() => _CrearEventoViewState();
}

class _CrearEventoViewState extends State<CrearEventoView> {
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  Future<void> _abrirSelectorFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2036),
      helpText: 'Día del evento',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _abrirSelectorHora(BuildContext context) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
      helpText: 'Hora del evento',
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
    // Tomamos el color primario configurado en main.dart
    final Color colorAcento = Theme.of(context).colorScheme.primary;

    final String textoFecha = _fechaSeleccionada == null
        ? 'Elegir fecha'
        : '${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/${_fechaSeleccionada!.year}';

    final String textoHora = _horaSeleccionada == null
        ? 'Elegir hora'
        : _horaSeleccionada!.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Nuevo Evento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del evento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Realiza una publicación para conectar con la comunidad del campus!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),

            // Nombre del evento
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del evento',
                hintText: 'Ej. Torneo Relámpago Smash / Chamusca fútbol / etc.',
                prefixIcon: Icon(Icons.campaign_outlined, color: colorAcento),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Ubicación en campus
            TextField(
              decoration: InputDecoration(
                labelText: 'Punto de encuentro',
                hintText: 'Ej. CIT - 313 / Plaza Paiz / Canchas UVG / etc.',
                prefixIcon: Icon(Icons.place_outlined, color: colorAcento),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Categoría
            DropdownButtonFormField<String>(
              initialValue: 'Deportes',
              decoration: InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category_outlined, color: colorAcento),
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Deportes',
                  child: Text('Deportes y Actividad Física'),
                ),
                DropdownMenuItem(
                  value: 'Gaming',
                  child: Text('Gaming / Juegos de mesa'),
                ),
              ],
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),

            // Dificultad
            DropdownButtonFormField<String>(
              initialValue: 'Casual',
              decoration: InputDecoration(
                labelText: 'Nivel de Dificultad',
                prefixIcon: Icon(Icons.speed, color: colorAcento),
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Casual',
                  child: Text('Casual / Para todos los niveles'),
                ),
                DropdownMenuItem(
                  value: 'Intermedio',
                  child: Text('Intermedio / Con algo de experiencia'),
                ),
                DropdownMenuItem(
                  value: 'Avanzado',
                  child: Text('Avanzado / Para usuarios experimentados'),
                ),
              ],
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),

            // Selectores de Fecha y Hora
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirSelectorFecha(context),
                    icon: Icon(
                      Icons.calendar_today,
                      color: _fechaSeleccionada != null ? colorAcento : null,
                      size: 18,
                    ),
                    label: Text(
                      textoFecha,
                      style: TextStyle(
                        color: _fechaSeleccionada != null ? colorAcento : null,
                        fontWeight: _fechaSeleccionada != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: _fechaSeleccionada != null
                          ? BorderSide(color: colorAcento)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirSelectorHora(context),
                    icon: Icon(
                      Icons.access_time,
                      color: _horaSeleccionada != null ? colorAcento : null,
                      size: 18,
                    ),
                    label: Text(
                      textoHora,
                      style: TextStyle(
                        color: _horaSeleccionada != null ? colorAcento : null,
                        fontWeight: _horaSeleccionada != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: _horaSeleccionada != null
                          ? BorderSide(color: colorAcento)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Capacidad
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cupo máximo de personas',
                hintText: 'Ej. 6',
                prefixIcon: Icon(Icons.group_outlined, color: colorAcento),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Descripción
             TextField(
              maxLines: 4,
              textAlignVertical: TextAlignVertical.top, // Asegura que el texto que escribas empiece arriba
              decoration: InputDecoration(
                labelText: 'Descripción o detalles adicionales a tomar en cuenta',
                hintText: 'Cuéntales de qué trata, qué deben llevar o a quién va dirigido...',
                alignLabelWithHint: true, // Mantiene el label arriba
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 0,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 56), // Empuja el icono hacia la parte superior
                  child: Icon(Icons.info_outline, color: colorAcento),
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Botón publicar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  'Publicar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAcento,
                  foregroundColor: Colors.black,
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
                child: const Text('Cancelar', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}