-- ============================================================
-- SCRIPT DE CREACIÓN Y MIGRACIÓN DE DATOS
-- Grupo: THE_BD_TEAM
-- Curso: K3522
-- Integrantes: Calzado, Chazarreta y Mendez Spahn
-- ============================================================

USE GD2C2025
GO

-- 1. CREACIÓN DEL ESQUEMA

CREATE SCHEMA THE_BD_TEAM;
GO

-- 2. CREACIÓN DE TABLAS

-- Dia
CREATE TABLE THE_BD_TEAM.Dia (
    id_dia BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL, --clave primaria autoincremental
    dia VARCHAR(10)
);
GO

-- Turno
CREATE TABLE THE_BD_TEAM.Turno (
    id_turno BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    turno VARCHAR(6)
);
GO

-- Categoria
CREATE TABLE THE_BD_TEAM.Categoria (
    id_categoria BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    categoria VARCHAR(15)
);
GO

-- Estado Inscripcion
CREATE TABLE THE_BD_TEAM.EstadoInscripcion (
    id_EstadoInscripcion BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    estado VARCHAR(255)
);
GO

-- Medio De Pago
CREATE TABLE THE_BD_TEAM.MedioDePago (
    id_medioDePago BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    medioPago VARCHAR(255)
);
GO

--Periodo
CREATE TABLE THE_BD_TEAM.Periodo (
    id_periodo BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    anio BIGINT,
    mes BIGINT
);
GO

-- Provincia
CREATE TABLE THE_BD_TEAM.Provincia (
    id_provincia BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    provincia VARCHAR(255)
);
GO

-- Pregunta
CREATE TABLE THE_BD_TEAM.Pregunta (
    id_pregunta BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    texto_pregunta VARCHAR(255)
);
GO

-- Institucion
CREATE TABLE THE_BD_TEAM.Institucion (
    cuit_institucion NVARCHAR(255) PRIMARY KEY NOT NULL,
    nombre NVARCHAR(255),
    razon_social NVARCHAR(255)
);
GO

--- Tablas con FK ---

-- Localidad
CREATE TABLE THE_BD_TEAM.Localidad (
    id_localidad BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    id_provincia BIGINT, -- Clave foranea que relaciona la localidad con una provincia.
    localidad VARCHAR(255),

    CONSTRAINT FK_Localidad_Provincia -- FK que enlaza la localidad con su provincia
    FOREIGN KEY (id_provincia)
    REFERENCES THE_BD_TEAM.Provincia(id_provincia)
);
GO

-- Sede
CREATE TABLE THE_BD_TEAM.Sede (
    id_sede BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    cuit_institucion nvarchar(255) NOT NULL,
    id_localidad BIGINT NOT NULL,
    nombre NVARCHAR(255),
    direccion NVARCHAR(255),
    telefono NVARCHAR(255),
    mail NVARCHAR(255),

    CONSTRAINT FK_Sede_Institucion
    FOREIGN KEY (cuit_institucion)
    REFERENCES THE_BD_TEAM.Institucion(cuit_institucion),

    CONSTRAINT FK_Sede_Localidad -- FK que enlaza la sede con su localidad (y, por ende, provincia)
    FOREIGN KEY (id_localidad)
    REFERENCES THE_BD_TEAM.Localidad(id_localidad)
);
GO

-- Profesor
CREATE TABLE THE_BD_TEAM.Profesor (
    id_profesor BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    id_localidad BIGINT NOT NULL,
    nombre NVARCHAR(255),
    apellido NVARCHAR(255),
    direccion NVARCHAR(255),
    telefono NVARCHAR(255),
    mail NVARCHAR(255),
    dni NVARCHAR(255),
    fecha_nacimiento DATETIME2(6),

    CONSTRAINT FK_Profesor_Localidad
    FOREIGN KEY (id_localidad)
    REFERENCES THE_BD_TEAM.Localidad(id_localidad)
);
GO

-- Alumno
CREATE TABLE THE_BD_TEAM.Alumno (
    legajo BIGINT PRIMARY KEY NOT NULL,
    id_localidad BIGINT NOT NULL,
    nombre VARCHAR(255),
    apellido VARCHAR(255),
    dni INT,
    fechaNacimiento DATETIME2(6),
    direccion VARCHAR(255),
    telefono VARCHAR(255),

    CONSTRAINT FK_Alumno_Localidad
    FOREIGN KEY (id_localidad)
    REFERENCES THE_BD_TEAM.Localidad(id_localidad)
);
GO

