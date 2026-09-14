-- =========================================================
-- BASE DE DATOS: CLINICA VETERINARIA
-- Generado a partir del diagrama de clases (modelo logico)
-- Estrategia de herencia: tabla por subclase (comparten PK)
-- =========================================================

CREATE DATABASE IF NOT EXISTS clinica_veterinaria;
USE clinica_veterinaria;

-- =========================================================
-- 1. PERSONA (superclase) y sus subclases
-- =========================================================
CREATE TABLE Persona (
    documentoIdentidad VARCHAR(20) PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    telefono            VARCHAR(20)
);

CREATE TABLE Cliente (
    documentoIdentidad VARCHAR(20) PRIMARY KEY,
    direccion           VARCHAR(200),
    correoElectronico   VARCHAR(100),
    CONSTRAINT fk_cliente_persona
        FOREIGN KEY (documentoIdentidad) REFERENCES Persona(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Veterinario (
    documentoIdentidad VARCHAR(20) PRIMARY KEY,
    CONSTRAINT fk_veterinario_persona
        FOREIGN KEY (documentoIdentidad) REFERENCES Persona(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 2. ESPECIALIDAD y relacion N:M con Veterinario
-- =========================================================
CREATE TABLE Especialidad (
    idEspecialidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL
);

CREATE TABLE Veterinario_Especialidad (
    documentoIdentidad VARCHAR(20) NOT NULL,
    idEspecialidad     INT NOT NULL,
    PRIMARY KEY (documentoIdentidad, idEspecialidad),
    CONSTRAINT fk_ve_veterinario
        FOREIGN KEY (documentoIdentidad) REFERENCES Veterinario(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ve_especialidad
        FOREIGN KEY (idEspecialidad) REFERENCES Especialidad(idEspecialidad)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 3. SEDE
-- =========================================================
CREATE TABLE Sede (
    idSede    INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono  VARCHAR(20)
);

-- =========================================================
-- 4. JAULA
-- =========================================================
CREATE TABLE Jaula (
    idJaula INT AUTO_INCREMENT PRIMARY KEY,
    numero  VARCHAR(20) NOT NULL,
    tamano  VARCHAR(20)
);

-- =========================================================
-- 5. MASCOTA (pertenece a un Cliente)
-- =========================================================
CREATE TABLE Mascota (
    idMascota        INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    especie          VARCHAR(50),
    raza             VARCHAR(50),
    fechaNacimiento  DATE,
    sexo             VARCHAR(10),
    peso             FLOAT,
    microchip        VARCHAR(50),
    idCliente        VARCHAR(20) NOT NULL,
    CONSTRAINT fk_mascota_cliente
        FOREIGN KEY (idCliente) REFERENCES Cliente(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 6. HISTORIA CLINICA (1:1 con Mascota)
-- =========================================================
CREATE TABLE HistoriaClinica (
    idHistoriaClinica INT AUTO_INCREMENT PRIMARY KEY,
    idMascota         INT NOT NULL UNIQUE,
    CONSTRAINT fk_historia_mascota
        FOREIGN KEY (idMascota) REFERENCES Mascota(idMascota)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 7. HOSPITALIZACION (1 Mascota : N, 1 Jaula : N)
-- =========================================================
CREATE TABLE Hospitalizacion (
    idHospitalizacion INT AUTO_INCREMENT PRIMARY KEY,
    fechaIngreso      DATE NOT NULL,
    fechaSalida       DATE,
    motivo            VARCHAR(200),
    idMascota         INT NOT NULL,
    idJaula           INT NOT NULL,
    CONSTRAINT fk_hosp_mascota
        FOREIGN KEY (idMascota) REFERENCES Mascota(idMascota)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_hosp_jaula
        FOREIGN KEY (idJaula) REFERENCES Jaula(idJaula)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================================================
-- 8. NOTA EVOLUCION (1 Hospitalizacion : N)
-- =========================================================
CREATE TABLE NotaEvolucion (
    idNotaEvolucion   INT AUTO_INCREMENT PRIMARY KEY,
    fecha             DATE NOT NULL,
    hora              TIME NOT NULL,
    observacion       VARCHAR(300),
    idHospitalizacion INT NOT NULL,
    CONSTRAINT fk_nota_hospitalizacion
        FOREIGN KEY (idHospitalizacion) REFERENCES Hospitalizacion(idHospitalizacion)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 9. CITA (1 Mascota : N, 1 Sede : N, 1 Veterinario : N)
-- =========================================================
CREATE TABLE Cita (
    idCita    INT AUTO_INCREMENT PRIMARY KEY,
    fecha     DATE NOT NULL,
    hora      TIME NOT NULL,
    motivo    VARCHAR(200),
    estado    VARCHAR(30),
    idMascota INT NOT NULL,
    idSede    INT NOT NULL,
    idVeterinario VARCHAR(20) NOT NULL,
    CONSTRAINT fk_cita_mascota
        FOREIGN KEY (idMascota) REFERENCES Mascota(idMascota)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_cita_sede
        FOREIGN KEY (idSede) REFERENCES Sede(idSede)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_veterinario
        FOREIGN KEY (idVeterinario) REFERENCES Veterinario(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================================================
-- 10. CONSULTA (0..1 : 1 con Cita -> no toda cita genera consulta)
-- =========================================================
CREATE TABLE Consulta (
    idConsulta   INT AUTO_INCREMENT PRIMARY KEY,
    sintomas     VARCHAR(300),
    diagnostico  VARCHAR(300),
    indicaciones VARCHAR(300),
    idCita       INT NOT NULL UNIQUE,
    CONSTRAINT fk_consulta_cita
        FOREIGN KEY (idCita) REFERENCES Cita(idCita)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 11. EXAMEN LABORATORIO (1 Consulta : N)
-- =========================================================
CREATE TABLE ExamenLaboratorio (
    idExamen        INT AUTO_INCREMENT PRIMARY KEY,
    tipoExamen      VARCHAR(100),
    fechaSolicitud  DATE,
    fechaResultado  DATE,
    resultado       VARCHAR(300),
    idConsulta      INT NOT NULL,
    CONSTRAINT fk_examen_consulta
        FOREIGN KEY (idConsulta) REFERENCES Consulta(idConsulta)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 12. PRODUCTO (superclase) y subclases Vacuna / Medicamento
-- =========================================================
CREATE TABLE Producto (
    idProducto   INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    presentacion VARCHAR(100)
);

CREATE TABLE Vacuna (
    idProducto           INT PRIMARY KEY,
    enfermedadQuePrevine VARCHAR(150),
    CONSTRAINT fk_vacuna_producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Medicamento (
    idProducto      INT PRIMARY KEY,
    principioActivo VARCHAR(150),
    CONSTRAINT fk_medicamento_producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 13. LOTE (1 Producto : N)
-- =========================================================
CREATE TABLE Lote (
    idLote           INT AUTO_INCREMENT PRIMARY KEY,
    numeroLote       VARCHAR(50) NOT NULL,
    fechaVencimiento DATE,
    fechaFabricacion DATE,
    idProducto       INT NOT NULL,
    CONSTRAINT fk_lote_producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 14. APLICACION VACUNA (1 Consulta : N, 1 Vacuna : N)
-- =========================================================
CREATE TABLE AplicacionVacuna (
    idAplicacion   INT AUTO_INCREMENT PRIMARY KEY,
    fechaAplicacion DATE NOT NULL,
    idConsulta     INT NOT NULL,
    idVacuna       INT NOT NULL,
    CONSTRAINT fk_aplicacion_consulta
        FOREIGN KEY (idConsulta) REFERENCES Consulta(idConsulta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_aplicacion_vacuna
        FOREIGN KEY (idVacuna) REFERENCES Vacuna(idProducto)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================================================
-- 15. SEDE <-> PRODUCTO (inventario, relacion N:M)
-- =========================================================
CREATE TABLE Sede_Producto (
    idSede     INT NOT NULL,
    idProducto INT NOT NULL,
    PRIMARY KEY (idSede, idProducto),
    CONSTRAINT fk_sp_sede
        FOREIGN KEY (idSede) REFERENCES Sede(idSede)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_sp_producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 16. FACTURA (1 Cliente : N)
-- =========================================================
CREATE TABLE Factura (
    idFactura    INT AUTO_INCREMENT PRIMARY KEY,
    fechaEmision DATE NOT NULL,
    valorTotal   FLOAT DEFAULT 0,
    idCliente    VARCHAR(20) NOT NULL,
    CONSTRAINT fk_factura_cliente
        FOREIGN KEY (idCliente) REFERENCES Cliente(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================================================
-- 17. LINEA FACTURA (1 Factura : N)
-- =========================================================
CREATE TABLE LineaFactura (
    idLineaFactura INT AUTO_INCREMENT PRIMARY KEY,
    concepto       VARCHAR(150) NOT NULL,
    cantidad       INT NOT NULL,
    valorUnitario  FLOAT NOT NULL,
    subtotal       FLOAT GENERATED ALWAYS AS (cantidad * valorUnitario) STORED,
    idFactura      INT NOT NULL,
    CONSTRAINT fk_linea_factura
        FOREIGN KEY (idFactura) REFERENCES Factura(idFactura)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 18. PAGO (1 Factura : N)
-- =========================================================
CREATE TABLE Pago (
    idPago    INT AUTO_INCREMENT PRIMARY KEY,
    fecha     DATE NOT NULL,
    monto     FLOAT NOT NULL,
    medioPago VARCHAR(50),
    idFactura INT NOT NULL,
    CONSTRAINT fk_pago_factura
        FOREIGN KEY (idFactura) REFERENCES Factura(idFactura)
        ON UPDATE CASCADE ON DELETE CASCADE
);