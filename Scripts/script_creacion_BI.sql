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

-- Tiempo
CREATE TABLE THE_BD_TEAM.BI_Tiempo (
    id_tiempo BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    anio BIGINT,
    mes BIGINT,
    cuatrimestre BIGINT
);
GO

-- Alumno (rangos etarios)
CREATE TABLE THE_BD_TEAM.BI_Alumno (
    id_rango_etario_alumno BIGINT PRIMARY KEY,
    rango_etario NVARCHAR(255)
);
GO

-- Profesor (rangos etarios)
CREATE TABLE THE_BD_TEAM.BI_Profesor (
    id_rango_etario_profesor BIGINT PRIMARY KEY,
    rango_etario NVARCHAR(255)
);
GO

-- Medio De Pago
CREATE TABLE THE_BD_TEAM.BI_MedioDePago (
    id_medio_pago BIGINT PRIMARY KEY NOT NULL, 
    medio_de_pago NVARCHAR(255)
);
GO

-- Satisfaccion
CREATE TABLE THE_BD_TEAM.BI_BloqueDeSatisfaccion (
    id_bloque_satisfaccion BIGINT PRIMARY KEY,
    descripcion NVARCHAR(255),
    nota_min BIGINT,
    nota_max BIGINT
);
GO

-- Categoría
CREATE TABLE THE_BD_TEAM.BI_Categoria (
    id_categoria BIGINT PRIMARY KEY NOT NULL,
    nombre VARCHAR(15)
);
GO

-- Turno  
CREATE TABLE THE_BD_TEAM.BI_Turno (
    id_turno BIGINT PRIMARY KEY NOT NULL,
    nombre VARCHAR(6)
);
GO

----------------------------
---- Migrar Dimensiones ----
----------------------------

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

            UNION

            SELECT fecha_inicio AS fecha
            FROM THE_BD_TEAM.Curso
            WHERE fecha_inicio IS NOT NULL
            
            UNION

            SELECT fecha_fin AS fecha
            FROM THE_BD_TEAM.Curso
            WHERE fecha_fin IS NOT NULL
    ) AS fechas;
       
END;
GO

-- Alumno
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarAlumno
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Alumno (id_rango_etario_alumno, rango_etario)
    VALUES 
        (1, '<25'),
        (2, '25-35'),
        (3, '35-50'),
        (4, '>50')
END;
GO

-- Profesor
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarProfesor
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Profesor (id_rango_etario_profesor, rango_etario)
    VALUES 
        (1, '25-35'),
        (2, '35-50'),
        (3, '>50')
END;
GO

-- Medio De Pago
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarMedioDePago
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_MedioDePago
        (id_medio_pago, medio_de_pago)
    
    SELECT mp.id_medioDePago, mp.medioPago
    FROM THE_BD_TEAM.MedioDePago mp
END;
GO

-- Satisfaccion
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarSatisfaccion
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_BloqueDeSatisfaccion
    (id_bloque_satisfaccion, descripcion, nota_min, nota_max)
    VALUES
        (1, 'Insatisfecho', 1, 4),
        (2, 'Neutral', 5, 6),
        (3, 'Satisfecho', 7, 10)
END;
GO

-- Categorías
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarCategoria
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Categoria (id_categoria, nombre)
    SELECT DISTINCT id_categoria, categoria 
    FROM THE_BD_TEAM.Categoria;
END;
GO

-- Turnos
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarTurno
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Turno (id_turno, nombre)
    SELECT DISTINCT id_turno, turno 
    FROM THE_BD_TEAM.Turno;
END;
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
CREATE FUNCTION THE_BD_TEAM.BI_Clasificar_Rango_Alumno(@fecha_nacimiento DATE)
RETURNS BIGINT
AS
BEGIN
    IF @fecha_nacimiento IS NULL RETURN NULL;

    DECLARE @edad INT = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());

    IF @edad < 25 RETURN 1;
    IF @edad BETWEEN 25 AND 35 RETURN 2;
    IF @edad BETWEEN 36 AND 50 RETURN 3;
    RETURN 4;
END;
GO

CREATE FUNCTION THE_BD_TEAM.BI_Clasificar_Rango_Profesor(@fecha_nacimiento DATE)
RETURNS BIGINT
AS
BEGIN
    IF @fecha_nacimiento IS NULL RETURN NULL;

    DECLARE @edad INT = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());

    IF @edad BETWEEN 25 AND 35 RETURN 1;
    IF @edad BETWEEN 36 AND 50 RETURN 2;
    RETURN 3;
END;
GO

