
ALTER TABLE Integration.IntegrationAccount
ADD 
	UserKey [VARCHAR](100) NOT NULL DEFAULT(''),
	IsDefaultPartner [bit] NOT NULL DEFAULT(1),
	IntegrationDirectionDefaultCode [AltKey] NULL
		CONSTRAINT [FK_IntegrationAccount_IntegrationDirectionDefault] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	IsPartnerSourceDefault [bit] NOT NULL DEFAULT(1),
	ShowManualMappingDefault [bit] NOT NULL DEFAULT(1),
	EnableAutoSyncDefault [bit] NOT NULL DEFAULT(0)
GO

ALTER TABLE Integration.IntegrationAccount
ALTER COLUMN UserKey [VARCHAR](100) NOT NULL
ALTER TABLE Integration.IntegrationAccount
ALTER COLUMN IsDefaultPartner [Boolean]
ALTER TABLE Integration.IntegrationAccount
ALTER COLUMN EnableAutoSyncDefault [Boolean]
GO

ALTER TABLE Consumer.AssetProtection
ALTER COLUMN Insured [VARCHAR](70) NOT NULL
GO

ALTER TABLE Code.LookupItem
ALTER COLUMN Name [VARCHAR](50) NOT NULL
GO


--EXEC sp_bindefault '[Default_String]', '[Integration].[IntegrationAccount].[UserKey]'
--GO

--Indicate this integration partner supports storing just the UserKey for auth
UPDATE [Code].[LookupItem]
SET	
	NumericData = 1, 
	Description = 'RT'
WHERE [Code] = 'INT-RED'
GO


INSERT INTO [Code].[Lookup] ([Name], [Description])
SELECT		 'Integration Direction', ''
UNION SELECT 'Integration Partner Mapping', ''
UNION SELECT 'Integration Local Area', ''
GO


DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Integration Direction'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Import into MOPRO Only', 'DIR-IMP', '', 5
UNION SELECT @LookupId, 'Export out of MOPRO Only', 'DIR-EXP', '', 10
UNION SELECT @LookupId, 'Both Directions', 'DIR-BOTH', '', 15
GO


DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Integration Partner Mapping'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder, NumericData)
SELECT		 @LookupId, 'Do Not Import', 'RT-SKIP', '', 0, 1

UNION SELECT @LookupId, 'Profile Information', 'RT-PROF', '', 0, 1
UNION SELECT @LookupId, 'Family Member', 'RT-FAM', '', 1, 1