-- Curso
CREATE TABLE THE_BD_TEAM.Curso (
    cod_curso BIGINT PRIMARY KEY NOT NULL,
    id_profesor BIGINT NOT NULL,
    id_sede BIGINT NOT NULL,
    id_categoria BIGINT NOT NULL,
    id_turno BIGINT NOT NULL,
    nombre NVARCHAR(255),
    descripcion NVARCHAR(255),
    fecha_inicio DATETIME2(6),
    fecha_fin DATETIME2(6),
    duracion_meses BIGINT,
    precio_mensual DECIMAL(38,2),

    CONSTRAINT FK_Curso_Profesor
    FOREIGN KEY (id_profesor)
    REFERENCES THE_BD_TEAM.Profesor(id_profesor),

    CONSTRAINT FK_Curso_Sede
    FOREIGN KEY (id_sede)
    REFERENCES THE_BD_TEAM.Sede(id_sede),

    CONSTRAINT FK_Curso_Categoria
    FOREIGN KEY (id_categoria)
    REFERENCES THE_BD_TEAM.Categoria(id_categoria),

    CONSTRAINT FK_Curso_Turno
    FOREIGN KEY (id_turno)
    REFERENCES THE_BD_TEAM.Turno(id_turno)
);
GO

-- Modulo 
CREATE TABLE THE_BD_TEAM.Modulo (
    id_modulo BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    cod_curso BIGINT NOT NULL,
    nombre VARCHAR(255),
    descripcion VARCHAR(255)

    CONSTRAINT FK_Modulo_Curso
    FOREIGN KEY (cod_curso)
    REFERENCES THE_BD_TEAM.Curso(cod_curso),
);
GO

-- Encuesta
CREATE TABLE THE_BD_TEAM.Encuesta (
    id_encuesta BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    cod_curso BIGINT NOT NULL,
    fecha_registro DATETIME2(6),
    observacion VARCHAR(255),

    CONSTRAINT FK_Encuesta_Curso
    FOREIGN KEY (cod_curso)
    REFERENCES THE_BD_TEAM.Curso(cod_curso)
);
GO

-- Evaluacion
CREATE TABLE THE_BD_TEAM.Evaluacion (
    id_evaluacion BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    id_modulo BIGINT NOT NULL,
    fecha_evaluacion DATETIME2(6),
    instancia BIGINT,

    CONSTRAINT FK_Evaluacion_Modulo
    FOREIGN KEY (id_modulo)
    REFERENCES THE_BD_TEAM.Modulo(id_modulo)
);
GO

-- Mesa de Final
CREATE TABLE THE_BD_TEAM.Mesa_De_Final (
    id_mesa BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    cod_curso BIGINT NOT NULL,
    fecha DATETIME2(6),
    hora VARCHAR(255),
    descripcion VARCHAR(255),

    CONSTRAINT FK_MesaFinal_Curso
    FOREIGN KEY (cod_curso)
    REFERENCES THE_BD_TEAM.Curso(cod_curso)
);
GO

-- Factura
CREATE TABLE THE_BD_TEAM.Factura (
    nro_factura BIGINT PRIMARY KEY NOT NULL,
    legajo BIGINT NOT NULL,
    fecha_emision DATETIME2(6),
    fecha_vencimiento DATETIME2(6),
    importe_total DECIMAL(18,2),

    CONSTRAINT FK_Factura_Alumno
    FOREIGN KEY (legajo)
    REFERENCES THE_BD_TEAM.Alumno(legajo)
);
GO

-- Pago
CREATE TABLE THE_BD_TEAM.Pago (
    id_pago BIGINT  IDENTITY(1,1) PRIMARY KEY NOT NULL,
    nro_factura BIGINT NOT NULL,
    fecha DATETIME2(6),
    importe DECIMAL(18,2),
    
    CONSTRAINT FK_Pago_Factura
    FOREIGN KEY (nro_factura)
    REFERENCES THE_BD_TEAM.Factura(nro_factura)
);
GO

--- Tablas Intermedias ---

-- Respuesta --> Tabla Respuesta (Encuesta - Pregunta)
CREATE TABLE THE_BD_TEAM.Respuesta (
    id_respuesta BIGINT  IDENTITY(1,1) PRIMARY KEY NOT NULL,
    id_encuesta BIGINT NOT NULL, --FK a la Encuesta.
    id_pregunta  BIGINT NOT NULL, -- FK a la Pregunta.
    nota BIGINT,

    CONSTRAINT FK_Respuesta_Encuesta
    FOREIGN KEY (id_encuesta)
    REFERENCES THE_BD_TEAM.Encuesta(id_encuesta),

    CONSTRAINT FK_Respuesta_Pregunta
    FOREIGN KEY (id_pregunta)
    REFERENCES THE_BD_TEAM.Pregunta(id_pregunta)
);
GO