-- Clasificar Encuesta
CREATE FUNCTION THE_BD_TEAM.BI_Clasificar_Respuesta(@promedio DECIMAL(5,2))
RETURNS INT
AS
BEGIN
    IF @promedio >= 7 AND @promedio <= 10 RETURN 3;   -- Satisfecho
    IF @promedio >= 5 AND @promedio < 7  RETURN 2;    -- Neutral
    IF @promedio >= 1 AND @promedio < 5  RETURN 1;    -- Insatisfecho
    RETURN NULL;
END;
GO

----------------
---- Hechos ----
----------------

-- Inscripcion
CREATE TABLE THE_BD_TEAM.BI_Hechos_Inscripciones (
    id_inscripcion BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    
    -- DIMENSIONES 
    id_sede BIGINT NOT NULL,
    id_tiempo BIGINT NOT NULL,
    id_rango_etario_alumno BIGINT NOT NULL,
    id_categoria BIGINT NOT NULL, 
    id_turno BIGINT NOT NULL, 
    
    -- ATRIBUTO
    cantidad_inscriptos INT,
    cantidad_rechazados INT,

    -- CONSTRAINTS
    CONSTRAINT FK_BI_Inscripcion_Sede
    FOREIGN KEY (id_sede)
    REFERENCES THE_BD_TEAM.BI_Sede(id_sede),

    CONSTRAINT FK_BI_Inscripcion_Tiempo
    FOREIGN KEY (id_tiempo)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo), 

    CONSTRAINT FK_BI_Inscripcion_Alumno
    FOREIGN KEY (id_rango_etario_alumno)
    REFERENCES THE_BD_TEAM.BI_Alumno(id_rango_etario_alumno),

    CONSTRAINT FK_BI_Inscripcion_Categoria
    FOREIGN KEY (id_categoria)
    REFERENCES THE_BD_TEAM.BI_Categoria(id_categoria),

    CONSTRAINT FK_BI_Inscripcion_Turno
    FOREIGN KEY (id_turno)
    REFERENCES THE_BD_TEAM.BI_Turno(id_turno)
);
GO

-- Cursada
CREATE TABLE THE_BD_TEAM.BI_Hechos_Cursadas (
    id_cursada BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    
    -- DIMENSIONES
    id_sede BIGINT NOT NULL,
    id_tiempo BIGINT NOT NULL,
    id_rango_etario_alumno BIGINT NOT NULL,
    id_categoria BIGINT NOT NULL,     
    
    cantidad_inscriptos INT NOT NULL DEFAULT 0,
    cantidad_aprobados INT NOT NULL DEFAULT 0,
    tiempo_promedio_finalizacion_dias DECIMAL(10,2) NULL,

    -- CONSTRAINTS
    CONSTRAINT FK_BI_Cursada_Sede
    FOREIGN KEY (id_sede)
    REFERENCES THE_BD_TEAM.BI_Sede(id_sede),

    CONSTRAINT FK_BI_Cursada_Tiempo
    FOREIGN KEY (id_tiempo)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo),

    CONSTRAINT FK_BI_Cursada_Alumno
    FOREIGN KEY (id_rango_etario_alumno)
    REFERENCES THE_BD_TEAM.BI_Alumno(id_rango_etario_alumno),

    CONSTRAINT FK_BI_Cursada_Categoria
    FOREIGN KEY (id_categoria)
    REFERENCES THE_BD_TEAM.BI_Categoria(id_categoria)
);
GO

-- Finales
CREATE TABLE THE_BD_TEAM.BI_Hechos_Finales (
    id_hechos_final BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    
    -- DIMENSIONES
    id_tiempo_final BIGINT NOT NULL,         
    id_tiempo_inicio BIGINT NOT NULL,               
    id_sede BIGINT NOT NULL,                
    id_rango_etario_alumno BIGINT NOT NULL,
    id_categoria BIGINT NOT NULL,
    
    -- MEDIDAS Y ATRIBUTOS
    nota_final DECIMAL(4,2),                  
    aprobo_final BIT NOT NULL,                                 
    ausente BIT NOT NULL,                                      
    cant_inscriptos INT NOT NULL DEFAULT 1,                    


    -- CONSTRAINTS
    CONSTRAINT FK_BI_Finales_Tiempo
    FOREIGN KEY (id_tiempo_final)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo),

    CONSTRAINT FK_BI_Finales_Tiempo_Inicio
    FOREIGN KEY (id_tiempo_inicio)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo),

    CONSTRAINT FK_BI_Finales_Sede
    FOREIGN KEY (id_sede)
    REFERENCES THE_BD_TEAM.BI_Sede(id_sede),

    CONSTRAINT FK_BI_Finales_Alumno
    FOREIGN KEY (id_rango_etario_alumno)
    REFERENCES THE_BD_TEAM.BI_Alumno(id_rango_etario_alumno),

    CONSTRAINT FK_BI_Finales_Categoria
    FOREIGN KEY (id_categoria)
    REFERENCES THE_BD_TEAM.BI_Categoria(id_categoria)
);
GO

