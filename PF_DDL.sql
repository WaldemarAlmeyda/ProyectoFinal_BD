/* ============================================================================
   PROYECTO: Sistema de Monitoreo y Gestión de Delitos contra el Patrimonio
             en la Ciudad de Ica
   ============================================================================ */

-- ===============================
-- 1. CREACIÓN DE LA BASE DE DATOS
-- ===============================
CREATE DATABASE SistemaDelitosPatrimonioIca;
GO

USE SistemaDelitosPatrimonioIca;
GO

-- ==================
-- 2. TABLAS CATÁLOGO
-- ==================

-- Tabla: Ciudadano
CREATE TABLE Ciudadano (
    id_ciudadano     INT IDENTITY(1,1) NOT NULL,
    dni              CHAR(8)       NOT NULL,
    nombres          VARCHAR(100)  NOT NULL,
    apellidos        VARCHAR(100)  NOT NULL,
    telefono         VARCHAR(15)   NULL,
    direccion        VARCHAR(200)  NULL,
    correo           VARCHAR(100)  NULL,
    fecha_registro   DATE          NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    estado           BIT           NOT NULL DEFAULT (1),

    CONSTRAINT PK_Ciudadano PRIMARY KEY (id_ciudadano),
    CONSTRAINT UQ_Ciudadano_Dni UNIQUE (dni)             
);
GO

-- Tabla: Tipo_Delito
CREATE TABLE Tipo_Delito (
    id_tipo_delito   INT IDENTITY(1,1) NOT NULL,
    nombre           VARCHAR(80)   NOT NULL,
    descripcion      VARCHAR(250)  NULL,

    CONSTRAINT PK_Tipo_Delito PRIMARY KEY (id_tipo_delito),
    CONSTRAINT UQ_Tipo_Delito_Nombre UNIQUE (nombre)
);
GO

-- Tabla: Tipo_Evidencia
CREATE TABLE Tipo_Evidencia (
    id_tipo_evidencia INT IDENTITY(1,1) NOT NULL,
    nombre            VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Tipo_Evidencia PRIMARY KEY (id_tipo_evidencia),
    CONSTRAINT UQ_Tipo_Evidencia_Nombre UNIQUE (nombre)
);
GO

-- Tabla: Ubicacion 
CREATE TABLE Ubicacion (
    id_ubicacion     INT IDENTITY(1,1) NOT NULL,
    distrito         VARCHAR(50)   NOT NULL,
    direccion        VARCHAR(200)  NOT NULL,
    referencia       VARCHAR(250)  NULL,
    latitud          DECIMAL(10,8) NULL,
    longitud         DECIMAL(11,8) NULL,

    CONSTRAINT PK_Ubicacion PRIMARY KEY (id_ubicacion),
    CONSTRAINT CK_Ubicacion_Latitud  CHECK (latitud  BETWEEN -90  AND 90),  
    CONSTRAINT CK_Ubicacion_Longitud CHECK (longitud BETWEEN -180 AND 180) 
);
GO

-- Tabla: Estado_Incidente
CREATE TABLE Estado_Incidente (
    id_estado        INT IDENTITY(1,1) NOT NULL,
    nombre_estado    VARCHAR(50)  NOT NULL,
    descripcion      VARCHAR(200) NULL,

    CONSTRAINT PK_Estado_Incidente PRIMARY KEY (id_estado),
    CONSTRAINT UQ_Estado_Incidente_Nombre UNIQUE (nombre_estado)
);
GO

-- Tabla: Autoridad
CREATE TABLE Autoridad (
    id_autoridad     INT IDENTITY(1,1) NOT NULL,
    nombres          VARCHAR(100) NOT NULL,
    apellidos        VARCHAR(100) NOT NULL,
    cargo            VARCHAR(100) NOT NULL,
    institucion      VARCHAR(100) NOT NULL,
    telefono         VARCHAR(15)  NULL,
    correo           VARCHAR(100) NULL,

    CONSTRAINT PK_Autoridad PRIMARY KEY (id_autoridad)
);
GO

-- ==============================
-- 3. TABLA PRINCIPAL: Incidente
-- ==============================
CREATE TABLE Incidente (
    id_incidente            INT IDENTITY(1,1) NOT NULL,
    fecha_ocurrencia        DATE          NOT NULL,  
    hora_ocurrencia         TIME          NOT NULL,  
    descripcion             VARCHAR(500)  NOT NULL,
    fecha_registro_sistema  DATE          NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    id_tipo_delito          INT           NOT NULL, 
    id_ubicacion            INT           NOT NULL, 
    id_estado               INT           NOT NULL, 
    
    CONSTRAINT PK_Incidente PRIMARY KEY (id_incidente),
    CONSTRAINT FK_Incidente_TipoDelito FOREIGN KEY (id_tipo_delito)
        REFERENCES Tipo_Delito(id_tipo_delito),
    CONSTRAINT FK_Incidente_Ubicacion FOREIGN KEY (id_ubicacion)
        REFERENCES Ubicacion(id_ubicacion),
    CONSTRAINT FK_Incidente_Estado FOREIGN KEY (id_estado)
        REFERENCES Estado_Incidente(id_estado)
);
GO

