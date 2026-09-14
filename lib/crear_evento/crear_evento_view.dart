import 'package:flutter/material.dart';
import 'crear_evento_model.dart';
import 'crear_evento_controller.dart';

class CrearEventoView extends StatefulWidget {
  const CrearEventoView({super.key});

  @override
  State<CrearEventoView> createState() => _CrearEventoViewState();
}

class _CrearEventoViewState extends State<CrearEventoView> {
  final CrearEventoController _controller = CrearEventoController();

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _ubicacionCtrl = TextEditingController();
  final TextEditingController _cupoCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();

  String _categoria = 'Deportes y Actividad Física';
  String _dificultad = 'Casual';
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nombreCtrl.dispose();
    _ubicacionCtrl.dispose();
    _cupoCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _enviarFormulario() async {
    if (_nombreCtrl.text.trim().isEmpty ||
        _ubicacionCtrl.text.trim().isEmpty ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final int cupo = int.tryParse(_cupoCtrl.text.trim()) ?? 1;

    final DateTime fechaFinal = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    final nuevoEvento = CrearEventoModel(
      nombre: _nombreCtrl.text.trim(),
      puntoEncuentro: _ubicacionCtrl.text.trim(),
      categoria: _categoria,
      dificultad: _dificultad,
      fechaHora: fechaFinal,
      cupoMaximo: cupo,
      descripcion: _descripcionCtrl.text.trim(),
    );

    _controller.publicarEvento(context, nuevoEvento);
  }

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
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
                  controller: _nombreCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre del evento',
                    hintText: 'Ej. Torneo Relámpago Smash / Chamusca fútbol / etc.',
                    prefixIcon: Icon(Icons.campaign_outlined, color: colorAcento),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Punto de encuentro
                TextField(
                  controller: _ubicacionCtrl,
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
                  initialValue: _categoria,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category_outlined, color: colorAcento),
                    border: const OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Deportes y Actividad Física',
                      child: Text('Deportes y Actividad Física'),
                    ),
                    DropdownMenuItem(
                      value: 'Gaming / Juegos de mesa',
                      child: Text('Gaming / Juegos de mesa'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _categoria = val);
                  },
                ),
                const SizedBox(height: 16),

                // Nivel de Dificultad
                DropdownButtonFormField<String>(
                  initialValue: _dificultad,
                  decoration: InputDecoration(
                    labelText: 'Nivel de Dificultad',
                    prefixIcon: Icon(Icons.signal_cellular_alt, color: colorAcento),
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
                  onChanged: (val) {
                    if (val != null) setState(() => _dificultad = val);
                  },
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: _horaSeleccionada != null
                              ? BorderSide(color: colorAcento)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cupo máximo
                TextField(
                  controller: _cupoCtrl,
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
                  controller: _descripcionCtrl,
                  maxLines: 4,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: 'Descripción o detalles adicionales a tomar en cuenta',
                    hintText: 'Cuéntales de qué trata, qué deben llevar o a quién va dirigido...',
                    alignLabelWithHint: true,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 0,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 56),
                      child: Icon(Icons.format_list_bulleted, color: colorAcento),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón Publicar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _controller.cargando ? null : _enviarFormulario,
                    icon: _controller.cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.add_circle_outline),
                    label: Text(
                      _controller.cargando ? 'Publicando...' : 'Publicar',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón Cancelar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: _controller.cargando ? null : () => _controller.cancelar(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}