-- Finanzas
CREATE TABLE THE_BD_TEAM.BI_Hechos_Finanzas (
    id_finanza BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    
    -- DIMENSIONES
    id_sede BIGINT NOT NULL,
    id_tiempo_emision BIGINT NOT NULL,
    id_tiempo_pago BIGINT NULL, 
    id_categoria BIGINT NULL,            
    id_medio_pago BIGINT NULL,
    
    -- MEDIDAS
    importe_facturado DECIMAL(10,2) NOT NULL,
    importe_adeudado DECIMAL(10,2) NOT NULL,
    importe_pagado DECIMAL(10,2) NULL,
    pago_fuera_termino BIT NOT NULL,

    -- CONSTRAINTS
    CONSTRAINT FK_BI_Finanzas_Sede
    FOREIGN KEY (id_sede)
    REFERENCES THE_BD_TEAM.BI_Sede(id_sede),

    CONSTRAINT FK_BI_Finanzas_Tiempo_Emision
    FOREIGN KEY (id_tiempo_emision)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo),

    CONSTRAINT FK_BI_Finanzas_Tiempo_Pago
    FOREIGN KEY (id_tiempo_pago)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo),

    CONSTRAINT FK_BI_Finanzas_Categoria
    FOREIGN KEY (id_categoria)
    REFERENCES THE_BD_TEAM.BI_Categoria(id_categoria),

    CONSTRAINT FK_BI_Finanzas_Medio_Pago
    FOREIGN KEY (id_medio_pago)
    REFERENCES THE_BD_TEAM.BI_MedioDePago(id_medio_pago)
);
GO

-- Encuestas
CREATE TABLE THE_BD_TEAM.BI_Hechos_Encuestas (
    id_encuesta BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- DIMENSIONES
    id_rango_etario_profesor BIGINT,
    id_sede BIGINT,
    id_tiempo BIGINT,
    id_bloque_satisfaccion BIGINT,
    
    -- MEDIDA
    cantidad_respuestas INT,

    -- CONSTRAINTS
    CONSTRAINT FK_BI_Encuestas_Sede
    FOREIGN KEY (id_sede)
    REFERENCES THE_BD_TEAM.BI_Sede(id_sede),

    CONSTRAINT FK_BI_Encuestas_Tiempo
    FOREIGN KEY (id_tiempo)
    REFERENCES THE_BD_TEAM.BI_Tiempo(id_tiempo),

    CONSTRAINT FK_BI_Encuestas_Profesor
    FOREIGN KEY (id_rango_etario_profesor)
    REFERENCES THE_BD_TEAM.BI_Profesor(id_rango_etario_profesor),

    CONSTRAINT FK_BI_Encuestas_Satisfaccion
    FOREIGN KEY (id_bloque_satisfaccion)
    REFERENCES THE_BD_TEAM.BI_BloqueDeSatisfaccion(id_bloque_satisfaccion)
);
GO

-----------------------
---- Migrar Hechos ----
-----------------------

-- Inscripcion
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarInscripcion
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Hechos_Inscripciones
        (id_sede, id_tiempo, id_rango_etario_alumno, id_categoria, id_turno, cantidad_inscriptos, cantidad_rechazados)

    SELECT  
        c.id_sede,
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(i.fecha_inscripcion),
        THE_BD_TEAM.BI_Clasificar_Rango_Alumno(a.fechaNacimiento),
        c.id_categoria, 
        c.id_turno,      
        COUNT(DISTINCT i.nro_inscripcion) as cantidad_inscriptos,
        SUM(CASE WHEN ei.estado = 'Rechazada' THEN 1 ELSE 0 END) as cantidad_rechazados
       
    FROM THE_BD_TEAM.Inscripcion i
    JOIN THE_BD_TEAM.Curso c 
        ON c.cod_curso = i.cod_curso
    JOIN THE_BD_TEAM.EstadoInscripcion ei 
        ON ei.id_EstadoInscripcion = i.id_EstadoInscripcion
    JOIN THE_BD_TEAM.Alumno a 
        ON a.legajo = i.legajo
        WHERE i.fecha_inscripcion IS NOT NULL
    GROUP BY 
        c.id_sede,
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(i.fecha_inscripcion),
        THE_BD_TEAM.BI_Clasificar_Rango_Alumno(a.fechaNacimiento),
        c.id_categoria, 
        c.id_turno;
END;
GO