UNION SELECT @LookupId, 'Account: 401(k)', 'RT-ACT07', '', 2, 1
UNION SELECT @LookupId, 'Account: 529 Plan', 'RT-ACT12', '', 3, 1
UNION SELECT @LookupId, 'Account: Brokerage Account', 'RT-ACT03', '', 4, 1
UNION SELECT @LookupId, 'Account: Cash Management Account', 'RT-ACT23', '', 5, 1
UNION SELECT @LookupId, 'Account: Cash or Equivalents', 'RT-ACT38', '', 6, 1
UNION SELECT @LookupId, 'Account: Disability Insurance', 'RT-ACT17', '', 7, 1
UNION SELECT @LookupId, 'Account: Donor Advised Fund', 'RT-ACT24', '', 8, 1
UNION SELECT @LookupId, 'Account: Educational Savings Account', 'RT-ACT34', '', 9, 1
UNION SELECT @LookupId, 'Account: Fee-Based Account', 'RT-ACT08', '', 10, 1
UNION SELECT @LookupId, 'Account: Financial Plan', 'RT-ACT14', '', 11, 1
UNION SELECT @LookupId, 'Account: Fixed Annuity', 'RT-ACT06', '', 12, 1
UNION SELECT @LookupId, 'Account: Group Dental', 'RT-ACT29', '', 13, 1
UNION SELECT @LookupId, 'Account: Group Disability', 'RT-ACT32', '', 14, 1
UNION SELECT @LookupId, 'Account: Group Life', 'RT-ACT35', '', 15, 1
UNION SELECT @LookupId, 'Account: Group Long Term Care', 'RT-ACT31', '', 16, 1
UNION SELECT @LookupId, 'Account: Group Medical', 'RT-ACT28', '', 17, 1
UNION SELECT @LookupId, 'Account: Group Voluntary Life', 'RT-ACT36', '', 18, 1
UNION SELECT @LookupId, 'Account: Indexed Annuity', 'RT-ACT21', '', 19, 1
UNION SELECT @LookupId, 'Account: Individual Dental', 'RT-ACT30', '', 20, 1
UNION SELECT @LookupId, 'Account: Individual Life', 'RT-ACT22', '', 21, 1
UNION SELECT @LookupId, 'Account: Individual Medical', 'RT-ACT27', '', 22, 1
UNION SELECT @LookupId, 'Account: ISI Capital Account', 'RT-ACT09', '', 23, 1
UNION SELECT @LookupId, 'Account: Long Term Care', 'RT-ACT18', '', 24, 1
UNION SELECT @LookupId, 'Account: Long Term Disability', 'RT-ACT16', '', 25, 1
UNION SELECT @LookupId, 'Account: Medicare Advantage Plan', 'RT-ACT40', '', 26, 1
UNION SELECT @LookupId, 'Account: Medicare Prescription Drug Plan (Part D)', 'RT-ACT41', '', 27, 1
UNION SELECT @LookupId, 'Account: Medicare Supplement Plan', 'RT-ACT42', '', 28, 1
UNION SELECT @LookupId, 'Account: Mutual Fund', 'RT-ACT04', '', 29, 1
UNION SELECT @LookupId, 'Account: Other', 'RT-ACT13', '', 30, 1
UNION SELECT @LookupId, 'Account: Pooled Income Fund', 'RT-ACT26', '', 31, 1
UNION SELECT @LookupId, 'Account: Profit Sharing', 'RT-ACT11', '', 32, 1
UNION SELECT @LookupId, 'Account: REIT', 'RT-ACT33', '', 33, 1
UNION SELECT @LookupId, 'Account: Return of Premium Term Life Insurance', 'RT-ACT43', '', 34, 1
UNION SELECT @LookupId, 'Account: Select Roth IRA', 'RT-ACT44', '', 35, 1
UNION SELECT @LookupId, 'Account: Separately Managed Account', 'RT-ACT25', '', 36, 1
UNION SELECT @LookupId, 'Account: Sole 401(k)', 'RT-ACT15', '', 37, 1
UNION SELECT @LookupId, 'Account: Term Life', 'RT-ACT05', '', 38, 1
UNION SELECT @LookupId, 'Account: Universal Life', 'RT-ACT19', '', 39, 1
UNION SELECT @LookupId, 'Account: Variable Annuity', 'RT-ACT01', '', 40, 1
UNION SELECT @LookupId, 'Account: Variable Life', 'RT-ACT39', '', 41, 1
UNION SELECT @LookupId, 'Account: Variable Universal Life', 'RT-ACT02', '', 42, 1
UNION SELECT @LookupId, 'Account: Whole Life', 'RT-ACT20', '', 43, 1
UNION SELECT @LookupId, 'Account: Worker''s Comp', 'RT-ACT37', '', 44, 1