-- Inscripcion
CREATE TABLE THE_BD_TEAM.Inscripcion (
    nro_inscripcion BIGINT PRIMARY KEY NOT NULL,
    legajo BIGINT NOT NULL,
    cod_curso  BIGINT NOT NULL,
    id_EstadoInscripcion BIGINT NOT NULL,
    fecha_inscripcion DATETIME2(6),
    fecha_respuesta DATETIME2(6),

    CONSTRAINT FK_Inscripcion_Alumno
    FOREIGN KEY (legajo)
    REFERENCES THE_BD_TEAM.Alumno(legajo),

    CONSTRAINT FK_Inscripcion_Curso
    FOREIGN KEY (cod_curso)
    REFERENCES THE_BD_TEAM.Curso(cod_curso),

    CONSTRAINT FK_Inscripcion_EstadoInscripcion
    FOREIGN KEY (id_EstadoInscripcion)
    REFERENCES THE_BD_TEAM.EstadoInscripcion(id_EstadoInscripcion)
);
GO

-- Trabajo Practico
CREATE TABLE THE_BD_TEAM.Trabajo_Practico (
    id_tp BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    legajo BIGINT NOT NULL,
    cod_curso  BIGINT NOT NULL,
    nota BIGINT,
    fecha_evaluacion DATETIME2(6),

    CONSTRAINT FK_TrabajoPractico_Alumno
    FOREIGN KEY (legajo)
    REFERENCES THE_BD_TEAM.Alumno(legajo),

    CONSTRAINT FK_TrabajoPractico_Curso
    FOREIGN KEY (cod_curso)
    REFERENCES THE_BD_TEAM.Curso(cod_curso)
);
GO

-- Inscripcion Final
CREATE TABLE THE_BD_TEAM.Inscripcion_Final (
    nro_inscripcion BIGINT PRIMARY KEY NOT NULL,
    legajo BIGINT NOT NULL,
    id_mesa  BIGINT NOT NULL,
    fecha_inscripcion DATETIME2(6),

    CONSTRAINT FK_InscripcionFinal_Alumno
    FOREIGN KEY (legajo)
    REFERENCES THE_BD_TEAM.Alumno(legajo),

    CONSTRAINT FK_InscripcionFinal_Mesa
    FOREIGN KEY (id_mesa)
    REFERENCES THE_BD_TEAM.Mesa_De_Final(id_mesa)
);
GO

-- Examen Final
CREATE TABLE THE_BD_TEAM.Examen_Final (
    id_final BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    legajo BIGINT NOT NULL,
    id_mesa  BIGINT NOT NULL,
    id_profesor BIGINT NOT NULL,
    nota BIGINT,
    presente BIT,

    CONSTRAINT FK_ExamenFinal_Alumno
    FOREIGN KEY (legajo)
    REFERENCES THE_BD_TEAM.Alumno(legajo),

    CONSTRAINT FK_ExamenFinal_Mesa
    FOREIGN KEY (id_mesa)
    REFERENCES THE_BD_TEAM.Mesa_De_Final(id_mesa),

    CONSTRAINT FK_ExamenFinal_Profesor
    FOREIGN KEY (id_profesor)
    REFERENCES THE_BD_TEAM.Profesor(id_profesor)
);
GO

-- Detalle Factura
CREATE TABLE THE_BD_TEAM.Detalle_Factura (
    id_detalleFactura BIGINT  IDENTITY(1,1) PRIMARY KEY NOT NULL,
    cod_curso BIGINT NOT NULL,
    nro_factura  BIGINT NOT NULL,
    id_periodo BIGINT NOT NULL,
    importe DECIMAL(18,2),

    CONSTRAINT FK_DetalleFactura_Curso
    FOREIGN KEY (cod_curso)
    REFERENCES THE_BD_TEAM.Curso(cod_curso),

    CONSTRAINT FK_DetalleFactura_Factura
    FOREIGN KEY (nro_factura)
    REFERENCES THE_BD_TEAM.Factura(nro_factura),

    CONSTRAINT FK_DetalleFactura_Periodo
    FOREIGN KEY (id_periodo)
    REFERENCES THE_BD_TEAM.Periodo(id_periodo)
);
GO

-- Dia X Curso
CREATE TABLE THE_BD_TEAM.DiaXCurso (
    id_dia BIGINT NOT NULL, -- FK al Día.
    cod_curso BIGINT NOT NULL, -- FK al Curso.

    CONSTRAINT PK_DiaXCurso -- Define la clave primaria compuesta por las dos FK.
    PRIMARY KEY (id_dia, cod_curso),

    CONSTRAINT FK_DiaXCurso_Dia 
    FOREIGN KEY (id_dia)
    REFERENCES THE_BD_TEAM.Dia(id_dia),

    CONSTRAINT FK_DiaXCurso_Curso 
    FOREIGN KEY (cod_curso)
    REFERENCES THE_BD_TEAM.Curso(cod_curso)
);
GO