-- Cursada
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarCursada
AS
BEGIN

    WITH CursadasAprobadas AS (
        SELECT 
            i.legajo,
            i.cod_curso,
            -- Lógica de aprobación: nota >=4 en TODOS los módulos + TP
            CASE 
                -- Verifica que tenga nota >=4 en TODOS los módulos del curso
                WHEN (SELECT COUNT(*) 
                      FROM THE_BD_TEAM.Modulo m
                      WHERE m.cod_curso = i.cod_curso) =
                     (SELECT COUNT(*)
                      FROM THE_BD_TEAM.AlumnoXEvaluacion axe
                      JOIN THE_BD_TEAM.Evaluacion ev ON ev.id_evaluacion = axe.id_evaluacion
                      JOIN THE_BD_TEAM.Modulo m ON m.id_modulo = ev.id_modulo
                      WHERE axe.legajo = i.legajo
                        AND axe.presente = 1
                        AND axe.nota >= 4
                        AND m.cod_curso = i.cod_curso)
                -- Verifica que tenga TP aprobado (nota >=4)
                AND EXISTS (
                    SELECT 1
                    FROM THE_BD_TEAM.Trabajo_Practico tp
                    WHERE tp.legajo = i.legajo
                      AND tp.cod_curso = i.cod_curso
                      AND tp.nota >= 4)
                THEN 1 
                ELSE 0 
            END AS aprobo_cursada


        FROM THE_BD_TEAM.Inscripcion i
        WHERE i.id_EstadoInscripcion = (
            SELECT id_EstadoInscripcion 
            FROM THE_BD_TEAM.EstadoInscripcion 
            WHERE estado = 'Confirmada'
        )
    ),
    TiemposFinalizacion AS (
        -- Calcular tiempo de finalización para cada alumno que aprobó el FINAL
        SELECT 
            i.legajo,
            i.cod_curso,
            -- Tiempo en días entre inicio del curso y aprobación del final
            DATEDIFF(DAY, c.fecha_inicio, mf.fecha) as dias_finalizacion
        FROM THE_BD_TEAM.Inscripcion i
        JOIN THE_BD_TEAM.Curso c ON c.cod_curso = i.cod_curso
        JOIN THE_BD_TEAM.Mesa_De_Final mf ON mf.cod_curso = c.cod_curso
        JOIN THE_BD_TEAM.Examen_Final ef ON ef.id_mesa = mf.id_mesa 
            AND ef.legajo = i.legajo
        WHERE i.id_EstadoInscripcion = (
            SELECT id_EstadoInscripcion 
            FROM THE_BD_TEAM.EstadoInscripcion 
            WHERE estado = 'Confirmada'
        )
        AND ef.nota >= 4  -- Solo finales aprobados
        AND c.fecha_inicio IS NOT NULL
        AND mf.fecha IS NOT NULL
        AND mf.fecha >= c.fecha_inicio  -- Validación lógica
    )
    -- Insertar en tabla de hechos BI
    INSERT INTO THE_BD_TEAM.BI_Hechos_Cursadas 
        (id_sede, id_tiempo, id_rango_etario_alumno, id_categoria, cantidad_inscriptos, cantidad_aprobados, tiempo_promedio_finalizacion_dias)
    SELECT  
        c.id_sede,
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(c.fecha_inicio),  
        THE_BD_TEAM.BI_Clasificar_Rango_Alumno(a.fechaNacimiento),
        c.id_categoria,
        COUNT(*) as cantidad_inscriptos,
        SUM(ca.aprobo_cursada) as cantidad_aprobados,
        AVG(CASE 
            WHEN tf.dias_finalizacion IS NOT NULL 
            THEN CAST(tf.dias_finalizacion AS DECIMAL(10,2))
            ELSE NULL 
        END) as tiempo_promedio_finalizacion_dias
    FROM CursadasAprobadas ca
    JOIN THE_BD_TEAM.Inscripcion i 
        ON i.legajo = ca.legajo AND i.cod_curso = ca.cod_curso
    JOIN THE_BD_TEAM.Curso c 
        ON c.cod_curso = i.cod_curso
    JOIN THE_BD_TEAM.Alumno a 
        ON a.legajo = i.legajo
    LEFT JOIN TiemposFinalizacion tf 
        ON tf.legajo = i.legajo AND tf.cod_curso = i.cod_curso
    WHERE c.fecha_inicio IS NOT NULL
    GROUP BY 
        c.id_sede,
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(c.fecha_inicio),
        THE_BD_TEAM.BI_Clasificar_Rango_Alumno(a.fechaNacimiento),
        c.id_categoria;
END;
GO


