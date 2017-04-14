
--Lookup updates:
UPDATE [Code].[LookupItem] 
SET [Name] = 'Life: Universal'
WHERE [Code] = 'INS-UNIV'


DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Beneficiary'
INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT @LookupId, 'Estate', 'BEN-EST', '', 20


