-- ============================================================
-- SCRIPT DE CREACIÓN Y MIGRACIÓN DE DATOS BI
-- Grupo: THE_BD_TEAM
-- Curso: K3522
-- Integrantes: Calzado, Chazarreta y Mendez Spahn
-- ============================================================

USE GD2C2025
GO

IF NOT EXISTS (SELECT * 
               FROM   sys.schemas 
               WHERE  name = 'THE_BD_TEAM') 
  BEGIN 
      EXEC ('CREATE SCHEMA THE_BD_TEAM')
  END 

GO

---------------------
---- Dimensiones ----
---------------------

-- Sede
CREATE TABLE THE_BD_TEAM.BI_Sede (
    id_sede BIGINT PRIMARY KEY NOT NULL, 
    nombre NVARCHAR(255)
);
GO

-- Curso
CREATE TABLE THE_BD_TEAM.BI_Curso (
    id_curso BIGINT PRIMARY KEY NOT NULL, 
    turno VARCHAR(6),
    categoria VARCHAR(15)
);
GO

-- Tiempo
CREATE TABLE THE_BD_TEAM.BI_Tiempo (
    id_tiempo BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    anio BIGINT,
    mes BIGINT,
    cuatrimestre BIGINT
);
GO

-- Alumno
CREATE TABLE THE_BD_TEAM.BI_Alumno (
    legajo BIGINT PRIMARY KEY NOT NULL, 
    rango_etario NVARCHAR(255)
);
GO

-- Profesor
CREATE TABLE THE_BD_TEAM.BI_Profesor (
    id_profesor BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
    rango_etario NVARCHAR(255)
);
GO

-----------------------
---- Funciones Aux ----
-----------------------

-- Tiempo
CREATE FUNCTION THE_BD_TEAM.BI_Obtener_Id_Tiempo(@fecha DATE) 
RETURNS INT 
AS 
BEGIN
    DECLARE @id INT;

    SELECT @id = id_tiempo
    FROM THE_BD_TEAM.BI_Tiempo
    WHERE anio = YEAR(@fecha)
      AND mes = MONTH(@fecha);

    RETURN @id;
END;
GO

-- Rango etario
CREATE FUNCTION THE_BD_TEAM.BI_Obtener_Rango_Etario(@fecha_nacimiento DATE) 
RETURNS NVARCHAR(20) 
AS 
BEGIN 
    DECLARE @edad INT;
    IF @fecha_nacimiento IS NULL RETURN NULL;

    SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());

    IF @edad < 25 RETURN '<25';
    IF @edad BETWEEN 25 AND 35 RETURN '25-35';
    IF @edad BETWEEN 36 AND 50 RETURN '35-50';
    RETURN '>50';
END;
GO

CREATE FUNCTION THE_BD_TEAM.BI_Notas_Cursada(@legajo BIGINT, @cod_curso BIGINT)
RETURNS TABLE
AS
RETURN
(
    -- notas de módulos
    SELECT axe.nota
    FROM THE_BD_TEAM.AlumnoXEvaluacion axe
    JOIN THE_BD_TEAM.Evaluacion ev 
        ON ev.id_evaluacion = axe.id_evaluacion
    JOIN THE_BD_TEAM.Modulo m
        ON m.id_modulo = ev.id_modulo
    WHERE axe.legajo = @legajo
      AND m.cod_curso = @cod_curso

    UNION ALL
    
    -- nota TP    
    SELECT tp.nota
    FROM THE_BD_TEAM.Trabajo_Practico tp
    WHERE tp.legajo = @legajo
      AND tp.cod_curso = @cod_curso
);
GO

----------------
---- Hechos ----
----------------

-- Inscripcion
CREATE TABLE THE_BD_TEAM.BI_Hecho_Inscripcion (
    id_inscripcion BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    id_curso BIGINT,
    id_sede BIGINT,
    id_tiempo BIGINT,
    legajo BIGINT,
    estado VARCHAR(255)

    CONSTRAINT FK_BI_Inscripcion_Curso
    FOREIGN KEY (id_curso)
    REFERENCES THE_BD_TEAM.BI_Curso(id_curso),

    CONSTRAINT FK_BI_Inscripcion_Sede
    FOREIGN KEY (id_sede)
    REFERENCES THE_BD_TEAM.BI_Sede(id_sede),

    CONSTRAINT FK_BI_Inscripcion_Tiempo
    FOREIGN KEY (id_tiempo)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo), 

    CONSTRAINT FK_BI_Inscripcion_Alumno
    FOREIGN KEY (legajo)
    REFERENCES THE_BD_TEAM.BI_Alumno(legajo)
);
GO

