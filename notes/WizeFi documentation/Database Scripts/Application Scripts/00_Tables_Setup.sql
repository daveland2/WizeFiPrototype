SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO

PRINT 'Create defaults'
GO
CREATE DEFAULT [Default_SortIndex] AS (0)
GO
CREATE DEFAULT [Default_ModDate] AS (cast(convert([varchar] (20), getdate(), 120) AS [datetime]))
GO
CREATE DEFAULT [Default_ModUser] AS (SUBSTRING(suser_sname(), CHARINDEX('\', suser_sname()) + 1, LEN(suser_sname())))
GO
CREATE DEFAULT [Default_String] AS ('')
GO
CREATE DEFAULT [Default_Boolean] AS (0)
GO
CREATE DEFAULT [Default_SoftDelete] AS (1)
GO
CREATE DEFAULT [Default_Currency] AS (0)
GO
CREATE DEFAULT [Default_Numeric] AS (0)
GO
CREATE RULE [Rule_Req_String] AS (datalength(@Value) > 0)
GO
CREATE RULE [Rule_Numeric_String] AS (isnumeric(isnull(nullif(@Value, ''), 0)) = 1) -- allows empty/null values
GO

PRINT 'Create UDTs'
GO
EXEC sp_addtype 'Factor', 'decimal (10,4)', 'NOT NULL'
EXEC sp_addtype 'Rate', 'decimal (6,4)', 'NOT NULL'
EXEC sp_addtype 'SortIndex', 'smallint', 'NOT NULL'
EXEC sp_addtype 'ModDate', 'datetime', 'NOT NULL'
EXEC sp_addtype 'ModUser', 'varchar (25)', 'NOT NULL'
EXEC sp_addtype 'RecordID', 'int', 'NOT NULL'
EXEC sp_addtype 'AltKey', 'varchar(8)', 'NOT NULL'
EXEC sp_addtype 'ReferenceID', 'int', 'NOT NULL'
EXEC sp_addtype 'Boolean', 'bit', 'NOT NULL'
EXEC sp_addtype 'SoftDelete', 'bit', 'NOT NULL'
EXEC sp_addtype 'Currency', 'money', 'NOT NULL'
EXEC sp_addtype 'LogDate', 'smalldatetime', 'NOT NULL'
GO

PRINT 'Bind defaults'
GO
EXEC sp_bindefault '[Default_SortIndex]', '[SortIndex]'
EXEC sp_bindefault '[Default_ModDate]', '[ModDate]'
EXEC sp_bindefault '[Default_ModUser]', '[ModUser]'
EXEC sp_bindefault '[Default_Boolean]', '[Boolean]'
EXEC sp_bindefault '[Default_SoftDelete]', '[SoftDelete]'
EXEC sp_bindefault '[Default_Currency]', '[Currency]'
EXEC sp_bindefault '[Default_Numeric]', '[Factor]'
EXEC sp_bindefault '[Default_Numeric]', '[Rate]'
GO

PRINT 'Add system messages'
GO
EXEC sp_addmessage 50001, 11, 'This record was modified by another user.', null, false, 'REPLACE'
EXEC sp_addmessage 50002, 11, 'This record was deleted by another user.', null, false,'REPLACE'
EXEC sp_addmessage 50003, 11, 'Expected parameter %s was not supplied.', null, false, 'REPLACE'
EXEC sp_addmessage 50004, 11, 'Cannot create a new %s because one already exists %s', null, false, 'REPLACE'
EXEC sp_addmessage 50005, 11, 'This %s cannot be deleted because %s', null, false, 'REPLACE'
EXEC sp_addmessage 50006, 11, 'This %s cannot be updated because %s', null, false, 'REPLACE'
GO
