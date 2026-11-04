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
- 🏟️ **Gestión y Creación de Eventos:** Publicación de encuentros deportivos, videojuegos o juegos de mesa con control de cupos, dificultad (Casual, Intermedio, Avanzado), fecha, hora y ubicación.
- 📰 **Feed Comunitario:** Muro interactivo con publicaciones y eventos recientes del campus.
- 🏷️ **Filtros por Categoría:** Exploración rápida de eventos según el interés del estudiante.
- 👉 **Inscripción Inmediata:** Registro y confirmación de asistencia a eventos con un solo toque.
- 👤 **Módulo de Perfil:** Consulta y edición de datos del usuario, personalización de carrera, alias y carga de fotografía de perfil.

---

## 🏗️ Arquitectura del Software

El sistema implementa el patrón de diseño **MVC (Modelo - Vista - Controlador)** separando responsabilidades entre la interfaz cliente (Flutter) y el servidor de servicios REST (Node.js/Express):

```text
proyecto_poo/
├── lib/                             # Frontend (Flutter)
│   ├── main.dart                    # Punto de entrada y configuración de rutas
│   ├── theme/                       # Paleta de colores y Material 3 (Dark/Light)
│   ├── crear_log_in/                # Módulo de Autenticación
│   │   ├── crear_log_in_model.dart
│   │   ├── crear_log_in_view.dart
│   │   └── crear_log_in_controller.dart
│   ├── feed_principal/              # Módulo del Feed y Publicaciones
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── data/
│   ├── crear_evento/                # Módulo de Creación de Eventos
│   │   ├── crear_evento_model.dart
│   │   ├── crear_evento_view.dart
│   │   └── crear_evento_controller.dart
│   └── ver_perfil/                  # Módulo de Perfil de Usuario
│       ├── crear_perfil_model.dart
│       ├── ver_perfil_view.dart
│       └── ver_perfil_controller.dart
├── backend/                         # Backend (API REST en Node.js)
│   ├── server.js                    # Servidor principal y middlewares
│   ├── perfil.js                    # Endpoints y lógica de perfil / uploads
│   ├── PERFIL.md                    # Documentación del módulo de perfil
│   ├── cors-local.js                # Control de orígenes permitidos
│   ├── .env.example                 # Variables de entorno de muestra
│   └── package.json                 # Dependencias y scripts de Node
├── database.sql                     # Script de creación de tablas y datos base
├── pubspec.yaml                     # Dependencias de Flutter
└── .env                             # Configuración local de Flutter (ignorado en Git)
```

---

## 🛠️ Tecnologías Empleadas

| Capa | Herramienta / Librería | Descripción |
| :--- | :--- | :--- |
| **Frontend** | Flutter / Dart (SDK ^3.13.2) | Interfaz móvil y web reactiva bajo Material 3 |
| **Backend** | Node.js (v24.x) + Express 5 | Servidor HTTP modular con endpoints REST |
| **Base de Datos**| MySQL | Almacenamiento relacional de usuarios, eventos y perfiles |
| **Seguridad** | JWT + bcryptjs | Tokens de sesión seguros y hashing de contraseñas |
| **Networking** | ngrok | Exposición segura del backend local para pruebas móviles |

---

## ⚙️ Prerrequisitos

