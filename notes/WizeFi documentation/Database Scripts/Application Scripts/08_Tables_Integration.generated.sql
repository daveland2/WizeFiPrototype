SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO



IF SCHEMA_ID('Integration') IS NULL
	EXEC('CREATE SCHEMA [Integration]') 
GO




PRINT 'Add [PartnerMappingDefault] table' 
IF OBJECT_ID(N'[Integration].[PartnerMappingDefault]') IS NOT NULL 
	DROP TABLE [Integration].[PartnerMappingDefault] 
GO
CREATE TABLE [Integration].[PartnerMappingDefault] ( 

	[PartnerMappingDefaultId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_PartnerMappingDefault] PRIMARY KEY CLUSTERED,
	[PartnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_PartnerMappingDefault_Partner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[PartnerMappingTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_PartnerMappingDefault_PartnerMappingType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[LocalMappingAreaCode] [AltKey] NOT NULL
		CONSTRAINT [FK_PartnerMappingDefault_LocalMappingArea] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[LocalMappingTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_PartnerMappingDefault_LocalMappingType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[ForPartnerOnly] [Boolean] NOT NULL,
	[ForLocalOnly] [Boolean] NOT NULL,

	CONSTRAINT [AK_PartnerMappingDefault_Unique] UNIQUE NONCLUSTERED 
	( 
		[PartnerCode],
		[PartnerMappingTypeCode],
		[LocalMappingAreaCode],
		[LocalMappingTypeCode]
	)
) ON [PRIMARY]
GO



PRINT 'Add [IntegrationAccount] table' 
IF OBJECT_ID(N'[Integration].[IntegrationAccount]') IS NOT NULL 
	DROP TABLE [Integration].[IntegrationAccount] 
GO
CREATE TABLE [Integration].[IntegrationAccount] ( 

	[IntegrationAccountId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_IntegrationAccount] PRIMARY KEY CLUSTERED,
	[FinancialAdvisorId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_IntegrationAccount_FinancialAdvisor] FOREIGN KEY 
			REFERENCES [Advisor].[FinancialAdvisor] ([FinancialAdvisorId]), 
	[PartnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_IntegrationAccount_Partner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Username] [varchar](100) NOT NULL,
	[Password] [varchar](100) NOT NULL,
	[IsDefaultPartner] [Boolean] NOT NULL,
	[IntegrationDirectionDefaultCode] [AltKey] NOT NULL
		CONSTRAINT [FK_IntegrationAccount_IntegrationDirectionDefault] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[IsPartnerSourceDefault] [Boolean] NOT NULL,
	[ShowManualMappingDefault] [Boolean] NOT NULL,
	[EnableAutoSyncDefault] [Boolean] NOT NULL,
	[UserKey] [varchar](200) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Integration].[IntegrationAccount].[Username]'
EXEC sp_bindefault '[Default_String]', '[Integration].[IntegrationAccount].[Password]'
EXEC sp_bindefault '[Default_String]', '[Integration].[IntegrationAccount].[UserKey]'
GO



PRINT 'Add [BaselinePartnerConfig] table' 
IF OBJECT_ID(N'[Integration].[BaselinePartnerConfig]') IS NOT NULL 
	DROP TABLE [Integration].[BaselinePartnerConfig] 
GO
CREATE TABLE [Integration].[BaselinePartnerConfig] ( 

	[BaselinePartnerConfigId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_BaselinePartnerConfig] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_BaselinePartnerConfig_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[PartnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_BaselinePartnerConfig_Partner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[IntegrationDirectionCode] [AltKey] NOT NULL
		CONSTRAINT [FK_BaselinePartnerConfig_IntegrationDirection] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[IsPartnerSource] [Boolean] NOT NULL,
	[ShowManualMapping] [Boolean] NOT NULL,
	[EnableAutoSync] [Boolean] NOT NULL,
	[PartnerClientId] [int] NULL,

	CONSTRAINT [AK_BaselinePartnerConfig_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId],
		[PartnerCode]
	)
) ON [PRIMARY]
GO



PRINT 'Add [BaselineDataMappings] table' 
IF OBJECT_ID(N'[Integration].[BaselineDataMappings]') IS NOT NULL 
	DROP TABLE [Integration].[BaselineDataMappings] 
GO
CREATE TABLE [Integration].[BaselineDataMappings] ( 

	[BaselineDataMappingsId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_BaselineDataMappings] PRIMARY KEY CLUSTERED,
	[BaselinePartnerConfigId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_BaselineDataMappings_BaselinePartnerConfig] FOREIGN KEY 
			REFERENCES [Integration].[BaselinePartnerConfig] ([BaselinePartnerConfigId]), 
	[PartnerRecordId] [int] NULL,
	[LocalRecordId] [int] NULL,
	[Name] [varchar](200) NOT NULL,
	[ItemIdentifier] [varchar](60) NOT NULL,
	[SecondaryDescription] [varchar](200) NOT NULL,
	[Amount] [Currency] NOT NULL,
	[MiscData] [varchar](50) NOT NULL,
	[MiscCode] [varchar](15) NOT NULL,
	[MiscDate] [smalldatetime] NULL,
	[PartnerMappingTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_BaselineDataMappings_PartnerMappingType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[LocalMappingAreaCode] [AltKey] NOT NULL
		CONSTRAINT [FK_BaselineDataMappings_LocalMappingArea] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[LocalMappingTypeCode] [AltKey] NULL
		CONSTRAINT [FK_BaselineDataMappings_LocalMappingType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_BaselineDataMappings_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[Name]'
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[ItemIdentifier]'
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[SecondaryDescription]'
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[MiscData]'
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[MiscCode]'
GO

--<<#SQL_TABLE_SCRIPT#>>




