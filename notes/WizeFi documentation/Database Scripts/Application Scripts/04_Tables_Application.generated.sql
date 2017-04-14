SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO



IF SCHEMA_ID('Application') IS NULL
	EXEC('CREATE SCHEMA [Application]') 
GO




PRINT 'Add [ConfigurationItem] table' 
IF OBJECT_ID(N'[Application].[ConfigurationItem]') IS NOT NULL 
	DROP TABLE [Application].[ConfigurationItem] 
GO
CREATE TABLE [Application].[ConfigurationItem] ( 

	[ConfigurationItemId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_ConfigurationItem] PRIMARY KEY NONCLUSTERED,
	[KeyName] [varchar](30) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[Value] [varchar](15) NOT NULL,
	[IsSystem] [Boolean] NOT NULL,

	CONSTRAINT [AK_ConfigurationItem_Unique] UNIQUE CLUSTERED 
	( 
		[KeyName]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Application].[ConfigurationItem].[KeyName]'
EXEC sp_bindefault '[Default_String]', '[Application].[ConfigurationItem].[Description]'
EXEC sp_bindrule '[Rule_Req_String]', '[Application].[ConfigurationItem].[Value]'
GO



PRINT 'Add [SiteMap] table' 
IF OBJECT_ID(N'[Application].[SiteMap]') IS NOT NULL 
	DROP TABLE [Application].[SiteMap] 
GO
CREATE TABLE [Application].[SiteMap] ( 

	[SiteMapId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_SiteMap] PRIMARY KEY NONCLUSTERED,
	[Module] [varchar](30) NOT NULL,
	[TabGroup] [varchar](30) NOT NULL,
	[Subgroup] [varchar](30) NOT NULL,
	[Title] [varchar](30) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[Uri] [varchar](100) NOT NULL,
	[Value] [varchar](15) NOT NULL,
	[IsWizardStep] [Boolean] NOT NULL,
	[IsActive] [Boolean] NOT NULL,
	[ParentId] [ReferenceID] NULL
		CONSTRAINT [FK_SiteMap_Parent] FOREIGN KEY 
			REFERENCES [Application].[SiteMap] ([SiteMapId]), 

	CONSTRAINT [AK_SiteMap_Unique] UNIQUE CLUSTERED 
	( 
		[Module],
		[TabGroup],
		[Subgroup],
		[Title]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Application].[SiteMap].[Module]'
EXEC sp_bindrule '[Rule_Req_String]', '[Application].[SiteMap].[TabGroup]'
EXEC sp_bindrule '[Rule_Req_String]', '[Application].[SiteMap].[Subgroup]'
EXEC sp_bindrule '[Rule_Req_String]', '[Application].[SiteMap].[Title]'
EXEC sp_bindefault '[Default_String]', '[Application].[SiteMap].[Description]'
EXEC sp_bindefault '[Default_String]', '[Application].[SiteMap].[Uri]'
EXEC sp_bindrule '[Rule_Req_String]', '[Application].[SiteMap].[Value]'
GO

--<<#SQL_TABLE_SCRIPT#>>