-- Pago X Medio de Pago
CREATE TABLE THE_BD_TEAM.PagoXMedioDePago (
    id_medioDePago BIGINT NOT NULL,
    id_pago BIGINT NOT NULL,

    CONSTRAINT PK_PagoXMedioDePago 
    PRIMARY KEY (id_medioDePago, id_pago),

    CONSTRAINT FK_PagoXMedioDePago_MedioDePago 
    FOREIGN KEY (id_medioDePago)
    REFERENCES THE_BD_TEAM.MedioDePago(id_medioDePago),

    CONSTRAINT FK_PagoXMedioDePago_Pago 
    FOREIGN KEY (id_pago)
    REFERENCES THE_BD_TEAM.Pago(id_pago)
);
GO

-- Alumno X Evaluacion
CREATE TABLE THE_BD_TEAM.AlumnoXEvaluacion (
    legajo BIGINT NOT NULL,
    id_evaluacion BIGINT NOT NULL,
    nota BIGINT,
    presente BIT,

    CONSTRAINT PK_AlumnoXEvaluacion 
    PRIMARY KEY (legajo, id_evaluacion),

    CONSTRAINT FK_AlumnoXEvaluacion_Alumno
    FOREIGN KEY (legajo)
    REFERENCES THE_BD_TEAM.Alumno(legajo),

    CONSTRAINT FK_AlumnoXEvaluacion_Evaluacion
    FOREIGN KEY (id_evaluacion)
    REFERENCES THE_BD_TEAM.Evaluacion(id_evaluacion)
);
GO

-- 3. CREACIÓN DE STORED PROCEDURES DE MIGRACIÓN

-- Dia
CREATE PROCEDURE THE_BD_TEAM.MigrarDia --Procedimiento para migrar la tabla Dia
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Dia (dia) 
    
    SELECT DISTINCT Curso_Dia
    FROM gd_esquema.maestra
    WHERE Curso_Dia IS NOT NULL
END;
GO

-- Turno
CREATE PROCEDURE THE_BD_TEAM.MigrarTurno 
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Turno (turno)
    
    SELECT DISTINCT Curso_Turno
    FROM gd_esquema.maestra
    WHERE Curso_Turno IS NOT NULL
END;
GO

-- Categoria
CREATE PROCEDURE THE_BD_TEAM.MigrarCategoria 
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Categoria(categoria)
    
    SELECT DISTINCT Curso_Categoria
    FROM gd_esquema.maestra
    WHERE Curso_Categoria IS NOT NULL
END;
GO

-- Estado Inscripcion
CREATE PROCEDURE THE_BD_TEAM.MigrarEstadoInscripcion 
AS
BEGIN
    INSERT INTO THE_BD_TEAM.EstadoInscripcion(estado)
    
    SELECT DISTINCT Inscripcion_Estado
    FROM gd_esquema.maestra
    WHERE Inscripcion_Estado IS NOT NULL
END;
GO

-- Medio De Pago
CREATE PROCEDURE THE_BD_TEAM.MigrarMedioDePago 
AS
BEGIN
    INSERT INTO THE_BD_TEAM.MedioDePago(medioPago)
    
    SELECT DISTINCT Pago_MedioPago
    FROM gd_esquema.maestra
    WHERE Pago_MedioPago IS NOT NULL
END;
GO

--Periodo
CREATE PROCEDURE THE_BD_TEAM.MigrarPeriodo 
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Periodo(anio, mes)
    
    SELECT DISTINCT Periodo_Anio, Periodo_Mes
    FROM gd_esquema.maestra
    WHERE Periodo_Anio IS NOT NULL
    AND Periodo_Mes IS NOT NULL
END;
GO

-- Provincia
CREATE PROCEDURE THE_BD_TEAM.MigrarProvincia
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Provincia(provincia)
    
    SELECT DISTINCT Alumno_Provincia
    FROM gd_esquema.maestra
    WHERE Alumno_Provincia IS NOT NULL
    
    UNION -- Combina las provincias distintas encontradas en los campos de Alumno, Sede y Profesor.
    
    SELECT DISTINCT Sede_Localidad
    FROM gd_esquema.maestra
    WHERE Sede_Localidad IS NOT NULL
    
    UNION
    
    SELECT DISTINCT Profesor_Provincia
    FROM gd_esquema.maestra
    WHERE Profesor_Provincia IS NOT NULL
END;
GO

-- Pregunta
CREATE PROCEDURE THE_BD_TEAM.MigrarPregunta
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Pregunta(texto_pregunta)
    
    SELECT DISTINCT Encuesta_Pregunta1
    FROM gd_esquema.maestra
    WHERE Encuesta_Pregunta1 IS NOT NULL
    
    UNION
    
    SELECT DISTINCT Encuesta_Pregunta2
    FROM gd_esquema.maestra
    WHERE Encuesta_Pregunta2 IS NOT NULL
