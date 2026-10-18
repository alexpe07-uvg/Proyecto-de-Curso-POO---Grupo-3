import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proyecto_poo/ver_perfil/ver_perfil_controller.dart';
import 'crear_perfil_model.dart';
import 'ver_perfil_controllerUU8.dart';

class VerPerfilView extends StatefulWidget {
  const VerPerfilView({super.key});

  @override
  State<VerPerfilView> createState() => _VerPerfilViewState();
}

class _VerPerfilViewState extends State<VerPerfilView> {
  late VerPerfilModel perfil;
  late VerPerfilController controller;

  bool cargando = true;

  @override
  void initState() {
    super.initState();

    perfil = VerPerfilModel(nombre: "Henry");
    controller = VerPerfilController(perfil);

    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      await controller.cargarPerfil();
    } catch (e) {
      mostrarMensaje("No se pudo cargar el perfil");
    }

    if (!mounted) return;

    setState(() {
      cargando = false;
    });
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> seleccionarFoto() async {
    try {
      bool cambio = await controller.cambiarFotoPerfil();

      if (!mounted) return;

      if (cambio) {
        setState(() {});
        mostrarMensaje("Foto actualizada correctamente");
      }
    } catch (e) {
      mostrarMensaje("No se pudo cambiar la foto");
    }
  }

  Future<void> eliminarFoto() async {
    try {
      await controller.eliminarFotoPerfil();

      if (!mounted) return;

      setState(() {});
      mostrarMensaje("Foto eliminada");
    } catch (e) {
      mostrarMensaje("No se pudo eliminar la foto");
    }
  }

  Future<void> editarNombre() async {
    final texto = TextEditingController(
      text: perfil.nombre,
    );

    final nuevoNombre = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar nombre"),
          content: TextField(
            controller: texto,
            autofocus: true,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: "Nombre",
              prefixIcon: Icon(Icons.person),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final nombre = texto.text.trim();

                if (nombre.isNotEmpty) {
                  Navigator.pop(context, nombre);
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );

    texto.dispose();

    if (nuevoNombre == null || !mounted) return;

    try {
      await controller.cambiarNombre(nuevoNombre);

      if (!mounted) return;

      setState(() {});
      mostrarMensaje("Nombre actualizado");
    } catch (e) {
      mostrarMensaje("No se pudo guardar el nombre");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi perfil"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 35),

                      GestureDetector(
                        onTap: seleccionarFoto,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage:
                              perfil.rutaFotoPerfil != null
                                  ? FileImage(
                                      File(perfil.rutaFotoPerfil!),
                                    )
                                  : null,
                          child: perfil.rutaFotoPerfil == null
                              ? const Icon(
                                  Icons.person,
                                  size: 70,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextButton.icon(
                        onPressed: seleccionarFoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Cambiar foto"),
                      ),

                      if (perfil.rutaFotoPerfil != null)
                        TextButton.icon(
                          onPressed: eliminarFoto,
                          icon: const Icon(Icons.delete),
                          label: const Text("Eliminar foto"),
                        ),

                      const SizedBox(height: 25),

                      Text(
                        perfil.nombre,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton.icon(
                        onPressed: editarNombre,
                        icon: const Icon(Icons.edit),
                        label: const Text("Editar nombre"),
                      ),

                      const SizedBox(height: 35),

                      const Text(
                        "Puedes modificar tu perfil todas las veces que quieras.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