-- Cursada
CREATE TABLE THE_BD_TEAM.BI_Hecho_Cursada (
    id_cursada BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    id_curso BIGINT,
    id_sede BIGINT,
    id_tiempo BIGINT,
    legajo BIGINT,
    nota_promedio DECIMAL(4,2),
    aprobo_cursada BIT,


    CONSTRAINT FK_BI_Inscripcion_Curso
    FOREIGN KEY (id_curso)
    REFERENCES THE_BD_TEAM.BI_Curso(id_curso),

    CONSTRAINT FK_BI_Inscripcion_Sede
    FOREIGN KEY (id_sede)
    REFERENCES THE_BD_TEAM.BI_Sede(id_sede),

    CONSTRAINT FK_BI_Inscripcion_Tiempo
    FOREIGN KEY (id_tiempo)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo),

    CONSTRAINT FK_BI_Inscripcion_Alumno
    FOREIGN KEY (legajo)
    REFERENCES THE_BD_TEAM.BI_Alumno(legajo)
);
GO


------------------------------
---- Procedures Migración ----
------------------------------

-- Sede
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarSede
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Sede
    (id_sede, nombre)
    
    SELECT DISTINCT s.id_sede, s.nombre
    FROM THE_BD_TEAM.Sede s
       
END;
GO

-- Curso
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarCurso
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Curso
    (id_curso, turno, categoria)
    
    SELECT DISTINCT c.cod_curso , t.turno, ca.categoria
    FROM THE_BD_TEAM.Curso c
        JOIN THE_BD_TEAM.Turno t
        ON (t.id_turno = c.id_turno)
        JOIN THE_BD_TEAM.Categoria ca
        ON (ca.id_categoria = c.id_categoria)
END;
GO

-- Tiempo
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarTiempo
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Tiempo (anio, mes, cuatrimestre)
    SELECT DISTINCT
        YEAR(fechas.fecha) AS anio,
        MONTH(fechas.fecha) AS mes,
        CASE 
            WHEN MONTH(fechas.fecha) BETWEEN 1 AND 6 THEN 1
            ELSE 2
        END AS cuatrimestre
    FROM (
            SELECT fecha_inscripcion AS fecha
            FROM THE_BD_TEAM.Inscripcion
            WHERE fecha_inscripcion IS NOT NULL

            UNION

            SELECT fecha AS fecha
            FROM THE_BD_TEAM.Mesa_De_Final
            WHERE fecha IS NOT NULL

            UNION

            SELECT fecha AS fecha
            FROM THE_BD_TEAM.Pago
            WHERE fecha IS NOT NULL

            UNION

            SELECT fecha_emision AS fecha
            FROM THE_BD_TEAM.Factura
            WHERE fecha_emision IS NOT NULL

            UNION

            SELECT fecha_evaluacion AS fecha
            FROM THE_BD_TEAM.Evaluacion
            WHERE fecha_evaluacion IS NOT NULL

            UNION

            SELECT fecha_evaluacion AS fecha
            FROM THE_BD_TEAM.Trabajo_Practico
            WHERE fecha_evaluacion IS NOT NULL

            UNION

            SELECT fecha_registro AS fecha
            FROM THE_BD_TEAM.Encuesta
            WHERE fecha_registro IS NOT NULL
    ) AS fechas;
       
END;
GO

-- Alumno
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarAlumno
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Alumno (legajo, rango_etario)
    SELECT DISTINCT
        a.legajo,
        THE_BD_TEAM.BI_Obtener_Rango_Etario(a.fechaNacimiento)
    FROM THE_BD_TEAM.Alumno a
    WHERE a.legajo IS NOT NULL;
END;
GO

-- Profesor
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarProfesor
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Profesor (id_profesor, rango_etario)
    SELECT DISTINCT
        p.id_profesor,
        THE_BD_TEAM.BI_Obtener_Rango_Etario(p.fecha_nacimiento)
    FROM THE_BD_TEAM.Profesor p
    WHERE p.id_profesor IS NOT NULL;
END;
GO

-- Inscripcion
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarInscripcion
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Hecho_Inscripcion
    (id_curso, id_sede, legajo, estado, id_tiempo)
   
    SELECT i.cod_curso, c.id_sede, i.legajo, ei.estado,
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(i.fecha_inscripcion)
        
    FROM THE_BD_TEAM.Inscripcion i
        JOIN THE_BD_TEAM.Curso c 
        ON (c.cod_curso = i.cod_curso)
        JOIN THE_BD_TEAM.EstadoInscripcion ei 
        ON (ei.id_EstadoInscripcion = i.id_EstadoInscripcion)
