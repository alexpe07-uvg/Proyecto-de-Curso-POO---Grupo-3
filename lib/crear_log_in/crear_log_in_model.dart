class CrearLogInModel {
  String email;
  String password;
  String confirmPassword;
  String alias;
  String carrera;
  String? rutaFotoPerfil;

  CrearLogInModel({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.alias = '',
    this.carrera = '',
    this.rutaFotoPerfil,
  });
}