import 'package:image_picker/image_picker.dart';
import 'crear_perfil_model.dart';

class VerPerfilController {
  final VerPerfilModel perfil;

  final ImagePicker _imagePicker = ImagePicker();

  VerPerfilController(this.perfil);

  Future<bool> cambiarFotoPerfil() async {
    final XFile? imagen = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagen != null) {
      perfil.rutaFotoPerfil = imagen.path;
      return true;
    }

    return false;
  }
}