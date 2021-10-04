SELECT o.name AS currConstraintName, c.name AS colName, t.name AS tableName, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNo
INTO #DefaultConstraints
FROM sysobjects o
	 INNER JOIN syscolumns c ON o.id = c.cdefault
	 INNER JOIN sysobjects t ON c.id = t.id
WHERE o.xtype = 'D'

DECLARE @count INT, @i INT = 1
SET @count = (SELECT MAX(RowNo)
			  FROM #DefaultConstraints)
DECLARE @currConstraintName NVARCHAR(500);
DECLARE @colName NVARCHAR(500);
DECLARE @tableName NVARCHAR(500);
DECLARE @NewConstraintName NVARCHAR(1500)
DECLARE @Command NVARCHAR(2500)

WHILE @i <= @count
	BEGIN
		SELECT @currConstraintName = currConstraintName, @colName = colName, @tableName = tableName FROM #DefaultConstraints WHERE RowNo = @i

		SET @NewConstraintName = N'DF_' + @tableName + N'_' + @colName

		IF @currConstraintName <> @NewConstraintName
			BEGIN
				SET @Command = N'EXEC sp_rename N''dbo.' + @currConstraintName + N''', N''' + @NewConstraintName + N''', N''OBJECT'''
				print @Command
				EXEC (@Command)
			END

		SET @i = @i + 1
	END

DROP TABLE IF EXISTS #DefaultConstraints
