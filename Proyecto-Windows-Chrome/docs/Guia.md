# Guía del proyecto: Windows y Chrome en macOS

## Qué contiene esta versión
Flutter → API Node/Express → MySQL 8.4. Cada integrante tendrá una base independiente en su computadora, cada uno de ustedes debe hacer su instalación local, los datos NO se va a sincronizar en lo que hagan. En el ZIP ya está el código y configuración que trajabé, favor leenla con mucho detalle, si hay cosas que no entienden, favor verlo con la IA, pero pidan bien una explicación de "por qué" de esas lineas de codigo. Los cambios son locales y no se publicaron en GitHub, eso es algo que ustedes deben hacer como GRUPO de trabajo.

## Windows: instalación
1. Instalar Node **24 LTS** con el instalador .msi de https://nodejs.org/en/download. No seleccionar herramientas adicionales de compilación para este backend.
2. Instalar MySQL Community Server **8.4** desde https://dev.mysql.com/downloads/mysql/ y completar su configuración: puerto 3306, servicio iniciado y contraseña de root propia. Workbench es opcional, yo lo dejaría para futuros proyectos.
3. Instalar Flutter siguiendo https://docs.flutter.dev/install y añadir su carpeta bin al PATH. El proyecto exige Dart ^3.13.2: comprobar que el Flutter elegido lo incluya con `flutter --version`.
 ----- En teoría esto TODOS ya lo tienen instalado en su maquina.
4. Instalar Chrome. 
 ----- Asumo que TODOS usamos Chrome
Para app de escritorio, instalar además **Visual Studio**, con **Desktop development with C++** (Visual Studio Code no lo reemplaza).
5. Extraer el proyecto en una ruta sencilla, por ejemplo C:\Proyectos\comunidad-campus. Abrir una terminal allí.

``` ** Esto es en powershell:
node --version
npm.cmd --version
flutter --version
flutter doctor -v
flutter devices

``` ---- Esto tambien deberían de SABERLO porque en teoria ya trabajaron en grupo, pero es para validar que todo ambiente esté SANO
```
Usamos npm.cmd en PowerShell para evitar bloqueos de ejecución de npm.ps1 sin cambiar políticas del sistema.

## Crear la base en Windows (una sola vez)
En la raíz del proyecto, iniciar el cliente. Si mysql no está en PATH:
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root -p
```
Dentro de mysql>, usando la ruta real con barras /:
```sql
SOURCE C:/Proyectos/comunidad-campus/database/instalacion.sql;
CREATE USER 'campus_app'@'127.0.0.1' IDENTIFIED BY 'REEMPLAZAR_POR_CLAVE_PROPIA';
GRANT SELECT, INSERT, UPDATE, DELETE ON comunidad_campus.* TO 'campus_app'@'127.0.0.1';
SHOW TABLES FROM comunidad_campus;
EXIT;
```
El archivo instalacion.sql se usa en una base nueva; PARA TODOS ES UNA BASE DE DATOS NUEVA. 


## Configurar y arrancar la API en Windows
```powershell
cd backend
Copy-Item .env.example .env
npm.cmd ci
node -e "console.log(require('node:crypto').randomBytes(32).toString('hex'))"
```
Abrir .env en el editor, conservar los valores de ejemplo y completar DB_PASSWORD con la contraseña de campus_app, y JWT_SECRET con el resultado generado. Si la contraseña contiene #, encerrar su valor entre comillas. La clave JWT es exclusiva del backend; no copiarla a Flutter. No compartir .env.
```powershell
npm.cmd start
```
Dejar esta terminal abierta. Abrir http://127.0.0.1:3000/categorias: debe mostrar las dos categorías. La ruta / no tiene página configurada.

## Ejecutar Flutter en Windows
En OTRA terminal, desde la raíz:
```powershell
flutter pub get
flutter run -d chrome --web-port=5173 --dart-define=API_BASE_URL=http://127.0.0.1:3000
```
O para escritorio:
```powershell
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:3000
```
El backend permite los orígenes http://localhost:5173 y http://127.0.0.1:5173. Mantener ese puerto en Chrome. Un cambio de puerto requiere actualizar backend/cors-local.js y reiniciar la API. CORS permite al navegador leer respuestas; la autenticación sigue dependiendo del token.

Investiguen de CORS, pero básicamente es una barrera segura para no permitir que otras entidades consuman un API

## Prueba de aceptación
1. Crear una cuenta ficticia con alias, carrera y contraseña de al menos ocho caracteres.
2. Confirmar que contraseña incorrecta impide entrar y correcta permite entrar.
3. Publicar evento futuro, con cupo positivo: aparece al volver al feed.
4. Cerrar/reabrir la app, iniciar sesión y comprobar persistencia.
5. Detener la API: aparece error; arrancarla y reintentar: se recupera.
Cada navegador/app tiene sesión en memoria; recargar Chrome requiere volver a iniciar sesión. Los tokens expiran a las dos horas.

## Fuentes de consulta para el proyecto
- https://docs.flutter.dev/platform-integration/windows/setup
- https://docs.flutter.dev/platform-integration/web/building
- https://nodejs.org/en/download
- https://dev.mysql.com/doc/refman/8.4/en/windows-installation.html