-- Finales
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarFinales
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Hechos_Finales
    (id_tiempo_final, id_tiempo_inicio, id_sede, id_rango_etario_alumno, 
     id_categoria, nota_final, aprobo_final, ausente, cant_inscriptos)
    
    SELECT 
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(mf.fecha),       
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(cur.fecha_inicio), 
        cur.id_sede,
        THE_BD_TEAM.BI_Clasificar_Rango_Alumno(a.fechaNacimiento),
        cur.id_categoria,
        ef.nota,
        CASE WHEN ef.nota IS NOT NULL AND ef.nota >= 4 THEN 1 ELSE 0 END,
        CASE WHEN ef.nota IS NULL THEN 1 ELSE 0 END,
        1
    FROM THE_BD_TEAM.Mesa_De_Final mf
    JOIN THE_BD_TEAM.Curso cur 
        ON cur.cod_curso = mf.cod_curso
    JOIN THE_BD_TEAM.Examen_Final ef 
        ON ef.id_mesa = mf.id_mesa
    JOIN THE_BD_TEAM.Alumno a 
        ON a.legajo = ef.legajo
    WHERE mf.fecha IS NOT NULL;
END;
GO

-- Finanzas
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarFinanzas
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Hechos_Finanzas
    (id_sede, id_medio_pago, id_tiempo_emision, id_tiempo_pago, 
     id_categoria, importe_facturado, importe_adeudado, 
     pago_fuera_termino, importe_pagado)
    
    SELECT 
        s.id_sede, 
        pmp.id_medioDePago,
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(f.fecha_emision),
        THE_BD_TEAM.BI_Obtener_Id_Tiempo((SELECT MIN(p.fecha)
                                          FROM THE_BD_TEAM.Pago p
                                          WHERE p.nro_factura = f.nro_factura)),
        c.id_categoria,  
        f.importe_total,
        CASE 
            WHEN EXISTS (SELECT 1
                         FROM THE_BD_TEAM.Pago p2
                         WHERE p2.nro_factura = f.nro_factura
                         AND YEAR(p2.fecha) = YEAR(f.fecha_emision)
                         AND MONTH(p2.fecha) = MONTH(f.fecha_emision))
            THEN 0
            ELSE f.importe_total
        END AS importe_adeudado,
        CASE
            WHEN NOT EXISTS (SELECT 1 FROM THE_BD_TEAM.Pago px
                             WHERE px.nro_factura = f.nro_factura) 
            THEN 1
            WHEN (SELECT MIN(p2.fecha)
                  FROM THE_BD_TEAM.Pago p2
                  WHERE p2.nro_factura = f.nro_factura
            ) > f.fecha_vencimiento 
            THEN 1
            ELSE 0
        END AS pago_fuera_termino,
        COALESCE((
            SELECT SUM(p3.importe)
            FROM THE_BD_TEAM.Pago p3
            WHERE p3.nro_factura = f.nro_factura
        ), 0) AS importe_pagado

    FROM THE_BD_TEAM.Factura f
    JOIN THE_BD_TEAM.Detalle_Factura df
        ON df.nro_factura = f.nro_factura
    JOIN THE_BD_TEAM.Curso c
        ON c.cod_curso = df.cod_curso
    JOIN THE_BD_TEAM.Sede s
        ON s.id_sede = c.id_sede
    LEFT JOIN THE_BD_TEAM.Pago p
        ON p.nro_factura = f.nro_factura
    LEFT JOIN THE_BD_TEAM.PagoXMedioDePago pmp
        ON pmp.id_pago = p.id_pago;
END;
GO

-- Encuestas
CREATE PROCEDURE THE_BD_TEAM.BI_MigrarEncuestas
AS
BEGIN
    INSERT INTO THE_BD_TEAM.BI_Hechos_Encuestas
        (id_rango_etario_profesor, id_sede, id_tiempo, id_bloque_satisfaccion, cantidad_respuestas)

    SELECT  
        THE_BD_TEAM.BI_Clasificar_Rango_Profesor(p.fecha_nacimiento),
        c.id_sede,
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(e.fecha_registro),
        THE_BD_TEAM.BI_Clasificar_Respuesta(r.nota),
        COUNT(*) AS cantidad_respuestas

    FROM THE_BD_TEAM.Respuesta r
    JOIN THE_BD_TEAM.Encuesta e
        ON e.id_encuesta = r.id_encuesta
    JOIN THE_BD_TEAM.Curso c
        ON c.cod_curso = e.cod_curso
    JOIN THE_BD_TEAM.Profesor p
        ON p.id_profesor = c.id_profesor
    WHERE r.nota IS NOT NULL
    GROUP BY  
        THE_BD_TEAM.BI_Clasificar_Rango_Profesor(p.fecha_nacimiento),
        c.id_sede,
        THE_BD_TEAM.BI_Obtener_Id_Tiempo(e.fecha_registro),
        THE_BD_TEAM.BI_Clasificar_Respuesta(r.nota);
