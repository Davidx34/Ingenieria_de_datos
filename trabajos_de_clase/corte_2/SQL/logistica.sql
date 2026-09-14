-- =========================================================
-- BASE DE DATOS 1: LOGISTICA DE ENVIOS
-- Entidades: Camionero, Camion, Conduce, Paquete, Ciudad
-- =========================================================

CREATE DATABASE IF NOT EXISTS logistica;
USE logistica;

-- ---------------------------------------------------------
-- Tabla: Camionero
-- ---------------------------------------------------------
CREATE TABLE Camionero (
    idCamionero VARCHAR(50) PRIMARY KEY,
    nombre      VARCHAR(100),
    telefono    VARCHAR(20),
    direccion   VARCHAR(200)
);

-- ---------------------------------------------------------
-- Tabla: Camion
-- ---------------------------------------------------------
CREATE TABLE Camion (
    idCamion VARCHAR(50) PRIMARY KEY,
    modelo   VARCHAR(100) NOT NULL,
    potencia VARCHAR(50),
    tipo     VARCHAR(50)
);

-- ---------------------------------------------------------
-- Tabla: Ciudad
-- ---------------------------------------------------------
CREATE TABLE Ciudad (
    idCiudad VARCHAR(50) PRIMARY KEY,
    nombre   VARCHAR(100)
);

-- ---------------------------------------------------------
-- Tabla: Conduce (relación N:M entre Camionero y Camion)
-- Un camionero puede conducir varios camiones a lo largo
-- del tiempo y un camion puede ser conducido por varios
-- camioneros.
-- ---------------------------------------------------------
CREATE TABLE Conduce (
    idCamionero VARCHAR(50) NOT NULL,
    idCamion    VARCHAR(50) NOT NULL,
    PRIMARY KEY (idCamionero, idCamion),
    CONSTRAINT fk_conduce_camionero
        FOREIGN KEY (idCamionero) REFERENCES Camionero(idCamionero)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_conduce_camion
        FOREIGN KEY (idCamion) REFERENCES Camion(idCamion)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Tabla: Paquete
-- Un camionero (1) puede llevar muchos paquetes (N)
-- Una ciudad (1) puede ser destino de muchos paquetes (N)
-- ---------------------------------------------------------
CREATE TABLE Paquete (
    idPaquete   VARCHAR(50) PRIMARY KEY,
    idCamionero VARCHAR(50),
    idCiudad    VARCHAR(50),
    descripcion VARCHAR(200),
    destinatario VARCHAR(100),
    direccion   VARCHAR(50),
    CONSTRAINT fk_paquete_camionero
        FOREIGN KEY (idCamionero) REFERENCES Camionero(idCamionero)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_paquete_ciudad
        FOREIGN KEY (idCiudad) REFERENCES Ciudad(idCiudad)
        ON UPDATE CASCADE ON DELETE SET NULL
);