END;
GO

-- Institucion
CREATE PROCEDURE THE_BD_TEAM.MigrarInstitucion
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Institucion
    (cuit_institucion, nombre, razon_social)

    SELECT DISTINCT Institucion_Cuit, Institucion_Nombre, Institucion_RazonSocial
    FROM gd_esquema.maestra
    WHERE Institucion_Cuit IS NOT NULL
    AND Institucion_Nombre IS NOT NULL
    AND Institucion_RazonSocial IS NOT NULL
END;
GO

-- Localidad
CREATE PROCEDURE THE_BD_TEAM.MigrarLocalidad
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Localidad
    (id_provincia, localidad)
    
    SELECT DISTINCT p.id_provincia, m.Alumno_Localidad
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Provincia p
        ON (p.provincia = m.Alumno_Provincia)
    WHERE Alumno_Localidad IS NOT NULL
    UNION

    SELECT DISTINCT p.id_provincia, m.Sede_Provincia
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Provincia p
        ON (p.provincia = m.Sede_Localidad)
    WHERE Sede_Provincia IS NOT NULL

    UNION

    SELECT DISTINCT p.id_provincia, m.Profesor_Localidad
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Provincia p
        ON (p.provincia = m.Profesor_Provincia)
    WHERE Profesor_Localidad IS NOT NULL
END;
GO

-- Sede
CREATE PROCEDURE THE_BD_TEAM.MigrarSede
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Sede
    (cuit_institucion, id_localidad, nombre, direccion, telefono, mail)
    
    SELECT DISTINCT m.Institucion_Cuit, l.id_localidad, m.Sede_Nombre,
                    m.Sede_Direccion, m.Sede_Telefono, m.Sede_Mail
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Localidad l
        ON (l.localidad = m.Sede_Provincia
        AND l.id_provincia = (
            SELECT p.id_provincia
            FROM THE_BD_TEAM.Provincia p
            WHERE p.provincia = m.Sede_Localidad
        ))
END;
GO

-- Profesor
CREATE PROCEDURE THE_BD_TEAM.MigrarProfesor
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Profesor
    (id_localidad, nombre, apellido, direccion, telefono, mail, dni, fecha_nacimiento)
    
    SELECT DISTINCT l.id_localidad, m.Profesor_Apellido, m.Profesor_nombre,
                    m.Profesor_Direccion, m.Profesor_Telefono, m.Profesor_Mail,
                    m.Profesor_Dni, m.Profesor_FechaNacimiento
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Localidad l
        ON (l.localidad = m.Profesor_Localidad
        AND l.id_provincia = (
            SELECT p.id_provincia
            FROM THE_BD_TEAM.Provincia p
            WHERE p.provincia = m.Profesor_Provincia
        ))
END;
GO

-- Alumno
CREATE PROCEDURE THE_BD_TEAM.MigrarAlumno
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Alumno
    (legajo, id_localidad, nombre, apellido, dni, fechaNacimiento, direccion, telefono)
    
    SELECT DISTINCT m.Alumno_Legajo, l.id_localidad, m.Alumno_Nombre, m.Alumno_Apellido,
                    m.Alumno_Dni, m.Alumno_FechaNacimiento, 
                    m.Alumno_Direccion, m.Alumno_Telefono
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Localidad l
        ON (l.localidad = m.Alumno_Localidad
        AND l.id_provincia = (
            SELECT p.id_provincia
            FROM THE_BD_TEAM.Provincia p
            WHERE p.provincia = m.Alumno_Provincia
     ))
END;
GO

-- Curso
CREATE PROCEDURE THE_BD_TEAM.MigrarCurso
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Curso
    (cod_curso, id_profesor, id_sede, id_categoria, id_turno, 
    nombre, descripcion, fecha_inicio, fecha_fin, duracion_meses, precio_mensual)
    
    SELECT DISTINCT m.Curso_Codigo, p.id_profesor, s.id_sede,
                    ca.id_categoria, t.id_turno, m.Curso_Nombre, m.Curso_Descripcion,
                    m.Curso_FechaInicio, m.Curso_FechaFin, m.Curso_DuracionMeses, 
                    m.Curso_PrecioMensual
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Profesor p -- Une con Profesor para obtener id_profesor (usando DNI).
        ON (p.dni = m.Profesor_Dni)
    JOIN THE_BD_TEAM.Sede s -- Une con Sede para obtener id_sede (usando nombre y dirección).
        ON (s.nombre = m.Sede_Nombre
        AND s.direccion = m.Sede_Direccion)
    JOIN THE_BD_TEAM.Categoria ca -- Une con Categoria para obtener id_categoria (usando nombre de categoría).
        ON (ca.categoria = m.Curso_Categoria)
    JOIN THE_BD_TEAM.Turno t -- Une con Turno para obtener id_turno (usando nombre del turno).
        ON (t.turno = m.Curso_Turno)
