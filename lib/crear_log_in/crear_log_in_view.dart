import 'package:flutter/material.dart';
import 'crear_log_in_controller.dart';

class CrearLogInView extends StatefulWidget {
  const CrearLogInView({super.key});

  @override
  State<CrearLogInView> createState() => _CrearLogInViewState();
}

class _CrearLogInViewState extends State<CrearLogInView> {
  final CrearLogInController _controller = CrearLogInController();
  final _formKey = GlobalKey<FormState>();

  bool isLoginMode = true; 

  final List<String> carrerasUVG = [
    'Ingeniería Biomédica',
    'Ingeniería Biotecnológica',
    'Ingeniería Civil',
    'Ingeniería Civil Ambiental',
    'Ingeniería Civil Arquitectónica',
    'Ingeniería de Alimentos',
    'Ingeniería en Ciencia de los Datos',
    'Ingeniería en Ciencias de la Computación y Tecnologías de la Información',
    'Ingeniería en Electrónica',
    'Ingeniería Industrial',
    'Ingeniería Mecánica',
    'Ingeniería Mecánica Industrial',
    'Ingeniería Mecatrónica',
    'Ingeniería Química',
    'Licenciatura en Arqueología',
    'Licenciatura en Biología',
    'Licenciatura en Biotecnología Molecular',
    'Licenciatura en Comunicación Estratégica y Publicidad',
    'Licenciatura en Física',
    'Licenciatura en Matemática',
    'Licenciatura en Nutrición',
    'Licenciatura en Química',
    'Licenciatura en Química Farmacéutica',
    'Licenciatura en Antropología',
    'Licenciatura en Educación con Especialidad en Educación Primaria',
    'Licenciatura en Educación Inclusiva',
    'Licenciatura en Psicología',
    'Licenciatura en Administración de Empresas',
    'Licenciatura en Business Analytics y Gestión de Datos',
    'Licenciatura en Marketing y Transformación Digital',
    'Licenciatura en Relaciones Internacionales',
    'Licenciatura en Arquitectura',
    'Licenciatura en Diseño de Producto e Innovación',
    'Licenciatura en Composición Musical y Producción de Audio',
    'Licenciatura en Administración de Empresas de Hospitalidad y Turismo'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Escudo oficial de la Universidad del Valle de Guatemala reescalado
              Image.network(
                'https://www.uvg.edu.gt/wp-content/uploads/UVG-logo-2022.png',
                height: 110,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.school, size: 80, color: Color.fromARGB(255, 7, 204, 37));
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'UVG MATCHES',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color.fromARGB(255, 7, 204, 37),
                ),
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          isLoginMode ? 'Iniciar Sesión' : 'Crear Cuenta',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Correo Institucional',
                            prefixIcon: Icon(Icons.email),
                          ),
                          onChanged: (val) => _controller.model.email = val,
                          validator: (val) => (val == null || !val.contains('@')) ? 'Correo inválido' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          onChanged: (val) => _controller.model.password = val,
                          validator: (val) => (val == null || val.length < 6) ? 'Mínimo 6 caracteres' : null,
                        ),
                        const SizedBox(height: 16),

                        if (!isLoginMode) ...[
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar Contraseña',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            onChanged: (val) => _controller.model.confirmPassword = val,
                            validator: (val) => (val != _controller.model.password) ? 'Las contraseñas no coinciden' : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo o Alias',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            onChanged: (val) => _controller.model.alias = val,
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Carrera',
                              prefixIcon: Icon(Icons.school),
                            ),
                            items: carrerasUVG.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (val) => _controller.model.carrera = val ?? '',
                          ),
                          const SizedBox(height: 20),

                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: Color(0xFF2E2E2E),
                                child: Icon(Icons.person, size: 50, color: Colors.white70),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color.fromARGB(255, 7, 204, 37),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.add_a_photo, size: 16, color: Colors.black),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Selector de archivos (Simulación visual)')),
                                      );
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final msg = isLoginMode ? '¡Inicio de sesión simulado!' : '¡Registro completado!';
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                              }
                            },
                            child: Text(
                              isLoginMode ? 'Iniciar Sesión' : 'Registrarme',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () => setState(() => isLoginMode = !isLoginMode),
                          child: Text(
                            isLoginMode ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión',
                            style: const TextStyle(color: Color.fromARGB(255, 7, 204, 37)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}