END;
GO

----------------
---- Vistas ----
----------------

-- Vista 1: Categorías y turnos más solicitados.
CREATE VIEW THE_BD_TEAM.BI_V_CategoriasYTurnosMasSolicitados
AS
    SELECT sede, anio, categoria, turno, cantidad_inscriptos
    FROM (
        SELECT 
            s.nombre AS sede,
            t.anio,
            cat.nombre AS categoria,  
            tur.nombre AS turno,         
            SUM(i.cantidad_inscriptos) AS cantidad_inscriptos,
            ROW_NUMBER() OVER (
                PARTITION BY s.nombre, t.anio
                ORDER BY SUM(i.cantidad_inscriptos) DESC
            ) AS rn
        FROM THE_BD_TEAM.BI_Hechos_Inscripciones i
        JOIN THE_BD_TEAM.BI_Sede s
            ON s.id_sede = i.id_sede
        JOIN THE_BD_TEAM.BI_Tiempo t
            ON t.id_tiempo = i.id_tiempo
        JOIN THE_BD_TEAM.BI_Categoria cat
            ON cat.id_categoria = i.id_categoria
        JOIN THE_BD_TEAM.BI_Turno tur
            ON tur.id_turno = i.id_turno
        GROUP BY s.nombre, t.anio, cat.nombre, tur.nombre
    ) AS ranking
    WHERE rn <= 3;
GO

-- Vista 2: Tasa de rechazo de inscripciones.
CREATE VIEW THE_BD_TEAM.BI_V_TasaRechazoInscripciones
AS
    SELECT s.nombre AS sede, t.anio, t.mes,
        SUM(i.cantidad_inscriptos) AS total_inscripciones,  
        SUM(i.cantidad_rechazados) AS cantidad_rechazadas,
        CAST(
            CASE 
                WHEN SUM(i.cantidad_inscriptos) > 0 
                THEN (SUM(i.cantidad_rechazados) * 100.0) / SUM(i.cantidad_inscriptos)
                ELSE 0 
            END
            AS DECIMAL(10,2)
        ) AS tasa_rechazo_porcentaje
    FROM THE_BD_TEAM.BI_Hechos_Inscripciones i
    JOIN THE_BD_TEAM.BI_Sede s
        ON s.id_sede = i.id_sede
    JOIN THE_BD_TEAM.BI_Tiempo t
        ON t.id_tiempo = i.id_tiempo
    GROUP BY s.nombre, t.anio, t.mes
GO

-- Vista 3: Comparación de desempeño de cursada por sede.
CREATE VIEW THE_BD_TEAM.BI_V_TasaAprobacionCursada
AS
    SELECT 
        s.nombre AS sede,
        t.anio,
        SUM(hc.cantidad_inscriptos) AS total_inscriptos,
        SUM(hc.cantidad_aprobados) AS total_aprobados,
        CAST(
            CASE
                WHEN SUM(hc.cantidad_inscriptos) > 0
                THEN (SUM(hc.cantidad_aprobados) * 100.0) / SUM(hc.cantidad_inscriptos)
                ELSE 0
            END
        AS DECIMAL(10,2)) AS tasa_aprobacion
    FROM THE_BD_TEAM.BI_Hechos_Cursadas hc
    JOIN THE_BD_TEAM.BI_Sede s 
        ON s.id_sede = hc.id_sede
    JOIN THE_BD_TEAM.BI_Tiempo t 
        ON t.id_tiempo = hc.id_tiempo
    GROUP BY s.nombre, t.anio;
GO

-- Vista 4: Tiempo promedio de finalización de curso
CREATE VIEW THE_BD_TEAM.BI_V_TiempoPromedioFinalizacion
AS
    SELECT 
        cat.nombre AS categoria,
        t.anio AS anio_inicio_curso,
        AVG(hc.tiempo_promedio_finalizacion_dias) AS tiempo_promedio_dias
    FROM THE_BD_TEAM.BI_Hechos_Cursadas hc
    JOIN THE_BD_TEAM.BI_Categoria cat 
        ON cat.id_categoria = hc.id_categoria
    JOIN THE_BD_TEAM.BI_Tiempo t 
        ON t.id_tiempo = hc.id_tiempo
    WHERE hc.tiempo_promedio_finalizacion_dias IS NOT NULL
    GROUP BY cat.nombre, t.anio;
GO

