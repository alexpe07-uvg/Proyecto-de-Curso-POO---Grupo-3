class VerPerfilModel {
  String nombre;
  String? rutaFotoPerfil;

  VerPerfilModel({
    required this.nombre,
    this.rutaFotoPerfil,
  });

  void cambiarNombre(String nuevoNombre) {
    nombre = nuevoNombre;
  }

  void cambiarFoto(String? nuevaRuta) {
    rutaFotoPerfil = nuevaRuta;
  }
}