END;
GO

CREATE PROCEDURE THE_BD_TEAM.BI_MigrarCursada
AS
BEGIN

    INSERT INTO THE_BD_TEAM.BI_Hecho_Cursada 
    (id_curso, id_sede, legajo, id_tiempo, nota_promedio, aprobo_cursada)
   
    SELECT c.cod_curso, c.id_sede, tp.legajo,    
           THE_BD_TEAM.BI_Obtener_Id_Tiempo(tp.fecha_evaluacion), 
           
       /* PROMEDIO */
        (SELECT AVG(CONVERT(decimal(10,2), nota))
         FROM THE_BD_TEAM.BI_Notas_Cursada(tp.legajo, tp.cod_curso)
        ) AS nota_promedio,

        /* APROBADO ? (todas >= 4) */
        CASE 
            WHEN (
                SELECT MIN(nota)
                FROM THE_BD_TEAM.BI_Notas_Cursada(tp.legajo, tp.cod_curso)
            ) >= 4
            THEN 1 ELSE 0
        END AS aprobo_cursada

    FROM THE_BD_TEAM.Trabajo_Practico tp
        JOIN THE_BD_TEAM.Curso c
        ON (c.cod_curso = tp.cod_curso)

END;
GO

----------------
---- Vistas ----
----------------

-- Vista 1
CREATE VIEW THE_BD_TEAM.BI_V_CategoriasYTurnosMasSolicitados
AS
SELECT sede, anio, categoria, turno, cantidad_inscriptos
FROM (
        SELECT 
            s.nombre AS sede,
            t.anio,
            c.categoria,
            c.turno,
            COUNT(*) AS cantidad_inscriptos,
            ROW_NUMBER() OVER (
                PARTITION BY s.nombre, t.anio
                ORDER BY COUNT(*) DESC
            ) AS rn
        FROM THE_BD_TEAM.BI_Hecho_Inscripcion i
            JOIN THE_BD_TEAM.BI_Curso c
            ON (c.id_curso = i.id_curso)
            JOIN THE_BD_TEAM.BI_Sede s
            ON (s.id_sede = i.id_sede)
            JOIN THE_BD_TEAM.BI_Tiempo t
            ON (t.id_tiempo = i.id_tiempo)
        GROUP BY s.nombre, t.anio, c.categoria, c.turno
    ) AS ranking
WHERE rn <= 3;
GO

-- Vista 2
CREATE VIEW THE_BD_TEAM.BI_V_TasaRechazoInscripciones
AS
SELECT
    s.nombre AS sede,
    t.anio,
    t.mes,
    CAST(
        SUM(CASE WHEN i.estado = 'RECHAZADA' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*) 
    AS DECIMAL(10,2)) AS tasa_rechazo
FROM THE_BD_TEAM.BI_Hecho_Inscripcion i
JOIN THE_BD_TEAM.BI_Sede s
    ON s.id_sede = i.id_sede
JOIN THE_BD_TEAM.BI_Tiempo t
    ON t.id_tiempo = i.id_tiempo
GROUP BY s.nombre, t.anio, t.mes;
GO

------------------------------
---- Ejecutar Migraciones ----
------------------------------

BEGIN TRY 
    BEGIN TRAN 

        EXEC THE_BD_TEAM.BI_MigrarSede
        EXEC THE_BD_TEAM.BI_MigrarCurso
        EXEC THE_BD_TEAM.BI_MigrarTiempo
        EXEC THE_BD_TEAM.BI_MigrarInscripcion

    COMMIT TRAN
END TRY
BEGIN CATCH

    ROLLBACK TRAN;

    /*ROLLBACK TRAN
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT 'Error en migración: ' + @ErrorMessage;*/

    DECLARE 
        @Msg NVARCHAR(4000),
        @ErrMsg NVARCHAR(4000),
        @ErrLine INT,
        @ErrProc NVARCHAR(200);

    SET @ErrMsg = ERROR_MESSAGE();
    SET @ErrLine = ERROR_LINE();
    SET @ErrProc = ERROR_PROCEDURE();

    SET @Msg = 
        'ERROR EN MIGRACIÓN' + CHAR(10) +
        'Procedimiento: ' + ISNULL(@ErrProc, 'N/A') + CHAR(10) +
        'Línea: ' + CAST(@ErrLine AS VARCHAR(10)) + CHAR(10) +
        'Mensaje: ' + @ErrMsg;

    PRINT @Msg;

END CATCH