Asegúrate de contar con las siguientes herramientas instaladas:

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Canal stable, Dart ^3.13.2)
* [Node.js](https://nodejs.org/) (Versión 24.x recomendada)
* [MySQL Server](https://dev.mysql.com/downloads/) (o cliente compatible como Workbench / XAMPP)
* [ngrok](https://ngrok.com/) (Para pruebas en dispositivos físicos o emuladores)
* Google Chrome o dispositivo físico Android con depuración USB activada.

---

## 🚀 Instalación y Despliegue Local

### 1. Clonar el repositorio
```bash
git clone <URL-del-repositorio>
cd proyecto_poo
```

### 2. Configurar la Base de Datos
1. Inicia tu servicio de MySQL.
2. Crea la base de datos e importa las tablas requeridas ejecutando el script provisto:
   ```bash
   mysql -u root -p < database.sql
   ```
   *(Tablas generadas: `usuarios`, `categorias`, `eventos`, `publicaciones`)*.

### 3. Configurar y Levantar el Backend
Navega a la carpeta del backend donde reside la configuración activa:
```bash
cd backend
npm install
```

Crea el archivo `.env` a partir de la plantilla:
```bash
cp .env.example .env
```

Configura tus credenciales en `backend/.env`:
```env
PORT=3000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=comunidad_campus
DB_USER=root
DB_PASSWORD=tu_contraseña_mysql
JWT_SECRET=tu_clave_secreta_jwt_segura
```

Inicia el servidor Node.js:
```bash
npm start
```
> El servidor quedará listo escuchando en `http://127.0.0.1:3000`.

---

### 4. Configurar el Frontend (Flutter)

En la raíz del proyecto Flutter, crea o edita tu archivo `.env`:

* **Opción A: Pruebas locales en navegador Chrome:**
  ```env
  API_BASE_URL=[http://127.0.0.1:3000](http://127.0.0.1:3000)
  ```

* **Opción B: Pruebas en Teléfono Físico / APK (vía ngrok):**  
  1. En una terminal independiente, expón el puerto 3000:
     ```bash
     ngrok http 3000
     ```
  2. Coloca la URL generada en tu archivo `.env`:
     ```env
     API_BASE_URL=[https://tu-url.ngrok-free.app](https://tu-url.ngrok-free.app)
     ```

Instala los paquetes de Flutter:
```bash
flutter pub get
```

---

### 5. Ejecutar la Aplicación

* **En Google Chrome (Recomendado para desarrollo rápido):**  
  *(Asegura omitir restricciones de CORS en el navegador local durante pruebas)*:
  ```bash
  flutter run -d chrome --web-port=5173 --web-browser-flag "--disable-web-security"
  ```

* **En Teléfono Físico o Emulador Android:**
  ```bash
  flutter run
  ```

---

## 📚 Catálogo de Endpoints (API REST)

| Método | Ruta | Requiere Token | Descripción |
| :--- | :--- | :---: | :--- |
| `GET` | `/categorias` | No | Lista las categorías disponibles para eventos |
| `POST` | `/auth/registro` | No | Registra un nuevo estudiante institucional |
| `POST` | `/auth/login` | No | Autenticación de usuario; retorna JWT de sesión |
| `GET` | `/feed` | Sí | Obtiene las publicaciones y eventos del campus |
| `POST` | `/eventos` | Sí | Registra y publica un nuevo evento |
| `GET` | `/perfil` | Sí | Consulta la información y foto del perfil activo |
| `PUT` | `/perfil` | Sí | Actualiza los datos personales o alias del estudiante |
| `POST` | `/perfil/foto` | Sí | Carga y almacena una nueva fotografía de perfil |

> 💡 **Nota sobre túneles ngrok:** Las peticiones HTTP que pasen por el túnel ngrok incluyen el encabezado `'ngrok-skip-browser-warning': 'true'` para evitar que el proxy intercepte la respuesta con pantallas HTML de advertencia.

---

## 📦 Dependencias Principales

### Frontend (Flutter)
- `http` — Cliente para consumo de servicios REST.
- `flutter_dotenv` — Carga y manejo seguro de variables de entorno.
- `image_picker` — Acceso a galería y cámara para selección de fotos.
- `shared_preferences` — Persistencia local de tokens y datos de sesión.
- `path_provider` — Resolución de rutas del sistema de archivos local.

### Backend (Node.js)
- `express` — Framework del servidor web y enrutamiento.
- `mysql2` — Driver de comunicación y pool de conexiones MySQL.
- `jsonwebtoken` — Generación, firmado y verificación de tokens JWT.
- `bcryptjs` — Hashing criptográfico unidireccional de contraseñas.
- `dotenv` — Inyección de variables de entorno del sistema.

---

## 📄 Licencia y Uso Académico

Proyecto desarrollado con fines estrictamente académicos para el curso de **Programación Orientada a Objetos**, Universidad del Valle de Guatemala (2026). Todos los derechos reservados por el equipo de desarrollo.