END;
GO

-- Modulo 
CREATE PROCEDURE THE_BD_TEAM.MigrarModulo
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Modulo(cod_curso, nombre, descripcion)
    
    SELECT DISTINCT c.cod_curso, m.Modulo_Nombre, m.Modulo_Descripcion
    FROM gd_esquema.maestra m
    JOIN THE_BD_TEAM.Curso c 
        ON (c.cod_curso = m.Curso_Codigo) 
    WHERE m.Modulo_Nombre IS NOT NULL
    AND m.Modulo_Descripcion IS NOT NULL
END;
GO

-- Encuesta
CREATE PROCEDURE THE_BD_TEAM.MigrarEncuesta
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Encuesta
    (cod_curso, fecha_registro, observacion)
    
    SELECT DISTINCT c.cod_curso, m.Encuesta_FechaRegistro,
                    m.Encuesta_Observacion
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Curso c
        ON (c.cod_curso = m.Curso_Codigo)
END;
GO

-- Evaluacion
CREATE PROCEDURE THE_BD_TEAM.MigrarEvaluacion
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Evaluacion
    (id_modulo, fecha_evaluacion, instancia)
    
    SELECT DISTINCT mo.id_modulo, m.Evaluacion_Curso_fechaEvaluacion,
                    m.Evaluacion_Curso_Instancia
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Modulo mo
        ON (mo.nombre = m.Modulo_Nombre)
END;
GO

-- Mesa de Final
CREATE PROCEDURE THE_BD_TEAM.MigrarMesaDeFinal
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Mesa_De_Final
    (cod_curso, fecha, hora, descripcion)
    
    SELECT DISTINCT c.cod_curso, m.Examen_Final_Fecha, 
                    m.Examen_Final_Hora, m.Examen_Final_Descripcion
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Curso c
        ON (c.cod_curso = m.Curso_Codigo)
END;
GO

-- Factura 
CREATE PROCEDURE THE_BD_TEAM.MigrarFactura
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Factura
    (nro_factura, legajo, fecha_emision, fecha_vencimiento , importe_total)

    SELECT DISTINCT m.Factura_Numero, a.legajo, m.Factura_FechaEmision,
                    m.Factura_FechaVencimiento, m.Factura_Total
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Alumno a
        ON (a.legajo = m.Alumno_Legajo)
    WHERE m.Factura_Numero IS NOT NULL
END;
GO

-- Pago
CREATE PROCEDURE THE_BD_TEAM.MigrarPago
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Pago
    (nro_factura, fecha, importe)
    SELECT DISTINCT f.nro_factura, m.Pago_Fecha, m.Pago_Importe 
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Factura f
        ON (f.nro_factura = m.Factura_Numero)
    WHERE m.Pago_Fecha IS NOT NULL
END;
GO

-- Respuesta
CREATE PROCEDURE THE_BD_TEAM.MigrarRespuesta
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Respuesta 
    (id_encuesta, id_pregunta, nota)
    
    -- Respuestas para la Pregunta 1
    SELECT DISTINCT e.id_encuesta, p.id_pregunta, m.Encuesta_Nota1
    FROM gd_esquema.maestra m
    JOIN THE_BD_TEAM.Encuesta e
        ON (e.fecha_registro = m.Encuesta_FechaRegistro
        AND e.observacion = m.Encuesta_Observacion)
    JOIN THE_BD_TEAM.Pregunta p
        ON (p.texto_pregunta = m.Encuesta_Pregunta1)

    UNION
    
    -- Respuestas para la Pregunta 2
    SELECT DISTINCT e.id_encuesta, p.id_pregunta, m.Encuesta_Nota2
    FROM gd_esquema.maestra m
    JOIN THE_BD_TEAM.Encuesta e
        ON (e.fecha_registro = m.Encuesta_FechaRegistro
        AND e.observacion = m.Encuesta_Observacion)
    JOIN THE_BD_TEAM.Pregunta p
        ON (p.texto_pregunta = m.Encuesta_Pregunta2)

    UNION

    -- Respuestas para la Pregunta 3
    SELECT DISTINCT e.id_encuesta, p.id_pregunta, m.Encuesta_Nota3
    FROM gd_esquema.maestra m
    JOIN THE_BD_TEAM.Encuesta e
        ON (e.fecha_registro = m.Encuesta_FechaRegistro
        AND e.observacion = m.Encuesta_Observacion)
    JOIN THE_BD_TEAM.Pregunta p
        ON (p.texto_pregunta = m.Encuesta_Pregunta3)
        
    UNION

    -- Respuestas para la Pregunta 4
    SELECT e.id_encuesta, p.id_pregunta, m.Encuesta_Nota4
    FROM gd_esquema.maestra m
    JOIN THE_BD_TEAM.Encuesta e
        ON (e.fecha_registro = m.Encuesta_FechaRegistro
        AND e.observacion = m.Encuesta_Observacion)
    JOIN THE_BD_TEAM.Pregunta p
        ON (p.texto_pregunta = m.Encuesta_Pregunta4)