-- Vista 5: Nota promedio de finales.
CREATE VIEW THE_BD_TEAM.BI_V_NotaPromedioFinales
AS
    SELECT 
        t.anio, 
        t.cuatrimestre AS semestre, 
        a.rango_etario AS rango_etario_alumno,
        cat.nombre AS categoria, 
        CAST(AVG(hf.nota_final) AS DECIMAL(10,2)) AS nota_promedio_final
    FROM THE_BD_TEAM.BI_Hechos_Finales hf
    JOIN THE_BD_TEAM.BI_Tiempo t
        ON t.id_tiempo = hf.id_tiempo_final
    JOIN THE_BD_TEAM.BI_Alumno a
        ON a.id_rango_etario_alumno = hf.id_rango_etario_alumno
    JOIN THE_BD_TEAM.BI_Categoria cat
        ON cat.id_categoria = hf.id_categoria  
    WHERE hf.ausente = 0
      AND hf.nota_final IS NOT NULL
    GROUP BY t.anio, t.cuatrimestre, a.rango_etario, cat.nombre;
GO

-- Vista 6: Tasa de ausentismo finales.
CREATE VIEW THE_BD_TEAM.BI_V_TasaAusentismoFinales
AS
    SELECT 
        t.anio, 
        t.cuatrimestre, 
        s.nombre AS sede,
        CAST(
            SUM(CASE WHEN hf.ausente = 1 THEN hf.cant_inscriptos ELSE 0 END) * 100.0 
            / SUM(hf.cant_inscriptos) 
        AS DECIMAL(10,2)) AS tasa_ausentismo
    FROM THE_BD_TEAM.BI_Hechos_Finales hf
    JOIN THE_BD_TEAM.BI_Tiempo t 
        ON t.id_tiempo = hf.id_tiempo_final  
    JOIN THE_BD_TEAM.BI_Sede s 
        ON s.id_sede = hf.id_sede      
    GROUP BY t.anio, t.cuatrimestre, s.nombre;
GO

-- Vista 7: Desvío de pagos.
CREATE VIEW THE_BD_TEAM.BI_V_DesvioPagos
AS
    SELECT 
        s.nombre AS sede, 
        t.anio, 
        t.cuatrimestre,
        CAST(
            SUM(CASE WHEN f.pago_fuera_termino = 1 THEN 1 ELSE 0 END) * 100.0 
            / COUNT(*)
        AS DECIMAL(10,2)) AS porcentaje_fuera_de_termino
    FROM THE_BD_TEAM.BI_Hechos_Finanzas f
    JOIN THE_BD_TEAM.BI_Sede s
        ON s.id_sede = f.id_sede
    JOIN THE_BD_TEAM.BI_Tiempo t
        ON t.id_tiempo = f.id_tiempo_pago 
    WHERE f.id_tiempo_pago IS NOT NULL  
    GROUP BY s.nombre, t.anio, t.cuatrimestre;
GO

-- Vista 8: Tasa de Morosidad Financiera mensual.
CREATE VIEW THE_BD_TEAM.BI_V_MorosidadMensual
AS
    SELECT 
        s.nombre AS sede, 
        t.anio, 
        t.mes,
        CAST(
            SUM(f.importe_adeudado) * 100.0 /
            NULLIF(SUM(f.importe_facturado), 0)
        AS DECIMAL(10,2)) AS tasa_morosidad
    FROM THE_BD_TEAM.BI_Hechos_Finanzas f
    JOIN THE_BD_TEAM.BI_Sede s
        ON s.id_sede = f.id_sede
    JOIN THE_BD_TEAM.BI_Tiempo t
        ON t.id_tiempo = f.id_tiempo_emision
    GROUP BY s.nombre, t.anio, t.mes;
GO

-- Vista 9: Ingresos por categoría de cursos.
CREATE VIEW THE_BD_TEAM.BI_V_IngresosPorCategoria
AS
    SELECT sede, anio, categoria, ingresos
    FROM (
        SELECT 
            s.nombre AS sede, 
            t.anio, 
            cat.nombre AS categoria,  
            SUM(f.importe_pagado) AS ingresos,
            ROW_NUMBER() OVER (
                PARTITION BY s.nombre, t.anio
                ORDER BY SUM(f.importe_pagado) DESC
            ) AS rn
        FROM THE_BD_TEAM.BI_Hechos_Finanzas f
        JOIN THE_BD_TEAM.BI_Sede s
            ON s.id_sede = f.id_sede
        JOIN THE_BD_TEAM.BI_Tiempo t
            ON t.id_tiempo = f.id_tiempo_pago
        JOIN THE_BD_TEAM.BI_Categoria cat
            ON cat.id_categoria = f.id_categoria  
        WHERE f.id_tiempo_pago IS NOT NULL  
        GROUP BY s.nombre, t.anio, cat.nombre
    ) ranking
    WHERE rn <= 3;