-- =========================================
-- 4. TABLA INTERMEDIA: Ciudadano_Incidente
-- =========================================
CREATE TABLE Ciudadano_Incidente (
    id_ciudadano_incidente INT IDENTITY(1,1) NOT NULL,
    rol                    VARCHAR(30) NOT NULL,   -- Víctima, Denunciante, Testigo, etc.
    id_ciudadano           INT NOT NULL,
    id_incidente           INT NOT NULL,

    CONSTRAINT PK_Ciudadano_Incidente PRIMARY KEY (id_ciudadano_incidente),
    CONSTRAINT FK_CiudInc_Ciudadano FOREIGN KEY (id_ciudadano)
        REFERENCES Ciudadano(id_ciudadano),
    CONSTRAINT FK_CiudInc_Incidente FOREIGN KEY (id_incidente)
        REFERENCES Incidente(id_incidente),
    CONSTRAINT UQ_CiudInc_Rol UNIQUE (id_ciudadano, id_incidente, rol)
);
GO

-- ===================
-- 5. TABLA: Evidencia
-- ===================
CREATE TABLE Evidencia (
    id_evidencia       INT IDENTITY(1,1) NOT NULL,
    descripcion        VARCHAR(250) NULL,
    ruta_archivo       VARCHAR(255) NOT NULL,
    id_incidente       INT NOT NULL, 
    id_tipo_evidencia  INT NOT NULL, 

    CONSTRAINT PK_Evidencia PRIMARY KEY (id_evidencia),
    CONSTRAINT FK_Evidencia_Incidente FOREIGN KEY (id_incidente)
        REFERENCES Incidente(id_incidente),
    CONSTRAINT FK_Evidencia_TipoEvidencia FOREIGN KEY (id_tipo_evidencia)
        REFERENCES Tipo_Evidencia(id_tipo_evidencia)
);
GO

-- ===============================
-- 6. TABLA: Seguimiento_Incidente
-- ===============================
CREATE TABLE Seguimiento_Incidente (
    id_seguimiento   INT IDENTITY(1,1) NOT NULL,
    fecha_hora       DATETIME     NOT NULL DEFAULT (GETDATE()),
    accion           VARCHAR(150) NOT NULL,
    observacion      VARCHAR(500) NULL,
    id_incidente     INT NOT NULL,   
    id_autoridad     INT NOT NULL,   
    id_estado        INT NOT NULL,   

    CONSTRAINT PK_Seguimiento_Incidente PRIMARY KEY (id_seguimiento),
    CONSTRAINT FK_Seguimiento_Incidente_Incidente FOREIGN KEY (id_incidente)
        REFERENCES Incidente(id_incidente),
    CONSTRAINT FK_Seguimiento_Autoridad FOREIGN KEY (id_autoridad)
        REFERENCES Autoridad(id_autoridad),
    CONSTRAINT FK_Seguimiento_Estado FOREIGN KEY (id_estado)
        REFERENCES Estado_Incidente(id_estado)
);
GO


-- ===================================
-- 7. ÍNDICES PARA OPTIMIZAR BÚSQUEDAS
-- ===================================
CREATE INDEX IX_Incidente_TipoDelito   ON Incidente(id_tipo_delito);
CREATE INDEX IX_Incidente_Ubicacion    ON Incidente(id_ubicacion);
CREATE INDEX IX_Incidente_Estado       ON Incidente(id_estado);
CREATE INDEX IX_Incidente_Fecha        ON Incidente(fecha_ocurrencia);

CREATE INDEX IX_CiudInc_Ciudadano      ON Ciudadano_Incidente(id_ciudadano);
CREATE INDEX IX_CiudInc_Incidente      ON Ciudadano_Incidente(id_incidente);

CREATE INDEX IX_Evidencia_Incidente    ON Evidencia(id_incidente);
CREATE INDEX IX_Evidencia_TipoEvid     ON Evidencia(id_tipo_evidencia);

CREATE INDEX IX_Seguimiento_Incidente  ON Seguimiento_Incidente(id_incidente);
CREATE INDEX IX_Seguimiento_Autoridad  ON Seguimiento_Incidente(id_autoridad);
CREATE INDEX IX_Seguimiento_FechaHora  ON Seguimiento_Incidente(fecha_hora);
GO

PRINT 'Base de datos SistemaDelitosPatrimonioIca creada correctamente.';
GO
