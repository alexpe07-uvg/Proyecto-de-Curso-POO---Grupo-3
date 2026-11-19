# 🎮⚽ UVG Matches — Proyecto POO 2026

Aplicación móvil y web desarrollada en **Flutter** para conectar a la comunidad estudiantil de la **Universidad del Valle de Guatemala (UVG)** mediante la creación, descubrimiento y gestión de eventos deportivos, videojuegos y juegos de mesa dentro del campus.

> **Materia:** Programación Orientada a Objetos  
> **Universidad:** Universidad del Valle de Guatemala  
> **Ciclo:** 2026  

---

## 👥 Equipo de Desarrollo

| Nombre | Rol |
| :--- | :--- |
| **Mario Pellecer** | Desarrollador |
| **Otto de León** | Desarrollador |
| **Henry Donis** | Desarrollador |
| **Santiago Martínez** | Desarrollador |

---

## 📖 Funcionalidades del Sistema

- 🔐 **Autenticación Institucional:** Registro e inicio de sesión restringido a correos `@uvg.edu.gt` con contraseñas encriptadas y sesiones persistentes vía JWT.
- 🏟️ **Gestión y Creación de Eventos:** Publicación de encuentros deportivos, videojuegos o juegos de mesa con control de cupos, dificultad (Casual, Intermedio, Avanzado), fecha, hora y punto de encuentro.
- ⏰ **Validación Temporal Estricta:** Validación preventiva en la interfaz que impide programar eventos en fechas u horas pasadas, alertando al usuario en tiempo real.
- 📰 **Feed Comunitario Inteligente:** Muro interactivo que muestra las publicaciones y eventos vigentes del campus.
- ⏳ **Filtro Automático de Eventos Expirados:** Los eventos cuya fecha y hora ya transcurrieron se descartan automáticamente en tiempo real tanto en la base de datos (`e.fecha_hora >= UTC_TIMESTAMP()`) como en la interfaz del cliente al recargar.
- 🏷️ **Filtros por Categoría:** Exploración rápida de eventos según el interés del estudiante (Deportes, Videojuegos, Juegos de Mesa, etc.).
- 👉 **Inscripción y Control de Cupos:** Registro y confirmación de asistencia a eventos con un solo toque, validación de cupo máximo disponible y visualización de la lista de asistentes.
- 💬 **Comentarios y Discusión en Hilos:** Sistema de debate comunitario en publicaciones con soporte para respuestas anidadas en árbol jerárquico.
- 👤 **Módulo de Perfil:** Consulta y edición de datos del estudiante, personalización de alias y carga de fotografía de perfil en almacenamiento persistente.
- 🌗 **Modo Oscuro / Claro Dinámico:** Alternador de tema en tiempo real accesible desde la barra superior del feed y el perfil, con persistencia local mediante `SharedPreferences`.

---

## 🏗️ Arquitectura del Software

El sistema implementa el patrón de diseño **MVC (Modelo - Vista - Controlador)** en el cliente y una arquitectura de servicios modular basada en el principio de **Responsabilidad Única (SRP)** en el servidor:

```text
proyecto_poo/
├── lib/                             # Frontend (Flutter)
│   ├── main.dart                    # Punto de entrada, rutas y ValueListenableBuilder de tema
│   ├── theme/                       # Paleta de colores, animaciones y controlador de tema
│   │   ├── app_colors.dart          # Tokens de color primario, secundario y acentos
│   │   ├── app_theme.dart           # Definición de ThemeData (Light y Dark)
│   │   ├── app_animations.dart      # Componentes animados y transiciones suaves
│   │   └── theme_controller.dart    # Gestión reactiva y persistencia del modo oscuro/claro
│   ├── crear_log_in/                # Módulo MVC de Autenticación
│   │   ├── crear_log_in_model.dart
│   │   ├── crear_log_in_view.dart
│   │   └── crear_log_in_controller.dart
│   ├── feed_principal/              # Módulo MVC del Feed y Publicaciones
│   │   ├── models/                  # ItemFeed, Comentario y serialización JSON
│   │   ├── screens/                 # FeedScreen con recarga y filtrado reactivo
│   │   ├── widgets/                 # FeedCard, CategoryFilter, DragonBanner
│   │   └── data/                    # Catálogo local de respaldo
│   ├── crear_evento/                # Módulo MVC de Creación de Eventos
│   │   ├── crear_evento_model.dart  # Modelo de datos y serialización UTC
│   │   ├── crear_evento_view.dart   # Formulario con validación de horas pasadas
│   │   └── crear_evento_controller.dart
│   └── ver_perfil/                  # Módulo MVC de Perfil de Usuario
│       ├── crear_perfil_model.dart
│       ├── ver_perfil_view.dart
│       └── ver_perfil_controller.dart
├── backend/                         # Backend (API REST modular en Node.js)
│   ├── server.js                    # Puente de arranque y compatibilidad para Render / npm start
│   ├── server/                      # Módulos desacoplados del servidor Express
│   │   ├── server.js                # Orquestador Express, CORS, headers ngrok y middlewares
│   │   ├── server.db.js             # Pool de conexiones MySQL / TiDB Cloud
│   │   ├── server.auth.js           # Registro, login, hashing bcrypt y middleware verificarSesion
│   │   ├── server.contenido.js      # Categorías, publicación de eventos, feed y borrado
│   │   └── server.interacciones.js  # Inscripciones, comentarios, árbol de respuestas y persistencia
│   ├── perfil.js                    # Endpoints y lógica de perfil / subida de fotografías
│   ├── cors-local.js                # Configuración de orígenes permitidos
│   ├── .env.example                 # Plantilla de variables de entorno del servidor
│   └── package.json                 # Dependencias y scripts de ejecución
├── database/                        # Scripts SQL y migraciones
│   └── instalacion.sql              # Definición de esquema completo (DDL) y datos iniciales
├── pubspec.yaml                     # Dependencias y configuración de Flutter
└── .env                             # Configuración local de Flutter (ignorado en Git)
```

