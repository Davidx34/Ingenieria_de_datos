DROP DATABASE IF EXISTS eduplus;
CREATE DATABASE eduplus CHARACTER SET utf8mb4;
USE eduplus;

CREATE TABLE Instructores (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Cursos (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  titulo       VARCHAR(100)  NOT NULL,
  area         VARCHAR(50)   NOT NULL,
  precio       DECIMAL(10,2) NOT NULL,
  instructorId INT           NOT NULL,
  CONSTRAINT fkCursosInstructor
    FOREIGN KEY (instructorId) REFERENCES Instructores(id)
);

CREATE TABLE Estudiantes (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  nombre   VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  ciudad   VARCHAR(50) NOT NULL
);

CREATE TABLE Inscripciones (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  estudianteId     INT           NOT NULL,
  cursoId          INT           NOT NULL,
  fechaInscripcion DATE          NOT NULL,
  valorPagado      DECIMAL(10,2) NOT NULL,
  notaFinal        DECIMAL(3,1)  NULL,
  CONSTRAINT fkInscripcionesEstudiante
    FOREIGN KEY (estudianteId) REFERENCES Estudiantes(id),
  CONSTRAINT fkInscripcionesCurso
    FOREIGN KEY (cursoId) REFERENCES Cursos(id)
);

INSERT INTO Instructores (nombre, email) VALUES
  ('Paula Herrera',   'paula@eduplus.co'),
  ('Andrés Quintero', 'andres@eduplus.co'),
  ('Camilo Vargas',   'camilo@eduplus.co');

INSERT INTO Cursos (titulo, area, precio, instructorId) VALUES
  ('SQL desde cero',       'Bases de datos', 200000.00, 1),
  ('Python para análisis', 'Programación',   350000.00, 2),
  ('Git y GitHub',         'Herramientas',   120000.00, 1),
  ('React avanzado',       'Programación',   450000.00, 2),
  ('Docker práctico',      'Herramientas',   300000.00, 1);

INSERT INTO Estudiantes (nombre, apellido, ciudad) VALUES
  ('Valeria',  'Ortiz',  'Bogotá'),
  ('Samuel',   'Rojas',  'Medellín'),
  ('Isabella', 'Cruz',   'Cali'),
  ('Tomás',    'Pineda', 'Bogotá'),
  ('Juliana',  'Soto',   'Pereira'),
  ('Martín',   'López',  'Cali');

INSERT INTO Inscripciones (estudianteId, cursoId, fechaInscripcion, valorPagado, notaFinal) VALUES
  (1, 1, '2026-06-01', 200000.00, 4.5),
  (1, 2, '2026-06-10', 350000.00, 4.0),
  (2, 1, '2026-06-05', 180000.00, 3.8),
  (2, 4, '2026-07-01', 450000.00, NULL),
  (3, 2, '2026-07-15', 315000.00, 4.8),
  (3, 3, '2026-07-20', 120000.00, 4.2),
  (4, 1, '2026-08-01', 200000.00, NULL),
  (4, 3, '2026-08-03', 120000.00, 3.5),
  (4, 4, '2026-08-10', 450000.00, NULL);

-- Punto 1: INNER JOIN
SELECT
  c.titulo,
  c.area,
  c.precio,
  i.nombre AS instructor
FROM Cursos c
INNER JOIN Instructores i ON i.id = c.instructorId
ORDER BY i.nombre, c.titulo;

-- Punto 2: LEFT JOIN
SELECT
  e.nombre,
  e.apellido,
  e.ciudad
FROM Estudiantes e
LEFT JOIN Inscripciones ins ON ins.estudianteId = e.id
WHERE ins.id IS NULL;

-- Punto 3: tres o más tablas
SELECT
  CONCAT(e.nombre, ' ', e.apellido) AS estudiante,
  c.titulo                          AS curso,
  i.nombre                          AS instructor,
  ins.fechaInscripcion,
  ins.valorPagado
FROM Inscripciones ins
INNER JOIN Estudiantes  e ON e.id = ins.estudianteId
INNER JOIN Cursos       c ON c.id = ins.cursoId
INNER JOIN Instructores i ON i.id = c.instructorId
ORDER BY ins.fechaInscripcion;
