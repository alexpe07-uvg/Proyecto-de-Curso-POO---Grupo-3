import 'crear_log_in_model.dart';

class CrearLogInController {
  final CrearLogInModel model = CrearLogInModel();

  bool login() {
    return model.email.contains('@') && model.password.length >= 6;
  }

  bool registrar() {
    return model.email.contains('@') &&
        model.password.length >= 6 &&
        model.password == model.confirmPassword;
  }
}