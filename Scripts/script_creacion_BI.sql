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
    categoria VARCHAR(15),
    fecha_inicio DATETIME2(6) --lo necesito para finales
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

-- MedioDePago - FALTA MIGRAR NO SE MUY BIEN SI ESTO ESTA BN
CREATE TABLE THE_BD_TEAM.BI_MedioDePago (
    id_medio_pago BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
    medio_pago NVARCHAR(255)
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

-- Calcular los dias transcurridos entre dos fechas
CREATE FUNCTION THE_BD_TEAM.BI_Calcular_Dias_Transcurridos(@fecha_inicio DATE, @fecha_final DATE) 
RETURNS INT 
AS 
BEGIN
    IF @fecha_inicio IS NULL OR @fecha_final IS NULL
        RETURN NULL;
        
    -- Calcula la diferencia en días
    RETURN DATEDIFF(DAY, @fecha_inicio, @fecha_final);
END;
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

CREATE TABLE THE_BD_TEAM.BI_Hechos_Finales (
    id_hechos_final BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    FK_tiempo BIGINT NOT NULL,
    FK_sede BIGINT NOT NULL,
    FK_alumno BIGINT NOT NULL,
    FK_curso BIGINT NOT NULL,
    
    nota_final DECIMAL(4,2),                                   
    aprobo_final BIT NOT NULL,                                 
    ausente BIT NOT NULL,                                      
    cant_inscriptos INT NOT NULL DEFAULT 1,                    
    
    
    dias_hasta_aprobacion_final INT,        -- dias desde inicio curso hasta aprobación final

    CONSTRAINT FK_BI_Hechos_Finales_Tiempo
    FOREIGN KEY (FK_tiempo)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo),

    CONSTRAINT FK_BI_Hechos_Finales_Sede
    FOREIGN KEY (FK_sede)
    REFERENCES THE_BD_TEAM.BI_Sede(id_sede),

    CONSTRAINT FK_BI_Hechos_Finales_Alumno
    FOREIGN KEY (FK_alumno)
    REFERENCES THE_BD_TEAM.BI_Alumno(legajo),

    CONSTRAINT FK_BI_Hechos_Finales_Curso
    FOREIGN KEY (FK_curso)
    REFERENCES THE_BD_TEAM.BI_Curso(id_curso),
    
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
    (id_curso, turno, categoria, fecha_inicio)
    
    SELECT DISTINCT c.cod_curso, c.fecha_inicio, t.turno, ca.categoria
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

-- Cursada

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

-- finales
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarHechosFinales
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Hechos_Finales
    (
        FK_tiempo,
        FK_sede,
        FK_alumno,
        FK_curso,
        nota_final,
        aprobo_final,
        ausente,
        cant_inscriptos,
        dias_hasta_aprobacion_final 
    )
    SELECT
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(mf.fecha) AS FK_tiempo,
        cur.id_sede AS FK_sede,
        mf.legajo AS FK_alumno,
        mf.id_curso AS FK_curso,
        mf.nota AS nota_final,
        CASE WHEN mf.nota IS NOT NULL AND mf.nota >= 4 THEN 1 ELSE 0 END AS aprobo_final,
        CASE WHEN mf.nota IS NULL THEN 1 ELSE 0 END AS ausente,
        1 AS cant_inscriptos,
        
        -- DIAS TRANSCURRIDOS
        CASE 
            WHEN mf.nota IS NOT NULL AND mf.nota >= 4 
            THEN THE_BD_TEAM.BI_Calcular_Dias_Transcurridos(cur.fecha_inicio, mf.fecha)
            ELSE NULL 
        END AS dias_hasta_aprobacion_final

    FROM THE_BD_TEAM.Mesa_De_Final mf
    JOIN THE_BD_TEAM.BI_Curso cur 
        ON cur.id_curso = mf.id_curso
    WHERE 
        mf.fecha IS NOT NULL;
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

--Vista 3: Comparación de Desempeño de Cursada
CREATE VIEW THE_BD_TEAM.BI_V_TasaAprobacionCursada
AS
SELECT
    s.nombre as sede,
    t.anio,
    -- (Suma de aprobados / Total de cursadas) * 100
    CAST(
        SUM(CASE WHEN hc.aprobo_cursada = 1 THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*)
    AS DECIMAL(10,2)) AS porcentaje_aprobacion_cursada
FROM THE_BD_TEAM.BI_Hecho_Cursada hc
JOIN THE_BD_TEAM.BI_Sede s ON s.id_sede = hc.id_sede
JOIN THE_BD_TEAM.BI_Tiempo t ON t.id_tiempo = hc.id_tiempo 
GROUP BY 
    s.nombre,
    t.anio;
GO

-- Vista 4

CREATE VIEW THE_BD_TEAM.BI_V_TiempoPromedioFinalizacion
AS
SELECT
    cur.categoria,
    YEAR(cur.fecha_inicio) AS anio_inicio_curso, 
    
    CAST(
        AVG(hf.dias_hasta_aprobacion_final * 1.0) 
    AS DECIMAL(10,2)) AS tiempo_promedio_dias
FROM 
    THE_BD_TEAM.BI_Hechos_Finales hf
    
JOIN 
    THE_BD_TEAM.BI_Curso cur
    ON cur.id_curso = hf.FK_curso
    
WHERE 
    hf.aprobo_final = 1 
    AND hf.dias_hasta_aprobacion_final IS NOT NULL
    
GROUP BY 
    cur.categoria,
    YEAR(cur.fecha_inicio);
GO

-- Vista 5

CREATE VIEW THE_BD_TEAM.BI_V_NotaPromedioFinales
AS
SELECT
    t.anio,
    t.cuatrimestre AS semestre, --rariiiiiiiiiiiiiiiiiiiiiiii
    a.rango_etario,
    cur.categoria,
    

    CAST(AVG(hf.nota_final) AS DECIMAL(10,2)) AS nota_promedio_final
FROM 
    THE_BD_TEAM.BI_Hechos_Finales hf

JOIN 
    THE_BD_TEAM.BI_Tiempo t
    ON t.id_tiempo = hf.FK_tiempo
    
JOIN 
    THE_BD_TEAM.BI_Alumno a
    ON a.legajo = hf.FK_alumno
    
JOIN 
    THE_BD_TEAM.BI_Curso cur
    ON cur.id_curso = hf.FK_curso
    
WHERE hf.ausente = 0 
    
GROUP BY
    t.anio,
    t.cuatrimestre,
    a.rango_etario,
    cur.categoria;
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
        EXEC THE_BD_TEAM.BI_MigrarAlumno
        EXEC THE_BD_TEAM.BI_MigrarProfesor
        EXEC THE_BD_TEAM.BI_MigrarMedioPago
        EXEC THE_BD_TEAM.BI_MigrarCursada
        EXEC THE_BD_TEAM.BI_MigrarHechosFinales

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