---

## 🛠️ Tecnologías Empleadas

| Capa / Servicio | Herramienta / Plataforma | Descripción |
| :--- | :--- | :--- |
| **Frontend** | Flutter / Dart (SDK ^3.13.2) | Interfaz móvil y web reactiva basada en Material 3 |
| **Frontend en la Nube** | Vercel | Plataforma de alojamiento y distribución continua de la versión web de Flutter |
| **Backend** | Node.js (v24.x) + Express 5 | Servidor HTTP modular estructurado con endpoints REST |
| **Backend en la Nube** | Render | Despliegue continuo con sincronización automática al hacer `git push` al repositorio |
| **Base de Datos en la Nube** | TiDB Cloud (AWS) | Base de datos MySQL distribuida y serverless de alta disponibilidad |
| **Base de Datos Local** | MySQL Server 8.x | Alternativa local para pruebas y desarrollo sin conexión |
| **Seguridad** | JWT + bcryptjs | Emisión de tokens de sesión con expiración y hashing criptográfico de contraseñas |
| **Networking / Túneles** | ngrok | Exposición segura del backend local para pruebas directas en celulares físicos |

---

## ⚙️ Prerrequisitos

Para ejecutar o contribuir en el proyecto necesitas:

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Canal `stable`, Dart ^3.13.2)
* [Node.js](https://nodejs.org/) (Versión 18.x a 24.x)
* Cuenta en [TiDB Cloud](https://tidbcloud.com/) (o [MySQL Server](https://dev.mysql.com/downloads/) local)
* [ngrok](https://ngrok.com/) *(opcional, únicamente si se prueba en celular con servidor local)*
* Google Chrome o un dispositivo físico Android con depuración USB activada.

---

## 🗄️ Esquema de Base de Datos

El script de instalación y creación de tablas se encuentra en `database/instalacion.sql`. Las tablas que componen el modelo relacional son:

1. `usuarios` — Almacena el nombre, carrera, correo institucional (`@uvg.edu.gt`), hash de contraseña y URL de avatar.
2. `categorias` — Catálogo maestro de categorías temáticas (Deportes, Videojuegos, etc.).
3. `publicaciones` — Registros generales de publicaciones realizadas por los usuarios.
4. `eventos` — Entidad hija de publicaciones con ubicación física, fecha/hora programada, nivel de dificultad y cupo máximo.
5. `inscripciones` — Registro relacional de usuarios inscritos a cada evento (clave única compuesta `publicacion_id` + `usuario_id` para evitar duplicados).
6. `comentarios` — Mensajes de texto asociados a publicaciones con soporte para auto-referencia (`padre_id`) para respuestas anidadas.

---

## 🚀 Instalación y Despliegue

### 1. Clonar el repositorio
```bash
git clone <URL-del-repositorio>
cd proyecto_poo
```

### 2. Configurar la Base de Datos

* **Opción A (Recomendada - Nube TiDB Cloud):**  
  Crea un clúster Serverless gratuito en TiDB Cloud, abre la consola SQL y ejecuta el contenido de `database/instalacion.sql`. Obtendrás tus credenciales de host seguro (`gateway01.us-east-1.prod.aws.tidbcloud.com`).
* **Opción B (Local con MySQL Server):**  
  Inicia tu servicio local de MySQL e importa el archivo:
  ```bash
  mysql -u root -p < database/instalacion.sql
  ```

---

### 3. Configurar y Levantar el Backend (Node.js)

1. Ingresa a la carpeta del backend e instala dependencias:
   ```bash
   cd backend
   npm install
   ```

2. Crea tu archivo de variables de entorno:
   ```bash
   cp .env.example .env
   ```

3. Configura tus credenciales en `backend/.env`:
   ```env
   PORT=3000
   DB_HOST=gateway01.us-east-1.prod.aws.tidbcloud.com # o 127.0.0.1 para local
   DB_PORT=4000                                      # o 3306 para MySQL local
   DB_NAME=comunidad_campus
   DB_USER=tu_usuario
   DB_PASSWORD=tu_contraseña
   JWT_SECRET=tu_clave_secreta_jwt_segura
   ```

4. Inicia el servidor:
   ```bash
   npm start
   ```
   > El servidor responderá en `http://127.0.0.1:3000` y reportará la conexión exitosa con la base de datos.
   > 
   > *(Nota: En Render, el servicio se compila e inicia automáticamente mediante el comando `npm start` apuntando a `server.js`)*.

---

### 4. Configurar el Frontend (Flutter)

En la raíz del proyecto (`proyecto_poo/`), edita o crea el archivo `.env`:

* **Opción 1: Conectado al Backend en la Nube (Render):**
  ```env
  API_BASE_URL=https://uvg-matches-backend.onrender.com
  ```

* **Opción 2: Desarrollo Local en Chrome:**
  ```env
  API_BASE_URL=http://127.0.0.1:3000
  ```

* **Opción 3: Dispositivo Físico Android con Servidor Local (vía ngrok):**  
  Expón el puerto local:
  ```bash
  ngrok http 3000
  ```
  Y configura la URL generada en `.env`:
  ```env
  API_BASE_URL=https://tu-subdominio.ngrok-free.app
  ```

Descarga los paquetes de Flutter:
```bash
flutter pub get
```

---

### 5. Ejecutar la Aplicación

* **En Google Chrome (Pruebas Web):**
  ```bash
  flutter run -d chrome --web-port=5173 --web-browser-flag "--disable-web-security"
  ```

* **En Teléfono Físico o Emulador Android:**
  ```bash
  flutter run
  ```

* **En Producción Web (Vercel):**  
  La versión web de producción se compila con `flutter build web --release` y se despliega directamente en la plataforma de Vercel.

---

## 📚 Catálogo de Endpoints (API REST)

| Método | Ruta | Requiere Token | Módulo | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `GET` | `/categorias` | No | Contenido | Lista las categorías disponibles para eventos |
| `POST` | `/auth/registro` | No | Auth | Registra un nuevo estudiante institucional (`@uvg.edu.gt`) |
| `POST` | `/auth/login` | No | Auth | Valida credenciales y retorna el JWT de sesión |
| `GET` | `/feed` | Sí | Contenido | Obtiene eventos y publicaciones vigentes (excluye eventos pasados) |
| `POST` | `/eventos` | Sí | Contenido | Publica un nuevo evento validando cupos y fecha futura |
| `DELETE` | `/eventos/:id` | Sí | Contenido | Elimina un evento propio y limpia sus inscripciones y comentarios en cascada |
| `GET` | `/eventos/:id/inscripciones` | Sí | Interacciones | Consulta cupo ocupado, si el usuario está inscrito y lista de nombres |
| `POST` | `/eventos/:id/inscripcion` | Sí | Interacciones | Alterna inscripción/desinscripción con verificación de cupo máximo |
| `GET` | `/eventos/:id/comentarios` | Sí | Interacciones | Obtiene el listado estructurado de comentarios y respuestas |
| `POST` | `/eventos/:id/comentarios` | Sí | Interacciones | Publica un comentario general o una respuesta anidada a otro comentario |
| `GET` | `/perfil` | Sí | Perfil | Consulta los datos y foto del perfil activo |
| `PUT` | `/perfil` | Sí | Perfil | Actualiza los datos personales o alias del estudiante |
| `POST` | `/perfil/foto` | Sí | Perfil | Carga y almacena una nueva fotografía de perfil |

> 💡 **Nota sobre túneles ngrok:** Las peticiones HTTP que transitan por túneles ngrok incorporan el encabezado `'ngrok-skip-browser-warning': 'true'` para evitar que el proxy intercepte respuestas JSON con páginas de advertencia.

---

## 📦 Dependencias Principales

### Frontend (Flutter)
- `http` — Cliente HTTP reactivo para consumo de la API REST.
- `flutter_dotenv` — Carga y gestión segura de variables de entorno.
- `shared_preferences` — Persistencia en disco del token de sesión y preferencia de tema (claro/oscuro).
- `image_picker` — Acceso nativo a galería y cámara fotográfica.
- `path_provider` — Resolución de directorios del sistema de archivos local.

### Backend (Node.js)
- `express` (v5) — Framework del servidor web y enrutamiento modular.
- `mysql2` — Cliente con pool de conexiones y soporte para TiDB Cloud / MySQL Server.
- `jsonwebtoken` — Generación, firmado y verificación de tokens de autenticación JWT.
- `bcryptjs` — Hashing criptográfico unidireccional de contraseñas.
- `cors` — Middleware para control de acceso HTTP y habilitación de orígenes cruzados.
- `dotenv` — Inyección de variables de entorno desde archivos de configuración.

---

## 📄 Licencia y Uso Académico

Proyecto desarrollado con fines estrictamente académicos para el curso de **Programación Orientada a Objetos**, Universidad del Valle de Guatemala (2026). Todos los derechos reservados por el equipo de desarrollo.
