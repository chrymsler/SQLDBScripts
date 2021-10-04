# SQL Server Scripts

## [Default Constraint](default_constraints_rename.sql)

Update default constriants to a standard format. DF_\<Table Name>_\<Column Name>

## [Foreign Key](foreign_key_rename.sql)
  
Update foreign constraints to a standard format. FK_\<child table>_\<parent table>_\<column>

## [PK/UK/Index](pk_uk_index_rename.sql)

Update PK/UK/Index constraints to a standard format.
  
Primary Keys	PK_\<table name>_\<columns underscore separated>

Unique constraint	UK_\<table name>_\<columns underscore separated>

Unique index	UIndex_\<table name>_\<columns underscore separated>

Unique clustured index	UCIndex_\<table name>_\<columns underscore separated>
