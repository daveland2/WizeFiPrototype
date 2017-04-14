
ALTER TABLE [Consumer].[RealEstateAsset] 
ADD CONSTRAINT AK_RealEstateAsset_Unique UNIQUE (
( 
		[BaselineId],
		[OwnerCode],
		[PropertyTypeCode],
		[Description]
)
GO

EXEC sp_unbindefault '[Consumer].[RealEstateAsset].[Description]'
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[RealEstateAsset].[Description]'
GO



