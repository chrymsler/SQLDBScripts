SELECT SCHEMA_NAME(t.SCHEMA_ID) AS schemaname,
	t.name AS table_view,
	CASE
		WHEN t.type = 'U' THEN 'Table'
		WHEN t.type = 'V' THEN 'View'
		END AS [object_type],
	CASE
		WHEN c.type = 'PK' THEN 'Primary Key'
		WHEN c.type = 'UQ' THEN 'Unique constraint'
		WHEN i.type = 1 THEN 'Unique clustered index'
		WHEN i.type = 2 THEN 'Unique index'
		END AS constraint_type,
	CASE
		WHEN c.type = 'PK' THEN 'PK'
		WHEN c.type = 'UQ' THEN 'UK'
		WHEN i.type = 1 THEN 'UCIndex'
		WHEN i.type = 2 THEN 'UIndex'
		END AS constraint_code,
	ISNULL(c.name, i.name) AS constraint_name,
	SUBSTRING(column_names, 1, LEN(column_names) - 1) AS [details],
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNo
INTO #constraints
FROM sys.objects t
	 LEFT OUTER JOIN sys.indexes i ON t.object_id = i.object_id
	 LEFT OUTER JOIN sys.key_constraints c ON i.object_id = c.parent_object_id AND i.index_id = c.unique_index_id
	 CROSS APPLY (SELECT col.[name] + '_'
				  FROM sys.index_columns ic
					   INNER JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
				  WHERE ic.object_id = t.object_id
					AND ic.index_id = i.index_id
				  ORDER BY col.column_id
				  FOR XML PATH ('')) D (column_names)
WHERE is_unique = 1
  AND t.is_ms_shipped <> 1
ORDER BY table_view, constraint_name

SELECT *
FROM #constraints

DECLARE @count INT, @i INT = 1
SET @count = (SELECT MAX(RowNo)
			  FROM #constraints)
DECLARE @OldConstraintName NVARCHAR(500);
DECLARE @schemaname NVARCHAR(500);
DECLARE @NewConstraintName NVARCHAR(500);
DECLARE @Command NVARCHAR(2000)
DECLARE @constraint_code NVARCHAR(100);
DECLARE @tableName NVARCHAR(200);

WHILE @i <= @count
	BEGIN
		SELECT @schemaname = schemaname,
			@OldConstraintName = constraint_name,
			@tableName = table_view,
			@NewConstraintName = constraint_code + '_' + table_view + '_' + details,
			@constraint_code = constraint_code
		FROM #constraints
		WHERE RowNo = @i

		IF @OldConstraintName <> @NewConstraintName
			BEGIN
				IF @constraint_code IN ('UIndex', 'UCIndex')
					SET @Command = N'EXEC sp_rename N''' + @schemaname + N'.' + @tableName + N'.' + @OldConstraintName + N''', N''' + @NewConstraintName + N''', N''INDEX'''
				ELSE
					SET @Command = N'EXEC sp_rename N''' + @schemaname + N'.' + @OldConstraintName + N''', N''' + @NewConstraintName + N''', N''OBJECT'''
				print @Command
				EXEC (@command)
			END

		SET @i = @i + 1
	END

DROP TABLE IF EXISTS #constraints
