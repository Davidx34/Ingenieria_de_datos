-- =========================================================
-- TECHCORP - GESTION DE EMPLEADOS Y DEPARTAMENTOS
-- =========================================================

CREATE DATABASE IF NOT EXISTS techcorp;
USE techcorp;

-- ---------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------
CREATE TABLE Departamento (
    idDepartamento INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(50) NOT NULL
);

CREATE TABLE Empleado (
    idEmpleado         INT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    edad                INT NOT NULL,
    salario             DECIMAL(10,2) NOT NULL,
    fechaContratacion   DATE NOT NULL,
    idDepartamento      INT NOT NULL,
    CONSTRAINT fk_empleado_departamento
        FOREIGN KEY (idDepartamento) REFERENCES Departamento(idDepartamento)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------
-- Datos de prueba
-- ---------------------------------------------------------
INSERT INTO Departamento (nombre) VALUES
('Ventas'),
('IT'),
('Recursos Humanos'),
('Marketing'),
('Finanzas');

INSERT INTO Empleado (nombre, edad, salario, fechaContratacion, idDepartamento) VALUES
('Ana Martínez',      28, 3800.00, '2019-03-15', 1),
('Carlos Ramírez',    35, 4500.00, '2021-06-01', 1),
('Beatriz Gómez',     41, 5200.00, '2017-01-10', 2),
('Andrés Torres',     32, 3900.00, '2020-11-20', 2),
('Camila Rodríguez',  27, 4100.00, '2022-02-05', 3),
('David López',       45, 6000.00, '2015-08-30', 4),
('Elena Castro',      38, 4700.00, '2018-04-12', 4),
('Federico Ortiz',    30, 3700.00, '2023-01-18', 5),
('Alejandra Ríos',    33, 5100.00, '2021-09-09', 2),
('Camilo Vargas',     29, 3600.00, '2020-07-25', 1),
('Gabriela Suárez',   50, 6500.00, '2010-05-14', 5),
('Andrea Peña',       36, 4400.00, '2019-12-01', 3),
('Cristian Morales',  31, 3950.00, '2024-03-10', 2),
('Diana Herrera',     26, 3500.00, '2023-08-22', 1);

-- =========================================================
-- RETOS
-- =========================================================

-- 1. Lista de empleados: nombres, edades y salarios
SELECT nombre, edad, salario
FROM Empleado;

-- 2. Altos ingresos: empleados que ganan más de $4,000
SELECT nombre, salario
FROM Empleado
WHERE salario > 4000;

-- 3. Fuerza de ventas: empleados del departamento de Ventas
SELECT e.nombre, e.edad, e.salario
FROM Empleado e
JOIN Departamento d ON e.idDepartamento = d.idDepartamento
WHERE d.nombre = 'Ventas';

-- 4. Rango de edad: empleados entre 30 y 40 años
SELECT nombre, edad
FROM Empleado
WHERE edad BETWEEN 30 AND 40;

-- 5. Nuevas contrataciones: contratados después del año 2020
SELECT nombre, fechaContratacion
FROM Empleado
WHERE fechaContratacion > '2020-12-31';

-- 6. Distribución de empleados: cuántos hay en cada departamento
SELECT d.nombre AS departamento, COUNT(e.idEmpleado) AS totalEmpleados
FROM Departamento d
LEFT JOIN Empleado e ON d.idDepartamento = e.idDepartamento
GROUP BY d.nombre;

-- 7. Análisis salarial: salario promedio en la empresa
SELECT ROUND(AVG(salario), 2) AS salarioPromedio
FROM Empleado;

-- 8. Nombres selectivos: empleados cuyos nombres empiezan con "A" o "C"
SELECT nombre
FROM Empleado
WHERE nombre LIKE 'A%' OR nombre LIKE 'C%';

-- 9. Departamentos específicos: empleados que NO pertenecen a IT
SELECT e.nombre, d.nombre AS departamento
FROM Empleado e
JOIN Departamento d ON e.idDepartamento = d.idDepartamento
WHERE d.nombre <> 'IT';

-- 10. El mejor pagado: empleado con el salario más alto
SELECT nombre, salario
FROM Empleado
ORDER BY salario ASC
LIMIT 10;