-- Para una base NUEVA. No ejecutar como migración de una base existente.
CREATE DATABASE IF NOT EXISTS comunidad_campus CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE comunidad_campus;
CREATE TABLE usuarios (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 carrera VARCHAR(150) NULL,
 correo VARCHAR(254) NOT NULL,
 password_hash VARCHAR(255) NOT NULL,
 foto_url VARCHAR(2048) NULL,
 creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT uq_usuarios_correo UNIQUE(correo)
) ENGINE=InnoDB;
CREATE TABLE categorias (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;
CREATE TABLE publicaciones (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 usuario_id BIGINT UNSIGNED NOT NULL,
 categoria_id BIGINT UNSIGNED NOT NULL,
 titulo VARCHAR(150) NOT NULL,
 descripcion TEXT NOT NULL,
 creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(usuario_id) REFERENCES usuarios(id),
 FOREIGN KEY(categoria_id) REFERENCES categorias(id)
) ENGINE=InnoDB;
CREATE TABLE eventos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 publicacion_id BIGINT UNSIGNED NOT NULL UNIQUE,
 ubicacion VARCHAR(255) NOT NULL,
 fecha_hora DATETIME NOT NULL,
 dificultad ENUM('Casual','Intermedio','Avanzado') NOT NULL,
 cupo_maximo INT UNSIGNED NOT NULL,
 FOREIGN KEY(publicacion_id) REFERENCES publicaciones(id),
 CONSTRAINT chk_eventos_cupo CHECK(cupo_maximo > 0)
) ENGINE=InnoDB;
INSERT INTO categorias(nombre) VALUES ('Deportes y Actividad Física'),('Gaming / Juegos de mesa');
