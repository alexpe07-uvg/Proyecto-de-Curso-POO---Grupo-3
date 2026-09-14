import 'dart:io';
import 'package:flutter/material.dart';

import 'crear_perfil_model.dart';
import 'ver_perfil_controller.dart';

class VerPerfilView extends StatefulWidget {
  const VerPerfilView({
    super.key,
  });

  @override
  State<VerPerfilView> createState() => _VerPerfilViewState();
}

class _VerPerfilViewState extends State<VerPerfilView> {
  late VerPerfilModel perfil;
  late VerPerfilController controller;

  @override
  void initState() {
    super.initState();

    perfil = VerPerfilModel(
      nombre: "Henry",
    );

    controller = VerPerfilController(perfil);
  }

  Future<void> seleccionarFoto() async {
    bool cambio = await controller.cambiarFotoPerfil();

    if (cambio) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi perfil"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            GestureDetector(
              onTap: seleccionarFoto,

              child: CircleAvatar(
                radius: 70,

                backgroundImage: perfil.rutaFotoPerfil != null
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

            const SizedBox(height: 20),

            Text(
              perfil.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: seleccionarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                "Cambiar foto de perfil",
              ),
            ),
          ],
        ),
      ),
    );
  }
}