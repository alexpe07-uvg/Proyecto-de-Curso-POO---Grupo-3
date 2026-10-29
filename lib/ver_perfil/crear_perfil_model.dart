class VerPerfilModel {
  String nombre;
  String correo;
  String carrera;
  String? rutaFotoPerfil;
  VerPerfilModel({
    required this.nombre,
    this.correo = '',
    this.carrera = '',
    this.rutaFotoPerfil,
  });
}
