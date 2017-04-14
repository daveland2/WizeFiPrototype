SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO



IF SCHEMA_ID('Code') IS NULL
	EXEC('CREATE SCHEMA [Code]') 
GO




PRINT 'Add [Lookup] table' 
IF OBJECT_ID(N'[Code].[Lookup]') IS NOT NULL 
	DROP TABLE [Code].[Lookup] 
GO
CREATE TABLE [Code].[Lookup] ( 

	[LookupId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_Lookup] PRIMARY KEY CLUSTERED,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](50) NOT NULL,

	CONSTRAINT [AK_Lookup_Unique] UNIQUE NONCLUSTERED 
	( 
		[Name]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Code].[Lookup].[Name]'
EXEC sp_bindefault '[Default_String]', '[Code].[Lookup].[Description]'
GO



PRINT 'Add [Lookup] table' 
IF OBJECT_ID(N'[Code].[LookupItem]') IS NOT NULL 
	DROP TABLE [Code].[LookupItem] 
GO
CREATE TABLE [Code].[LookupItem] ( 

	[LookupItemId] [RecordID] IDENTITY(1,1) NOT NULL
		CONSTRAINT [AK_LookupItem_Key] UNIQUE NONCLUSTERED,
	[LookupId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_LookupItem_Lookup] FOREIGN KEY 
			REFERENCES [Code].[Lookup] ([LookupId]), 
	[ParentLookupItemId] [ReferenceID] NULL
		CONSTRAINT [FK_LookupItem_Parent] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([LookupItemId]), 
	[Name] [varchar](50) NOT NULL,
	[Code] [dbo].[AltKey] NOT NULL
		CONSTRAINT [PK_LookupItem] PRIMARY KEY CLUSTERED,
	[Description] [varchar](50) NOT NULL,
	[NumericData] [decimal](10, 4) NULL,
	[SortOrder] [dbo].[SortIndex] NOT NULL,

	CONSTRAINT [AK_LookupItem_Unique] UNIQUE NONCLUSTERED 
	( 
		[LookupId] ASC,
		[ParentLookupItemId] ASC,
		[Name] ASC
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Code].[LookupItem].[Name]'
EXEC sp_bindrule '[Rule_Req_String]', '[Code].[LookupItem].[Code]'
EXEC sp_bindefault '[Default_String]', '[Code].[LookupItem].[Description]'
EXEC sp_bindefault '[Default_SortIndex]', '[Code].[LookupItem].[SortOrder]'
GO




