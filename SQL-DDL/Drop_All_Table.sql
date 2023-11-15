DECLARE @sql NVARCHAR(MAX) = '';

-- Generate script to drop all foreign key constraints
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(FK.TABLE_SCHEMA) + '.' + QUOTENAME(FK.TABLE_NAME) 
    + ' DROP CONSTRAINT ' + QUOTENAME(FK.CONSTRAINT_NAME) + '; '
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS RC
JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS FK
    ON FK.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA
    AND FK.CONSTRAINT_NAME = RC.CONSTRAINT_NAME

-- Execute the generated script to drop foreign key constraints
EXEC sp_executesql @sql;

SET @sql = '';

-- Generate script to drop all tables
SELECT @sql += 'DROP TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + '; '
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
    AND TABLE_SCHEMA != 'sys'
    AND TABLE_NAME != 'dtproperties' -- Exclude system tables and special tables

-- Execute the generated script to drop all tables
EXEC sp_executesql @sql;