END;
GO

-- Inscripcion
CREATE PROCEDURE THE_BD_TEAM.MigrarInscripcion
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Inscripcion
    (nro_inscripcion, legajo, cod_curso, id_EstadoInscripcion, fecha_inscripcion, fecha_respuesta)
    
    SELECT DISTINCT m.Inscripcion_Numero, a.legajo, c.cod_curso,
                    e.id_EstadoInscripcion, m.Inscripcion_Fecha, 
                    m.Inscripcion_FechaRespuesta
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Alumno a
        ON (a.legajo = m.Alumno_Legajo)
    JOIN THE_BD_TEAM.Curso c
        ON (c.cod_curso = m.Curso_Codigo)
    JOIN THE_BD_TEAM.EstadoInscripcion e
        ON (e.estado = m.Inscripcion_Estado)
END;
GO

-- Trabajo Practico
CREATE PROCEDURE THE_BD_TEAM.MigrarTrabajoPractico
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Trabajo_Practico
    (legajo, cod_curso, nota, fecha_evaluacion)
    
    SELECT DISTINCT a.legajo, c.cod_curso, m.Trabajo_Practico_Nota,
                    m.Trabajo_Practico_FechaEvaluacion
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Alumno a
        ON (a.legajo = m.Alumno_Legajo)
    JOIN THE_BD_TEAM.Curso c
        ON (c.cod_curso = m.Curso_Codigo)
END;
GO

-- Inscripcion Final
CREATE PROCEDURE THE_BD_TEAM.MigrarInscripcionFinal
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Inscripcion_Final
    (nro_inscripcion, legajo, id_mesa, fecha_inscripcion)
    
    SELECT DISTINCT m.Inscripcion_Final_Nro, a.legajo, 
                    mf.id_mesa, m.Inscripcion_Final_Fecha
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Alumno a
        ON (a.legajo = m.Alumno_Legajo)
    JOIN THE_BD_TEAM.Curso c
        ON (c.cod_curso = m.Curso_Codigo)
    JOIN THE_BD_TEAM.Mesa_De_Final mf
        ON (mf.fecha = m.Examen_Final_Fecha
        AND mf.hora = m.Examen_Final_Hora
        AND mf.cod_curso = c.cod_curso)
    WHERE m.Inscripcion_Final_Nro IS NOT NULL
END;
GO

-- Examen Final
CREATE PROCEDURE THE_BD_TEAM.MigrarExamenFinal
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Examen_Final
    (legajo, id_mesa, id_profesor, nota, presente)
    
    SELECT DISTINCT a.legajo, mf.id_mesa, p.id_profesor, m.Evaluacion_Final_Nota,
                     m.Evaluacion_Final_Presente
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Alumno a
        ON (a.legajo = m.Alumno_Legajo)
    JOIN THE_BD_TEAM.Curso c
        ON (c.cod_curso = m.Curso_Codigo)
    JOIN THE_BD_TEAM.Mesa_De_Final mf
        ON (mf.fecha = m.Examen_Final_Fecha
        AND mf.hora = m.Examen_Final_Hora
        AND mf.cod_curso = c.cod_curso)
    JOIN THE_BD_TEAM.Profesor p
        ON (p.dni = m.Profesor_Dni)
    WHERE m.Evaluacion_Final_Presente IS NOT NULL
END;
GO

-- Detalle Factura
CREATE PROCEDURE THE_BD_TEAM.MigrarDetalleFactura
AS
BEGIN
    INSERT INTO THE_BD_TEAM.Detalle_Factura
    (cod_curso, nro_factura, id_periodo, importe)
    
    SELECT DISTINCT c.cod_curso, f.nro_factura, p.id_periodo,
                    m.Detalle_Factura_Importe
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Curso c
        ON (c.cod_curso = m.Curso_Codigo)
    JOIN THE_BD_TEAM.Factura f
        ON (f.nro_factura = m.Factura_Numero)
    JOIN THE_BD_TEAM.Periodo p
        ON (p.anio = m.Periodo_Anio
        AND p.mes = m.Periodo_Mes)
END;
GO

