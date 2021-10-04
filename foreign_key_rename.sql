SELECT SCHEMA_NAME(fk_tab.schema_id) AS SourceSchemaName,
	fk_tab.name AS foreign_table,
	fk.name AS fk_constraint_name,
	SCHEMA_NAME(pk_tab.schema_id) AS TargetSchemaName,
	pk_tab.name AS parent_table,
	ac.name colname,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNo
INTO #fkconstraints
FROM sys.foreign_keys fk
	 INNER JOIN sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id
	 INNER JOIN sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id
	 INNER JOIN sys.foreign_key_columns fk_cols ON fk_cols.constraint_object_id = fk.object_id
	 inner join sys.columns ac on ac.object_id = fk_cols.referenced_object_id and ac.column_id = fk_cols.referenced_column_id

SELECT *
FROM #fkconstraints

DECLARE @Count INT, @i INT = 1
SET @Count = (SELECT MAX(RowNo)
			  FROM #fkconstraints)
DECLARE @currFK NVARCHAR(500);
DECLARE @NewFK NVARCHAR(500);
DECLARE @Command NVARCHAR(2000);

WHILE @i <= @Count
	BEGIN
		SELECT @currFK = fk_constraint_name,
			@NewFK = 'FK_' + foreign_table + '_' + parent_table + '_' + colname
		FROM #fkconstraints
		WHERE RowNo = @i

		IF @currFK <> @NewFK
			BEGIN
				SET @Command = N'EXEC sp_rename N''dbo.' + @currFK + N''', N''' + @NewFK + N''', N''OBJECT'''
				print @command
				exec(@command)
			END

		SET @i = @i + 1
	END

DROP TABLE IF EXISTS #fkconstraints