GO

-- Vista 10: Índice de satisfacción.
CREATE VIEW THE_BD_TEAM.BI_V_IndiceSatisfaccion
AS
    SELECT 
        s.nombre AS sede, 
        p.rango_etario AS rango_profesor, 
        t.anio,
        CAST(((SUM(CASE WHEN b.id_bloque_satisfaccion = 3 THEN he.cantidad_respuestas END) * 100.0 
               / NULLIF(SUM(he.cantidad_respuestas), 0)) - 
               (SUM(CASE WHEN b.id_bloque_satisfaccion = 1 THEN he.cantidad_respuestas END) * 100.0 
                / NULLIF(SUM(he.cantidad_respuestas), 0)) + 100) / 2  AS DECIMAL(10,2)
        ) AS indice_satisfaccion
    FROM THE_BD_TEAM.BI_Hechos_Encuestas he
    JOIN THE_BD_TEAM.BI_Sede s
        ON s.id_sede = he.id_sede
    JOIN THE_BD_TEAM.BI_Tiempo t
        ON t.id_tiempo = he.id_tiempo
    JOIN THE_BD_TEAM.BI_Profesor p
        ON p.id_rango_etario_profesor = he.id_rango_etario_profesor
    JOIN THE_BD_TEAM.BI_BloqueDeSatisfaccion b
        ON b.id_bloque_satisfaccion = he.id_bloque_satisfaccion
    GROUP BY s.nombre, p.rango_etario, t.anio;
GO

------------------------------
---- Ejecutar Migraciones ----
------------------------------

BEGIN TRY 
    BEGIN TRAN 

        EXEC THE_BD_TEAM.BI_MigrarSede
        EXEC THE_BD_TEAM.BI_MigrarTurno
        EXEC THE_BD_TEAM.BI_MigrarCategoria
        EXEC THE_BD_TEAM.BI_MigrarTiempo
        EXEC THE_BD_TEAM.BI_MigrarAlumno
        EXEC THE_BD_TEAM.BI_MigrarProfesor
        EXEC THE_BD_TEAM.BI_MigrarMedioDePago
        EXEC THE_BD_TEAM.BI_MigrarSatisfaccion
        EXEC THE_BD_TEAM.BI_MigrarInscripcion
        EXEC THE_BD_TEAM.BI_MigrarCursada
        EXEC THE_BD_TEAM.BI_MigrarFinales
        EXEC THE_BD_TEAM.BI_MigrarFinanzas
        EXEC THE_BD_TEAM.BI_MigrarEncuestas

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

------------------------------
------ Test de Vistas --------
------------------------------

/*
SELECT * FROM THE_BD_TEAM.BI_V_CategoriasYTurnosMasSolicitados
SELECT * FROM THE_BD_TEAM.BI_V_TasaRechazoInscripciones
SELECT * FROM THE_BD_TEAM.BI_V_TiempoPromedioFinalizacion
SELECT * FROM THE_BD_TEAM.BI_V_TasaAprobacionCursada
SELECT * FROM THE_BD_TEAM.BI_V_TasaAusentismoFinales
SELECT * FROM THE_BD_TEAM.BI_V_NotaPromedioFinales
SELECT * FROM THE_BD_TEAM.BI_V_DesvioPagos
SELECT * FROM THE_BD_TEAM.BI_V_MorosidadMensual
SELECT * FROM THE_BD_TEAM.BI_V_IngresosPorCategoria
SELECT * FROM THE_BD_TEAM.BI_V_IndiceSatisfaccion

--DIMENSIONES

SELECT * FROM THE_BD_TEAM.BI_Curso
SELECT * FROM THE_BD_TEAM.BI_Tiempo
SELECT * FROM THE_BD_TEAM.BI_Alumno
SELECT * FROM THE_BD_TEAM.BI_Profesor
SELECT * FROM THE_BD_TEAM.BI_Sede
SELECT * FROM THE_BD_TEAM.BI_MedioDePago
SELECT * FROM THE_BD_TEAM.BI_BloqueDeSatisfaccion

--HECHOS

SELECT * FROM THE_BD_TEAM.BI_Hechos_Inscripciones
SELECT * FROM THE_BD_TEAM.BI_Hechos_Cursadas
SELECT * FROM THE_BD_TEAM.BI_Hechos_Finales
SELECT * FROM THE_BD_TEAM.BI_Hechos_Finanzas
SELECT * FROM THE_BD_TEAM.BI_Hechos_Encuestas

*/