UNION SELECT @LookupId, 'Account: Tax Type - None', 'RT-TXT00', '', 47, 1
UNION SELECT @LookupId, 'Account: Tax Type - 401(a)', 'RT-TXT21', '', 48, 1
UNION SELECT @LookupId, 'Account: Tax Type - 401(k)', 'RT-TXT07', '', 49, 1
UNION SELECT @LookupId, 'Account: Tax Type - 403(a)', 'RT-TXT22', '', 50, 1
UNION SELECT @LookupId, 'Account: Tax Type - 403(b)', 'RT-TXT03', '', 51, 1
UNION SELECT @LookupId, 'Account: Tax Type - 457 Plan', 'RT-TXT04', '', 52, 1
UNION SELECT @LookupId, 'Account: Tax Type - 529 Plan', 'RT-TXT15', '', 53, 1
UNION SELECT @LookupId, 'Account: Tax Type - Beneficiary IRA', 'RT-TXT20', '', 54, 1
UNION SELECT @LookupId, 'Account: Tax Type - Educational IRA', 'RT-TXT05', '', 55, 1
UNION SELECT @LookupId, 'Account: Tax Type - Health Savings Account', 'RT-TXT17', '', 56, 1
UNION SELECT @LookupId, 'Account: Tax Type - HR10', 'RT-TXT06', '', 57, 1
UNION SELECT @LookupId, 'Account: Tax Type - Medical Savings Account', 'RT-TXT18', '', 58, 1
UNION SELECT @LookupId, 'Account: Tax Type - Non Deductible IRA', 'RT-TXT19', '', 59, 1
UNION SELECT @LookupId, 'Account: Tax Type - Other', 'RT-TXT09', '', 60, 1
UNION SELECT @LookupId, 'Account: Tax Type - Pension Plan', 'RT-TXT08', '', 61, 1
UNION SELECT @LookupId, 'Account: Tax Type - Profit Sharing Plan', 'RT-TXT12', '', 62, 1
UNION SELECT @LookupId, 'Account: Tax Type - Rollover IRA', 'RT-TXT16', '', 63, 1
UNION SELECT @LookupId, 'Account: Tax Type - Roth IRA', 'RT-TXT01', '', 64, 1
UNION SELECT @LookupId, 'Account: Tax Type - SEP IRA', 'RT-TXT10', '', 65, 1
UNION SELECT @LookupId, 'Account: Tax Type - Simple IRA', 'RT-TXT11', '', 66, 1
UNION SELECT @LookupId, 'Account: Tax Type - Traditional IRA', 'RT-TXT02', '', 67, 1
UNION SELECT @LookupId, 'Account: Tax Type - UGMA', 'RT-TXT14', '', 68, 1
UNION SELECT @LookupId, 'Account: Tax Type - UTMA', 'RT-TXT13', '', 69, 1

UNION SELECT @LookupId, 'Asset: None', 'RT-AST00', '', 72, 1
UNION SELECT @LookupId, 'Asset: 401(k)', 'RT-AST17', '', 73, 1
UNION SELECT @LookupId, 'Asset: Annuity', 'RT-AST15', '', 74, 1
UNION SELECT @LookupId, 'Asset: Automobile', 'RT-AST11', '', 75, 1
UNION SELECT @LookupId, 'Asset: Bond', 'RT-AST10', '', 76, 1
UNION SELECT @LookupId, 'Asset: Brokerage Account', 'RT-AST19', '', 77, 1
UNION SELECT @LookupId, 'Asset: CD', 'RT-AST04', '', 78, 1
UNION SELECT @LookupId, 'Asset: Checking Account', 'RT-AST01', '', 79, 1
UNION SELECT @LookupId, 'Asset: Collectables', 'RT-AST16', '', 80, 1
UNION SELECT @LookupId, 'Asset: IRA', 'RT-AST13', '', 81, 1
UNION SELECT @LookupId, 'Asset: Life Insurance', 'RT-AST18', '', 82, 1
UNION SELECT @LookupId, 'Asset: Managed Accounts', 'RT-AST12', '', 83, 1
UNION SELECT @LookupId, 'Asset: Money Market', 'RT-AST03', '', 84, 1
UNION SELECT @LookupId, 'Asset: Mutual Fund', 'RT-AST07', '', 85, 1
UNION SELECT @LookupId, 'Asset: Other', 'RT-AST09', '', 86, 1
UNION SELECT @LookupId, 'Asset: Pension', 'RT-AST14', '', 87, 1
UNION SELECT @LookupId, 'Asset: Real Estate', 'RT-AST08', '', 88, 1
UNION SELECT @LookupId, 'Asset: Savings Account', 'RT-AST02', '', 89, 1
UNION SELECT @LookupId, 'Asset: Stock', 'RT-AST06', '', 90, 1
UNION SELECT @LookupId, 'Asset: T-Bill', 'RT-AST05', '', 91, 1

