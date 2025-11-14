----------------------------------------------------------------------------------
----------------------------- BORRRAR RELACIONAL ---------------------------------
----------------------------------------------------------------------------------

-- Eliminar las FOREIGN KEYS
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += 'ALTER TABLE THE_BD_TEAM.' + t.name + 
               ' DROP CONSTRAINT ' + fk.name + ';' + CHAR(13)
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
WHERE SCHEMA_NAME(t.schema_id) = 'THE_BD_TEAM';
EXEC sp_executesql @sql;

-- Eliminar las tablas
DECLARE @dropTables NVARCHAR(MAX) = N'';
SELECT @dropTables += 'DROP TABLE THE_BD_TEAM.' + name + ';' + CHAR(13)
FROM sys.tables
WHERE schema_id = SCHEMA_ID('THE_BD_TEAM');
EXEC sp_executesql @dropTables;

-- Eliminar los procedimientos almacenados
DECLARE @dropProcs NVARCHAR(MAX) = N'';
SELECT @dropProcs += 'DROP PROCEDURE THE_BD_TEAM.' + name + ';' + CHAR(13)
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('THE_BD_TEAM');
EXEC sp_executesql @dropProcs;

-- Finalmente eliminar el esquema
DROP SCHEMA THE_BD_TEAM;
go
----------------------------------------------------------------------------------
--------------------------------- BORRRAR BI -------------------------------------
----------------------------------------------------------------------------------
DECLARE @sql NVARCHAR(MAX) = N'';

-----------------------------------------
-- 1) DROPEAR VISTAS BI_
-----------------------------------------
SELECT @sql = @sql + 'DROP VIEW THE_BD_TEAM.' + QUOTENAME(name) + ';'
FROM sys.views
WHERE schema_id = SCHEMA_ID('THE_BD_TEAM')
  AND name LIKE 'BI_%';

EXEC (@sql);
SET @sql = N'';

-----------------------------------------
-- 2) DROPEAR FUNCIONES BI_
-----------------------------------------
SELECT @sql = @sql + 'DROP FUNCTION THE_BD_TEAM.' + QUOTENAME(name) + ';'
FROM sys.objects
WHERE schema_id = SCHEMA_ID('THE_BD_TEAM')
  AND name LIKE 'BI_%'
  AND type IN ('FN','IF','TF'); -- funciones escalares y de tabla

EXEC (@sql);
SET @sql = N'';

-----------------------------------------
-- 3) DROPEAR STORED PROCEDURES BI_
-----------------------------------------
SELECT @sql = @sql + 'DROP PROCEDURE THE_BD_TEAM.' + QUOTENAME(name) + ';'
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('THE_BD_TEAM')
  AND name LIKE 'BI_%';

EXEC (@sql);
SET @sql = N'';

-----------------------------------------
-- 4) DROPEAR TABLAS BI_ (ORDEN CORRECTO)
-- Primero dropea FOREIGN KEYS
-----------------------------------------

-- Eliminar todas las FKs cuyo nombre o tabla empiece con BI_
SELECT @sql = @sql + '
ALTER TABLE THE_BD_TEAM.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + ' 
DROP CONSTRAINT ' + QUOTENAME(name) + ';'
FROM sys.foreign_keys
WHERE parent_object_id IN (
        SELECT object_id 
        FROM sys.tables 
        WHERE schema_id = SCHEMA_ID('THE_BD_TEAM')
          AND name LIKE 'BI_%'
      );

EXEC (@sql);
SET @sql = N'';

-- Ahora s� eliminar tablas BI_
SELECT @sql = @sql + 'DROP TABLE THE_BD_TEAM.' + QUOTENAME(name) + ';'
FROM sys.tables
WHERE schema_id = SCHEMA_ID('THE_BD_TEAM')
  AND name LIKE 'BI_%';

EXEC (@sql);
SET @sql = N'';
------