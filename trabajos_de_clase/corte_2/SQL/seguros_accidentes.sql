-- =========================================================
-- BASE DE DATOS 2: SEGUROS Y ACCIDENTES DE AUTOMOVILES
-- Entidades: Compañia, Automovil, Asegura, Involucra, Accidente
-- =========================================================

CREATE DATABASE IF NOT EXISTS seguros_accidentes;
USE seguros_accidentes;

-- ---------------------------------------------------------
-- Tabla: Compania
-- ---------------------------------------------------------
CREATE TABLE Compania (
    idCompania         VARCHAR(50) PRIMARY KEY,
    nit                VARCHAR(30),
    nombre             VARCHAR(150),
    fechaFundacion     VARCHAR(20),
    representanteLegal VARCHAR(20)
);

-- ---------------------------------------------------------
-- Tabla: Automovil
-- serialChasis se marca como clave alterna (única)
-- ---------------------------------------------------------
CREATE TABLE Automovil (
    idAutomovil     VARCHAR(50) PRIMARY KEY,
    marca           VARCHAR(100),
    modelo          VARCHAR(100),
    placa           VARCHAR(20),
    tipo            VARCHAR(50),
    anioFabricacion INT,
    cilindraje      INT,
    pasajeros       INT,
    serialChasis    VARCHAR(50) NOT NULL UNIQUE
);

-- ---------------------------------------------------------
-- Tabla: Accidente
-- ---------------------------------------------------------
CREATE TABLE Accidente (
    idAccidente    VARCHAR(50) PRIMARY KEY,
    fechaAccidente VARCHAR(20) NOT NULL,
    lugar          VARCHAR(150),
    heridos        INT,
    muertos        INT,
    automoviles    INT
);

-- ---------------------------------------------------------
-- Tabla: Asegura (relación N:M entre Compania y Automovil)
-- Una compañia asegura muchos automoviles y un automovil
-- puede tener polizas con varias compañias (histórico).
-- ---------------------------------------------------------
CREATE TABLE Asegura (
    idCompania     VARCHAR(50) NOT NULL,
    idAutomovil    VARCHAR(50) NOT NULL,
    estado         VARCHAR(20),
    fechaInicio    DATE,
    fechaExpiracion DATE,
    costo          INT,
    valorAsegurado INT,
    PRIMARY KEY (idCompania, idAutomovil),
    CONSTRAINT fk_asegura_compania
        FOREIGN KEY (idCompania) REFERENCES Compania(idCompania)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_asegura_automovil
        FOREIGN KEY (idAutomovil) REFERENCES Automovil(idAutomovil)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Tabla: Involucra (relación N:M entre Accidente y Automovil)
-- Un accidente puede involucrar varios automoviles y un
-- automovil puede estar involucrado en varios accidentes.
-- ---------------------------------------------------------
CREATE TABLE Involucra (
    idAccidente VARCHAR(50) NOT NULL,
    idAutomovil VARCHAR(50) NOT NULL,
    PRIMARY KEY (idAccidente, idAutomovil),
    CONSTRAINT fk_involucra_accidente
        FOREIGN KEY (idAccidente) REFERENCES Accidente(idAccidente)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_involucra_automovil
        FOREIGN KEY (idAutomovil) REFERENCES Automovil(idAutomovil)
        ON UPDATE CASCADE ON DELETE CASCADE
);