-- Dia X Curso
CREATE PROCEDURE THE_BD_TEAM.MigrarDiaXCurso
AS
BEGIN
    INSERT INTO THE_BD_TEAM.DiaXCurso
    (id_dia, cod_curso)
    
    SELECT DISTINCT d.id_dia, c.cod_curso
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.Dia d
        ON (d.dia = m.Curso_Dia)
    JOIN THE_BD_TEAM.Curso c
        ON (c.cod_curso = m.Curso_Codigo)
END;
GO
-- Pago X Medio de Pago
CREATE PROCEDURE THE_BD_TEAM.MigrarPagoXMedioDePago
AS
BEGIN
    INSERT INTO THE_BD_TEAM.PagoXMedioDePago
    (id_medioDePago, id_pago)
    
    SELECT DISTINCT mp.id_medioDePago, p.id_pago
    FROM gd_esquema.maestra m 
    JOIN THE_BD_TEAM.MedioDePago mp
        ON (mp.medioPago = m.Pago_MedioPago)
    JOIN THE_BD_TEAM.Pago p
        ON (p.fecha = m.Pago_Fecha
        AND p.importe = m.Pago_Importe)
END;
GO

-- Alumno X Evaluacion
CREATE PROCEDURE THE_BD_TEAM.MigrarAlumnoXEvaluacion
AS
BEGIN
    INSERT INTO THE_BD_TEAM.AlumnoXEvaluacion
    (legajo, id_evaluacion, nota, presente)
    
    SELECT DISTINCT a.legajo, e.id_evaluacion, m.Evaluacion_Curso_Nota, 
                    m.Evaluacion_Curso_Presente
    FROM gd_esquema.maestra m
    JOIN THE_BD_TEAM.Alumno a
        ON a.legajo = m.Alumno_Legajo
    JOIN THE_BD_TEAM.Curso cu
        ON cu.cod_curso = m.Curso_Codigo
    JOIN THE_BD_TEAM.Modulo mo
        ON mo.cod_curso = cu.cod_curso
       AND mo.nombre = m.Modulo_Nombre
    JOIN THE_BD_TEAM.Evaluacion e
        ON e.id_modulo = mo.id_modulo
       AND e.fecha_evaluacion = m.Evaluacion_Curso_fechaEvaluacion
       AND e.instancia = m.Evaluacion_Curso_Instancia

    WHERE m.Evaluacion_Curso_Presente IS NOT NULL
    
END;
GO

-- 4. EJECUCIÓN DE LAS MIGRACIONES 

BEGIN TRY 
    BEGIN TRAN --transaccion para asegurar que todos los datos se migren correctamente o que no se migre nada en caso de error.

        EXEC THE_BD_TEAM.MigrarDia;
        EXEC THE_BD_TEAM.MigrarTurno;
        EXEC THE_BD_TEAM.MigrarCategoria;
        EXEC THE_BD_TEAM.MigrarEstadoInscripcion;
        EXEC THE_BD_TEAM.MigrarMedioDePago;
        EXEC THE_BD_TEAM.MigrarPeriodo;
        EXEC THE_BD_TEAM.MigrarProvincia;
        EXEC THE_BD_TEAM.MigrarPregunta;
        EXEC THE_BD_TEAM.MigrarInstitucion;
        EXEC THE_BD_TEAM.MigrarLocalidad;
        EXEC THE_BD_TEAM.MigrarSede;
        EXEC THE_BD_TEAM.MigrarProfesor;
        EXEC THE_BD_TEAM.MigrarAlumno;
        EXEC THE_BD_TEAM.MigrarCurso;
        EXEC THE_BD_TEAM.MigrarModulo;
        EXEC THE_BD_TEAM.MigrarEncuesta;
        EXEC THE_BD_TEAM.MigrarEvaluacion;
        EXEC THE_BD_TEAM.MigrarMesaDeFinal;
        EXEC THE_BD_TEAM.MigrarFactura;
        EXEC THE_BD_TEAM.MigrarPago;
        EXEC THE_BD_TEAM.MigrarRespuesta;
        EXEC THE_BD_TEAM.MigrarInscripcion;
        EXEC THE_BD_TEAM.MigrarTrabajoPractico;
        EXEC THE_BD_TEAM.MigrarInscripcionFinal;
        EXEC THE_BD_TEAM.MigrarExamenFinal;
        EXEC THE_BD_TEAM.MigrarDetalleFactura;
        EXEC THE_BD_TEAM.MigrarDiaXCurso;
        EXEC THE_BD_TEAM.MigrarPagoXMedioDePago;
        EXEC THE_BD_TEAM.MigrarAlumnoXEvaluacion;

    COMMIT TRAN
END TRY
BEGIN CATCH

    ROLLBACK TRAN
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT 'Error en migración: ' + @ErrorMessage;

END CATCH