UNION SELECT @LookupId, 'Liability: None', 'RT-LIA00', '', 92, 1
UNION SELECT @LookupId, 'Liability: Auto Loan', 'RT-LIA01', '', 93, 1
UNION SELECT @LookupId, 'Liability: Credit Card Debt', 'RT-LIA02', '', 94, 1
UNION SELECT @LookupId, 'Liability: Mortgage', 'RT-LIA03', '', 95, 1
UNION SELECT @LookupId, 'Liability: Other', 'RT-LIA04', '', 96, 1
UNION SELECT @LookupId, 'Liability: Personal Loan', 'RT-LIA05', '', 97, 1
GO



DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Integration Local Area'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Do Not Import', 'MOP-SKIP', '', 0
UNION SELECT @LookupId, 'Profile Information', 'MOP-PROF', '', 3
UNION SELECT @LookupId, 'Family Member', 'MOP-FAM', '', 7
UNION SELECT @LookupId, 'Asset: Bank Account', 'MOP-BANK', '', 10
UNION SELECT @LookupId, 'Asset: Asset Protection', 'MOP-ASST', '', 15
UNION SELECT @LookupId, 'Asset: CDs', 'MOP-CD', '', 20
UNION SELECT @LookupId, 'Asset: Taxable', 'MOP-TAX', '', 30
UNION SELECT @LookupId, 'Asset: Tax-Advantaged', 'MOP-NOTX', '', 40
UNION SELECT @LookupId, 'Asset: Real-Estate', 'MOP-REAL', '', 50
UNION SELECT @LookupId, 'Asset: Personal', 'MOP-PERS', '', 60
UNION SELECT @LookupId, 'Asset: Other', 'MOP-OTH', '', 70
UNION SELECT @LookupId, 'Liability: Real-Estate', 'MOP-LI-P', '', 80
UNION SELECT @LookupId, 'Liability: Other', 'MOP-LI-O', '', 90
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

