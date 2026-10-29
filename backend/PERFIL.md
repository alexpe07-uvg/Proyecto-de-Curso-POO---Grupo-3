# Perfil persistente

GET /perfil, POST /perfil/nombre, POST /perfil/foto y POST /perfil/foto/eliminar requieren Authorization: Bearer <token>. El usuario se obtiene exclusivamente del token. Correo y carrera no se editan.

El nombre admite 1–100 caracteres. La foto se envía como bytes (application/octet-stream), máximo 5 MB, PNG/JPEG/WebP. Se valida la firma del archivo; no se recodifica la imagen. Los archivos tienen nombres aleatorios y se sirven con nosniff. Las fotos son accesibles mediante su URL para poder mostrarlas como imágenes en web.

MySQL conserva nombre y foto_url en la tabla usuarios existente; no se requiere migración si se utilizó database/instalacion.sql. El archivo se almacena en backend/uploads/perfiles. Configurar PROFILE_UPLOAD_DIR con una ruta absoluta en un volumen persistente en producción; respaldar tanto ese directorio como MySQL. No versionar las imágenes.

Configurar backend/.env tomando .env.example y el .env de Flutter con API_BASE_URL. Instalar dependencias con npm ci y ejecutar npm start. Para imágenes remotas en Flutter web, Image.network usa las restricciones del navegador; el servidor permite orígenes de desarrollo locales.

Los antiguos datos de SharedPreferences no se importan porque no identifican una cuenta. El perfil se consulta al abrirlo; los cambios actualizan la cuenta en memoria y el feed se recarga al volver. No se implementa edición del correo.

Pruebas: `npm test` o `node --test cors-local.test.js perfil.test.js`. Las pruebas del perfil usan MySQL y middleware de sesión simulados, con archivos reales en una carpeta temporal; no sustituyen una prueba con MySQL y un inicio de sesión real.
