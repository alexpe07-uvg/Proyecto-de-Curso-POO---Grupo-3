import 'package:flutter/material.dart';

import 'crear_perfil_model.dart';
import 'ver_perfil_controller.dart';

class VerPerfilView extends StatefulWidget {
  const VerPerfilView({super.key});
  @override
  State<VerPerfilView> createState() => _VerPerfilViewState();
}

class _VerPerfilViewState extends State<VerPerfilView> {
  final perfil = VerPerfilModel(nombre: '');
  late final controller = VerPerfilController(perfil);
  bool cargando = true;
  bool guardando = false;
  String? error;
  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  String mensaje(Object e) => e.toString().replaceFirst('Exception: ', '');
  Future<void> cargarDatos() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      await controller.cargarPerfil();
    } catch (e) {
      if (mounted) error = mensaje(e);
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> guardar(Future<void> Function() accion, String exito) async {
    if (guardando) return;
    setState(() => guardando = true);
    try {
      await accion();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exito)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mensaje(e))));
      }
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  Future<void> seleccionarFoto() async {
    setState(() => guardando = true);
    try {
      final bytes = await controller.seleccionarFoto();
      if (bytes == null || !mounted) return;
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Actualizar fotografía'),
          content: Image.memory(
            bytes,
            width: 240,
            height: 240,
            fit: BoxFit.contain,
            errorBuilder: (_, error, stack) => const Text(
              'No se pudo previsualizar la imagen. Usa PNG, JPEG o WebP.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
      if (confirmar == true) {
        await controller.guardarFoto(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Foto actualizada')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mensaje(e))));
      }
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  Future<void> editarNombre() async {
    String texto = perfil.nombre;
    final form = GlobalKey<FormState>();
    final nombre = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre'),
        content: Form(
          key: form,
          child: TextFormField(
            initialValue: perfil.nombre,
            onChanged: (valor) => texto = valor,
            autofocus: true,
            maxLength: 100,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (valor) =>
                (valor ?? '').trim().isEmpty ? 'Escribe tu nombre' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, texto.trim());
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nombre != null && mounted) {
      await guardar(
        () => controller.cambiarNombre(nombre),
        'Nombre actualizado',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !guardando,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mi perfil')),
        body: cargando
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error!),
                    TextButton(
                      onPressed: cargarDatos,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (guardando) const LinearProgressIndicator(),
                        const SizedBox(height: 24),
                        ClipOval(
                          child: perfil.rutaFotoPerfil == null
                              ? const CircleAvatar(
                                  radius: 70,
                                  child: Icon(Icons.person, size: 70),
                                )
                              : Image.network(
                                  perfil.rutaFotoPerfil!,
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  headers: const {
                                    'ngrok-skip-browser-warning': 'true',
                                  },
                                  errorBuilder: (_, error, stack) =>
                                      const CircleAvatar(
                                        radius: 70,
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 60,
                                        ),
                                      ),
                                ),
                        ),
                        TextButton.icon(
                          onPressed: guardando ? null : seleccionarFoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Cambiar foto'),
                        ),
                        if (perfil.rutaFotoPerfil != null)
                          TextButton.icon(
                            onPressed: guardando
                                ? null
                                : () => guardar(
                                    controller.eliminarFotoPerfil,
                                    'Foto eliminada',
                                  ),
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar foto'),
                          ),
                        const SizedBox(height: 24),
                        Text(
                          perfil.nombre,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        ElevatedButton.icon(
                          onPressed: guardando ? null : editarNombre,
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar nombre'),
                        ),
                        const SizedBox(height: 24),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Correo institucional'),
                          subtitle: Text(perfil.correo),
                        ),
                        ListTile(
                          leading: const Icon(Icons.school),
                          title: const Text('Carrera'),
                          subtitle: Text(perfil.carrera),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
