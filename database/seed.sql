INSERT INTO categorias (nombre) VALUES
    ('Deportes y Actividad Física'),
    ('Gaming / Juegos de mesa')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);