--Have to modify this since by making it part of the signature, it autmatically gets set to required
ALTER TABLE [Integration].[PartnerMappingDefault]
ALTER COLUMN [LocalMappingTypeCode] [AltKey] NULL
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
	[ItemIdentifier] [varchar](60) NOT NULL,
	[Name] [varchar](200) NOT NULL,
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
	[OwnerCode] [AltKey] NULL
		CONSTRAINT [FK_BaselineDataMappings_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[ItemIdentifier]'
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[Name]'
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[SecondaryDescription]'
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[MiscData]'
EXEC sp_bindefault '[Default_String]', '[Integration].[BaselineDataMappings].[MiscCode]'
GO




--Add account number too all applicable places
ALTER TABLE Consumer.AssetProtection
ADD 
	AccountNumber [VARCHAR](60) NULL
GO
EXEC sp_bindefault '[Default_String]', 'Consumer.AssetProtection.[AccountNumber]'
GO
UPDATE Consumer.AssetProtection SET AccountNumber = ''
GO
ALTER TABLE Consumer.AssetProtection
ALTER COLUMN AccountNumber [VARCHAR](60) NOT NULL
GO


ALTER TABLE Consumer.BankAsset
ADD 
	AccountNumber [VARCHAR](60) NULL
GO
EXEC sp_bindefault '[Default_String]', 'Consumer.BankAsset.[AccountNumber]'
GO
UPDATE Consumer.BankAsset SET AccountNumber = ''
GO
ALTER TABLE Consumer.BankAsset
ALTER COLUMN AccountNumber [VARCHAR](60) NOT NULL
GO


ALTER TABLE Consumer.CdAsset
ADD 
	AccountNumber [VARCHAR](60) NULL
GO
EXEC sp_bindefault '[Default_String]', 'Consumer.CdAsset.[AccountNumber]'
GO
UPDATE Consumer.CdAsset SET AccountNumber = ''
GO
ALTER TABLE Consumer.CdAsset
ALTER COLUMN AccountNumber [VARCHAR](60) NOT NULL
GO


ALTER TABLE Consumer.OtherLiability
ADD 
	AccountNumber [VARCHAR](60) NULL
GO
EXEC sp_bindefault '[Default_String]', 'Consumer.OtherLiability.[AccountNumber]'
GO
UPDATE Consumer.OtherLiability SET AccountNumber = ''
GO
ALTER TABLE Consumer.OtherLiability
ALTER COLUMN AccountNumber [VARCHAR](60) NOT NULL
GO


ALTER TABLE Consumer.RealEstateLiability
ADD 
	AccountNumber [VARCHAR](60) NULL
GO
EXEC sp_bindefault '[Default_String]', 'Consumer.RealEstateLiability.[AccountNumber]'
GO
UPDATE Consumer.RealEstateLiability SET AccountNumber = ''
GO
ALTER TABLE Consumer.RealEstateLiability
ALTER COLUMN AccountNumber [VARCHAR](60) NOT NULL
GO


ALTER TABLE Consumer.TaxableInvestmentAsset
ADD 
	AccountNumber [VARCHAR](60) NULL
GO
EXEC sp_bindefault '[Default_String]', 'Consumer.TaxableInvestmentAsset.[AccountNumber]'
GO
UPDATE Consumer.TaxableInvestmentAsset SET AccountNumber = ''
GO
ALTER TABLE Consumer.TaxableInvestmentAsset
ALTER COLUMN AccountNumber [VARCHAR](60) NOT NULL
GO


ALTER TABLE Consumer.TaxAdvantagedAsset
ADD 
	AccountNumber [VARCHAR](60) NULL
GO
EXEC sp_bindefault '[Default_String]', 'Consumer.TaxAdvantagedAsset.[AccountNumber]'
GO
UPDATE Consumer.TaxAdvantagedAsset SET AccountNumber = ''
GO
ALTER TABLE Consumer.TaxAdvantagedAsset
ALTER COLUMN AccountNumber [VARCHAR](60) NOT NULL
GO


DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Advisor Ranking'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT @LookupId, 'Not Declared', 'RNK-UNSE', '', 0
GO


INSERT INTO Integration.PartnerMappingDefault (PartnerCode, PartnerMappingTypeCode, LocalMappingAreaCode, LocalMappingTypeCode, ForPartnerOnly, ForLocalOnly)
SELECT		 'INT-RED', 'RT-PROF', 'MOP-PROF', NULL, 0, 0
UNION SELECT 'INT-RED', 'RT-FAM', 'MOP-FAM', NULL, 0, 0
UNION SELECT 'INT-RED', 'RT-ACT07', 'MOP-NOTX', 'TAX-401K', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT12', 'MOP-NOTX', 'TAX-CLGE', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT03', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-ACT23', 'MOP-BANK', 'ACCT-GEN', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT38', 'MOP-BANK', 'ACCT-GEN', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT17', 'MOP-ASST', 'INS-DIS', 0, 0
UNION SELECT 'INT-RED', 'RT-ACT24', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-ACT34', 'MOP-NOTX', 'TAX-CLGE', 0, 0
UNION SELECT 'INT-RED', 'RT-ACT08', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-ACT14', 'MOP-OTH', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-ACT06', 'MOP-NOTX', 'TAX-ANN', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT29', 'MOP-ASST', 'INS-DENT', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT32', 'MOP-ASST', 'INS-DIS', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT35', 'MOP-ASST', 'INS-GRP', 0, 0
UNION SELECT 'INT-RED', 'RT-ACT31', 'MOP-ASST', 'INS-LTC', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT28', 'MOP-ASST', 'INS-MED', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT36', 'MOP-ASST', 'INS-GRP', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT21', 'MOP-NOTX', 'TAX-ANN', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT30', 'MOP-ASST', 'INS-DENT', 0, 0
UNION SELECT 'INT-RED', 'RT-ACT22', 'MOP-ASST', 'INS-WHOL', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT27', 'MOP-ASST', 'INS-MED', 0, 0
UNION SELECT 'INT-RED', 'RT-ACT09', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-ACT18', 'MOP-ASST', 'INS-LTC', 0, 0
UNION SELECT 'INT-RED', 'RT-ACT16', 'MOP-ASST', 'INS-DIS', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT40', 'MOP-ASST', 'INS-OTH', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT41', 'MOP-ASST', 'INS-OTH', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT42', 'MOP-ASST', 'INS-OTH', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT04', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-TXT21', 'MOP-NOTX', 'TAX-401K', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT07', 'MOP-NOTX', 'TAX-401K', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT22', 'MOP-NOTX', 'TAX-403B', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT03', 'MOP-NOTX', 'TAX-403B', 0, 0
UNION SELECT 'INT-RED', 'RT-TXT04', 'MOP-NOTX', 'TAX-457B', 0, 0
UNION SELECT 'INT-RED', 'RT-TXT15', 'MOP-NOTX', 'TAX-CLGE', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT20', 'MOP-NOTX', 'TAX-IRA', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT05', 'MOP-NOTX', 'TAX-CLGE', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT17', 'MOP-NOTX', 'TAX-HSA', 0, 0
UNION SELECT 'INT-RED', 'RT-TXT06', 'MOP-NOTX', 'TAX-PENS', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT18', 'MOP-NOTX', 'TAX-HSA', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT19', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-TXT09', 'MOP-NOTX', 'TAX-OTH', 0, 0
UNION SELECT 'INT-RED', 'RT-TXT08', 'MOP-NOTX', 'TAX-PENS', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT12', 'MOP-NOTX', 'TAX-OTH', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT16', 'MOP-NOTX', 'TAX-IRA', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT01', 'MOP-NOTX', 'TAX-ROTH', 0, 0
UNION SELECT 'INT-RED', 'RT-TXT10', 'MOP-NOTX', 'TAX-SEP', 0, 0
UNION SELECT 'INT-RED', 'RT-TXT11', 'MOP-NOTX', 'TAX-SIRA', 0, 0
UNION SELECT 'INT-RED', 'RT-TXT02', 'MOP-NOTX', 'TAX-IRA', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT14', 'MOP-NOTX', 'TAX-CLGE', 1, 0
UNION SELECT 'INT-RED', 'RT-TXT13', 'MOP-NOTX', 'TAX-CLGE', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT13', 'MOP-TAX', NULL, 0, 0
UNION SELECT 'INT-RED', 'RT-ACT26', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-ACT11', 'MOP-NOTX', 'TAX-OTH', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT33', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-ACT43', 'MOP-ASST', 'INS-TERM', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT44', 'MOP-NOTX', 'TAX-ROTH', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT25', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-ACT15', 'MOP-NOTX', 'TAX-401K', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT05', 'MOP-ASST', 'INS-TERM', 0, 0
UNION SELECT 'INT-RED', 'RT-ACT19', 'MOP-ASST', 'INS-UNIV', 0, 0
UNION SELECT 'INT-RED', 'RT-ACT01', 'MOP-NOTX', 'TAX-ANN', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT39', 'MOP-ASST', 'INS-VARU', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT02', 'MOP-ASST', 'INS-VARU', 0, 0
UNION SELECT 'INT-RED', 'RT-ACT20', 'MOP-ASST', 'INS-WHOL', 1, 0
UNION SELECT 'INT-RED', 'RT-ACT37', 'MOP-ASST', 'INS-OTH', 1, 0
UNION SELECT 'INT-RED', 'RT-AST17', 'MOP-NOTX', 'TAX-401K', 0, 0
UNION SELECT 'INT-RED', 'RT-AST15', 'MOP-NOTX', 'TAX-ANN', 0, 0
UNION SELECT 'INT-RED', 'RT-AST11', 'MOP-PERS', 'PPT-AUTO', 0, 0
UNION SELECT 'INT-RED', 'RT-AST10', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-AST19', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-AST04', 'MOP-CD', NULL, 0, 0
UNION SELECT 'INT-RED', 'RT-AST01', 'MOP-BANK', 'ACCT-GEN', 1, 0
UNION SELECT 'INT-RED', 'RT-AST16', 'MOP-PERS', 'PPT-COLL', 0, 0
UNION SELECT 'INT-RED', 'RT-AST13', 'MOP-NOTX', 'TAX-IRA', 0, 0
UNION SELECT 'INT-RED', 'RT-AST18', 'MOP-ASST', 'INS-WHOL', 0, 0
UNION SELECT 'INT-RED', 'RT-AST12', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-AST03', 'MOP-BANK', 'ACCT-MMA', 0, 0
UNION SELECT 'INT-RED', 'RT-AST07', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-AST09', 'MOP-OTH', NULL, 0, 0
UNION SELECT 'INT-RED', 'RT-AST14', 'MOP-NOTX', 'TAX-PENS', 0, 0
UNION SELECT 'INT-RED', 'RT-AST08', 'MOP-REAL', 'REAL-OTH', 0, 0
UNION SELECT 'INT-RED', 'RT-AST02', 'MOP-BANK', 'ACCT-GEN', 0, 0
UNION SELECT 'INT-RED', 'RT-AST06', 'MOP-TAX', NULL, 1, 0
UNION SELECT 'INT-RED', 'RT-AST05', 'MOP-TAX', NULL, 1, 0

UNION SELECT 'INT-RED', 'RT-AST02', 'MOP-BANK', 'ACCT-EMG', 0, 1
UNION SELECT 'INT-RED', 'RT-AST02', 'MOP-BANK', 'ACCT-XMS', 0, 1
UNION SELECT 'INT-RED', 'RT-AST02', 'MOP-BANK', 'ACCT-VAC', 0, 1
UNION SELECT 'INT-RED', 'RT-ACT27', 'MOP-ASST', 'INS-VIS', 0, 1
UNION SELECT 'INT-RED', 'RT-SKIP', 'MOP-ASST', 'INS-HO', 0, 1
UNION SELECT 'INT-RED', 'RT-SKIP', 'MOP-ASST', 'INS-AUTO', 0, 1
UNION SELECT 'INT-RED', 'RT-SKIP', 'MOP-ASST', 'INS-RV', 0, 1
UNION SELECT 'INT-RED', 'RT-SKIP', 'MOP-ASST', 'INS-UMB', 0, 1
UNION SELECT 'INT-RED', 'RT-SKIP', 'MOP-ASST', 'INS-EO', 0, 1
UNION SELECT 'INT-RED', 'RT-SKIP', 'MOP-ASST', 'INS-OTH', 0, 1
UNION SELECT 'INT-RED', 'RT-AST17', 'MOP-NOTX', 'TAX-R401', 0, 1
UNION SELECT 'INT-RED', 'RT-AST08', 'MOP-REAL', 'REAL-PRI', 0, 1
UNION SELECT 'INT-RED', 'RT-AST08', 'MOP-REAL', 'REAL-SEC', 0, 1
UNION SELECT 'INT-RED', 'RT-AST08', 'MOP-REAL', 'REAL-REN', 0, 1
UNION SELECT 'INT-RED', 'RT-AST08', 'MOP-REAL', 'REAL-LND', 0, 1
UNION SELECT 'INT-RED', 'RT-AST08', 'MOP-REAL', 'REAL-COM', 0, 1
UNION SELECT 'INT-RED', 'RT-AST11', 'MOP-PERS', 'PPT-RV', 0, 1
UNION SELECT 'INT-RED', 'RT-AST09', 'MOP-PERS', 'PPT-OTH', 0, 1
UNION SELECT 'INT-RED', 'RT-LIA01', 'MOP-LI-O', 'LIA-AUTO', 0, 0
UNION SELECT 'INT-RED', 'RT-LIA02', 'MOP-LI-O', 'LIA-CC', 0, 0
UNION SELECT 'INT-RED', 'RT-LIA03', 'MOP-LI-P', 'MORT-FIX', 0, 1
UNION SELECT 'INT-RED', 'RT-LIA03', 'MOP-LI-P', 'MORT-ARM', 0, 1
UNION SELECT 'INT-RED', 'RT-LIA03', 'MOP-LI-P', 'MORT-INT', 0, 1
UNION SELECT 'INT-RED', 'RT-LIA03', 'MOP-LI-P', 'MORT-LOC', 0, 1
UNION SELECT 'INT-RED', 'RT-LIA03', 'MOP-LI-P', 'MORT-OTH', 0, 0
UNION SELECT 'INT-RED', 'RT-LIA04', 'MOP-LI-O', 'LIA-OTH', 0, 0
UNION SELECT 'INT-RED', 'RT-LIA05', 'MOP-LI-O', 'LIA-PERS', 0, 0
UNION SELECT 'INT-RED', 'RT-LIA04', 'MOP-LI-O', 'LIA-LOC', 0, 1
UNION SELECT 'INT-RED', 'RT-LIA04', 'MOP-LI-O', 'LIA-RV', 0, 1
UNION SELECT 'INT-RED', 'RT-LIA04', 'MOP-LI-O', 'LIA-BIZ', 0, 1
UNION SELECT 'INT-RED', 'RT-LIA04', 'MOP-LI-O', 'LIA-STUD', 0, 1

UNION SELECT 'INT-RED', 'RT-SKIP', 'MOP-SKIP', NULL, 0, 0
GO



INSERT INTO Integration.BaselinePartnerConfig (BaselineId, PartnerCode, IntegrationDirectionCode, IsPartnerSource, ShowManualMapping, EnableAutoSync, PartnerClientId)
SELECT BaselineId, 'INT-RED', 'DIR-BOTH',	1,	1,	0, CrmLinkingId
FROM Consumer.Baseline
WHERE CrmLinkingId > 0
GO

INSERT INTO Integration.BaselineDataMappings (BaselinePartnerConfigId, PartnerRecordId, LocalRecordId, ItemIdentifier, Name, SecondaryDescription, Amount, MiscData, MiscCode, MiscDate, PartnerMappingTypeCode, LocalMappingAreaCode, LocalMappingTypeCode, OwnerCode)
SELECT BC.BaselinePartnerConfigId, BC.PartnerClientId, B.BaselineId, '', 'Basic Profile Info', '', 0, '', '', NULL, 'RT-PROF', 'MOP-PROF', NULL, 'CO-PRI'
FROM 
	Consumer.Baseline B
	JOIN Integration.BaselinePartnerConfig BC
		ON B.BaselineId = BC.BaselineId
			AND BC.PartnerCode = 'INT-RED'
GO

INSERT INTO Integration.BaselineDataMappings (BaselinePartnerConfigId, PartnerRecordId, LocalRecordId, ItemIdentifier, Name, SecondaryDescription, Amount, MiscData, MiscCode, MiscDate, PartnerMappingTypeCode, LocalMappingAreaCode, LocalMappingTypeCode, OwnerCode)
SELECT BC.BaselinePartnerConfigId, FM.CrmLinkingId, FamilyMemberId, LastName, FirstName, MiddleName, 0, Gender, REL.Name, BirthDate, 'RT-FAM', 'MOP-FAM', NULL, 'CO-PRI'
FROM 
	Consumer.FamilyMember FM 
	JOIN Code.LookupItem REL 
		ON FM.RelationshipCode = REL.Code
	JOIN Consumer.Baseline B
		ON FM.BaselineId = B.BaselineId 
	JOIN Integration.BaselinePartnerConfig BC
		ON B.BaselineId = BC.BaselineId
			AND BC.PartnerCode = 'INT-RED'
WHERE FM.CrmLinkingId > 0
GO

ALTER TABLE Consumer.Baseline
DROP COLUMN CrmLinkingId
ALTER TABLE Consumer.Baseline
DROP COLUMN WealthLinkingId
ALTER TABLE Consumer.FamilyMember
DROP COLUMN CrmLinkingId
GO


