

PRINT 'Add [FinancialPlan] table' 
IF OBJECT_ID(N'[Consumer].[FinancialPlan]') IS NOT NULL 
	DROP TABLE [Consumer].[FinancialPlan] 
GO
CREATE TABLE [Consumer].[FinancialPlan] ( 

	[FinancialPlanId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_FinancialPlan] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_FinancialPlan_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[PrimaryRetirementAge] [tinyint] NOT NULL,
	[PrimaryRetiredMonthlyExpenses] [Currency] NOT NULL,
	[PrimaryDeathFund] [Currency] NOT NULL,
	[SecondaryRetirementAge] [tinyint] NOT NULL,
	[SecondaryRetiredMonthlyExpenses] [Currency] NOT NULL,
	[SecondaryDeathFund] [Currency] NOT NULL,
	[PrimaryCurrentPlanProjection] [varchar](100) NOT NULL,
	[PrimaryNewPlanProjection] [varchar](100) NOT NULL,
	[SecondaryCurrentPlanProjection] [varchar](100) NOT NULL,
	[SecondaryNewPlanProjection] [varchar](100) NOT NULL,
	[Comments] [varchar](500) NOT NULL,

	CONSTRAINT [AK_FinancialPlan_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId]
	)
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[FinancialPlan].[PrimaryCurrentPlanProjection]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FinancialPlan].[PrimaryNewPlanProjection]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FinancialPlan].[SecondaryCurrentPlanProjection]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FinancialPlan].[SecondaryNewPlanProjection]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FinancialPlan].[Comments]'
GO



PRINT 'Add [PrimaryConsumerIncomeDeductions] table' 
IF OBJECT_ID(N'[Consumer].[PrimaryConsumerIncomeDeductions]') IS NOT NULL 
	DROP TABLE [Consumer].[PrimaryConsumerIncomeDeductions] 
GO
CREATE TABLE [Consumer].[PrimaryConsumerIncomeDeductions] ( 

	[PrimaryConsumerIncomeDeductionsId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_PrimaryConsumerIncomeDeductions] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_PrimaryConsumerIncomeDeductions_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[RetirementLoanRepaymemt] [Currency] NOT NULL,
	[OtherPayrollDeductionDescription] [varchar](50) NOT NULL,
	[OtherPayrollDeductionAmount] [Currency] NOT NULL,
	[OtherNonPayrollDeductionDescription] [varchar](50) NOT NULL,
	[OtherNonPayrollDeductionAmount] [Currency] NOT NULL,
	[FederalTax] [Currency] NOT NULL,
	[Fica] [Currency] NOT NULL,
	[Medicare] [Currency] NOT NULL,
	[StateTax] [Currency] NOT NULL,
	[StateDisabilityInsurance] [Currency] NOT NULL,
	[UnionDue] [Currency] NOT NULL,
	[MedicalHealth] [Currency] NOT NULL,
	[Dental] [Currency] NOT NULL,
	[GroupLifeInsurance] [Currency] NOT NULL,
	[DisabilityInsurance] [Currency] NOT NULL,
	[Comments] [varchar](500) NOT NULL,

	CONSTRAINT [AK_PrimaryConsumerIncomeDeductions_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId]
	)
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumerIncomeDeductions].[OtherPayrollDeductionDescription]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumerIncomeDeductions].[OtherNonPayrollDeductionDescription]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumerIncomeDeductions].[Comments]'
GO



PRINT 'Add [SecondaryConsumerIncomeDeductions] table' 
IF OBJECT_ID(N'[Consumer].[SecondaryConsumerIncomeDeductions]') IS NOT NULL 
	DROP TABLE [Consumer].[SecondaryConsumerIncomeDeductions] 
GO
CREATE TABLE [Consumer].[SecondaryConsumerIncomeDeductions] ( 

	[SecondaryConsumerIncomeDeductionsId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_SecondaryConsumerIncomeDeductions] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_SecondaryConsumerIncomeDeductions_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[RetirementLoanRepaymemt] [Currency] NOT NULL,
	[OtherPayrollDeductionDescription] [varchar](50) NOT NULL,
	[OtherPayrollDeductionAmount] [Currency] NOT NULL,
	[OtherNonPayrollDeductionDescription] [varchar](50) NOT NULL,
	[OtherNonPayrollDeductionAmount] [Currency] NOT NULL,
	[FederalTax] [Currency] NOT NULL,
	[Fica] [Currency] NOT NULL,
	[Medicare] [Currency] NOT NULL,
	[StateTax] [Currency] NOT NULL,
	[StateDisabilityInsurance] [Currency] NOT NULL,
	[UnionDue] [Currency] NOT NULL,
	[MedicalHealth] [Currency] NOT NULL,
	[Dental] [Currency] NOT NULL,
	[GroupLifeInsurance] [Currency] NOT NULL,
	[DisabilityInsurance] [Currency] NOT NULL,
	[Comments] [varchar](500) NOT NULL,

	CONSTRAINT [AK_SecondaryConsumerIncomeDeductions_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId]
	)
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumerIncomeDeductions].[OtherPayrollDeductionDescription]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumerIncomeDeductions].[OtherNonPayrollDeductionDescription]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumerIncomeDeductions].[Comments]'
GO



PRINT 'Add [InsuranceProfile] table' 
IF OBJECT_ID(N'[Consumer].[InsuranceProfile]') IS NOT NULL 
	DROP TABLE [Consumer].[InsuranceProfile] 
GO
CREATE TABLE [Consumer].[InsuranceProfile] ( 

	[InsuranceProfileId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_InsuranceProfile] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_InsuranceProfile_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[PrimaryLifeInsurancePurpose] [varchar](100) NOT NULL,
	[PrimaryHeight] [varchar](10) NOT NULL,
	[PrimaryWeight] [varchar](10) NOT NULL,
	[PrimaryHaveHealthIssues] [Boolean] NOT NULL,
	[PrimaryUseTobacco] [Boolean] NOT NULL,
	[PrimaryWhenQuitTobacco] [varchar](20) NOT NULL,
	[SecondaryLifeInsurancePurpose] [varchar](100) NOT NULL,
	[SecondaryHeight] [varchar](10) NOT NULL,
	[SecondaryWeight] [varchar](10) NOT NULL,
	[SecondaryHaveHealthIssues] [Boolean] NOT NULL,
	[SecondaryUseTobacco] [Boolean] NOT NULL,
	[SecondaryWhenQuitTobacco] [varchar](20) NOT NULL,
	[PrimaryHaveBenNotWork] [Boolean] NOT NULL,
	[PrimaryYearsBenNotWork] [tinyint] NOT NULL,
	[PrimaryHaveCollegePlans] [Boolean] NOT NULL,
	[PrimaryIsCollegePrivate] [Boolean] NOT NULL,
	[PrimaryFundCollege] [Boolean] NOT NULL,
	[SecondaryHaveBenNotWork] [Boolean] NOT NULL,
	[SecondaryYearsBenNotWork] [tinyint] NOT NULL,
	[SecondaryHaveCollegePlans] [Boolean] NOT NULL,
	[SecondaryIsCollegePrivate] [Boolean] NOT NULL,
	[SecondaryFundCollege] [Boolean] NOT NULL,
	[Comments] [varchar](500) NOT NULL,

	CONSTRAINT [AK_InsuranceProfile_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId]
	)
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[InsuranceProfile].[PrimaryLifeInsurancePurpose]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[InsuranceProfile].[PrimaryHeight]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[InsuranceProfile].[PrimaryWeight]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[InsuranceProfile].[PrimaryWhenQuitTobacco]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[InsuranceProfile].[SecondaryLifeInsurancePurpose]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[InsuranceProfile].[SecondaryHeight]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[InsuranceProfile].[SecondaryWeight]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[InsuranceProfile].[SecondaryWhenQuitTobacco]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[InsuranceProfile].[Comments]'
GO



ALTER TABLE Consumer.AssetProtection
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.BankAsset
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.Budget
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.CdAsset
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.EstatePlanning
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.FamilyMember
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.FinancialGoal
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.FinancialPlan
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.OtherAsset
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.OtherLiability
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.PersonalAsset
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.PrimaryConsumerIncomeSource
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.RealEstateAsset
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.RealEstateLiability
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.SecondaryConsumerIncomeSource
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.TaxableInvestmentAsset
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())

ALTER TABLE Consumer.TaxAdvantagedAsset
ADD LinkingId [UNIQUEIDENTIFIER] NOT NULL DEFAULT(NEWID())


ALTER TABLE Consumer.Baseline
ADD 
	IsLocked [BIT] NOT NULL DEFAULT(0),
	SyncSystemLinkingId [INT] NULL,
	CrmLinkingId [INT] NULL,
	WealthLinkingId [INT] NULL 

GO

ALTER TABLE Consumer.FamilyMember
ADD 
	CrmLinkingId [INT] NULL
GO

--DROP TABLE [Plan].RetirementAssumptions
--GO
--DROP TABLE [Plan].RecommendedTargets
--GO


--Insert Recommendation Category
INSERT INTO [Code].[Lookup] ([Name], [Description])
SELECT 'Recommendation Category', ''

DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Recommendation Category'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Annual Review', 'RC-REV', '', 5
UNION SELECT @LookupId, 'Asset Protection (Life Insurance)', 'RC-ASST', '', 10
UNION SELECT @LookupId, 'Budget', 'RC-BUD', '', 15
UNION SELECT @LookupId, 'Debt Management', 'RC-DEBT', '', 20
UNION SELECT @LookupId, 'Emergency Fund/Cash Reserve', 'RC-EMG', '', 25
UNION SELECT @LookupId, 'Investments/Retirement Savings', 'RC-INV', '', 30
GO

--Migrate recommendations from MOPro v1
INSERT INTO [Plan].RecommendationTemplate (RecommendationCategoryCode, Recommendation, SortOrder)
SELECT 
	RecommendationCategoryCode = CASE RecommendationCategoryId
		WHEN 1 THEN 'RC-BUD'
		WHEN 4 THEN 'RC-DEBT'
		WHEN 6 THEN 'RC-REV'
		WHEN 8 THEN 'RC-ASST'
		WHEN 9 THEN 'RC-EMG'
		ELSE 'RC-INV' END, --11 
	Recommendation = Recommendation, 
	SortOrder = SortOrder * 10
FROM MOPro_Finance.Code.RecommendationTemplate
GO


--Insert Refinance Type
INSERT INTO [Code].[Lookup] ([Name], [Description])
SELECT 'Refinance Type', ''

DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Refinance Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'First Mortgage', 'REF-FIR', '', 5
UNION SELECT @LookupId, 'Second Mortgage', 'REF-SEC', '', 10
UNION SELECT @LookupId, 'Other', 'REF-OTH', '', 15
GO


--Add Integration Partner types
INSERT INTO [Code].[Lookup] ([Name], [Description])
SELECT 'Integration Partner', ''

DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Integration Partner'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Redtail CRM', 'INT-RED', '', 5
GO


ALTER TABLE Advisor.Company
ADD 
	[LogoReportOffset] [varchar](10) NULL,
	[Logo] [varbinary](MAX) NULL
GO

--Update anything changed to company
UPDATE T
SET
	Name = ISNULL(S.Name, ''), 
	FullName = ISNULL(NULLIF(S.FullName, ''), ISNULL(S.Name, '')), 
	MainPhone = '', 
	AddressLine = ISNULL(NULLIF(S.StreetAddress, ''), 'Unknown'), 
	AddressLine2 = ISNULL(S.StreetAddress2, ''), 
	PhysicalCity = ISNULL(NULLIF(S.City, ''), 'Unknown'), 
	PhysicalState = ISNULL(NULLIF(S.State, ''), 'CA'), 
	PhysicalZip = ISNULL(NULLIF(S.ZipCode, ''), '00000'), 
	BrokerageText = ISNULL(S.BrokerageText, ''), 
	PasswordReuseRestriction = S.PasswordReuseRestriction, 
	PasswordExpiry = S.PasswordExpiry, 
	IsInternal = S.IsInternal,
	LogoReportOffset = S.LogoReportOffset,
	Logo = S.Logo
FROM 
	MOPro_Finance.Code.Company S
	JOIN Advisor.Company T
		ON S.CompanyId = T.CompanyId
GO

--Add companyies from v1 nto yet added
SET IDENTITY_INSERT Advisor.Company ON
GO
INSERT INTO Advisor.Company (CompanyId, Name, FullName, MainPhone, AddressLine, AddressLine2, PhysicalCity, PhysicalState, PhysicalZip, BrokerageText, PasswordReuseRestriction, PasswordExpiry, IsInternal, LogoReportOffset, Logo)
SELECT
	CompanyId = S.CompanyId, 
	Name = ISNULL(S.Name, ''), 
	FullName = ISNULL(NULLIF(S.FullName, ''), ISNULL(S.Name, '')), 
	MainPhone = '', 
	AddressLine = ISNULL(NULLIF(S.StreetAddress, ''), 'Unknown'), 
	AddressLine2 = ISNULL(S.StreetAddress2, ''), 
	PhysicalCity = ISNULL(NULLIF(S.City, ''), 'Unknown'), 
	PhysicalState = ISNULL(NULLIF(S.State, ''), 'CA'), 
	PhysicalZip = ISNULL(NULLIF(S.ZipCode, ''), '00000'), 
	BrokerageText = ISNULL(S.BrokerageText, ''), 
	PasswordReuseRestriction = S.PasswordReuseRestriction, 
	PasswordExpiry = S.PasswordExpiry, 
	IsInternal = S.IsInternal,
	LogoReportOffset = S.LogoReportOffset,
	Logo = S.Logo
FROM 
	MOPro_Finance.Code.Company S
	LEFT JOIN Advisor.Company T
		ON S.CompanyId = T.CompanyId
WHERE T.CompanyId IS NULL

GO
SET IDENTITY_INSERT Advisor.Company OFF
GO


--Update any changes to the advisor data
UPDATE T
SET
	CompanyId = S.CompanyId, 
	FirstName = S.FirstName, 
	LastName = S.LastName, 
	OfficePhone = S.OfficePhone, 
	Title = S.Title, 
	PhysicalAddressLine = S.StreetAddress, 
	PhysicalAddressLine2 = S.StreetAddress2, 
	PhysicalCity = S.City, 
	PhysicalState = S.State, 
	PhysicalZip = S.ZipCode, 
	LicenseText = S.LicenseText, 
	IsCompanyAdmin = S.IsCompanyAdmin, 
	IsPasswordExpired = S.IsUserPasswordExpired, 
	Username = S.Username
FROM 
	MOPro_Finance.Code.FinancialRep S
	JOIN Advisor.FinancialAdvisor T
		ON S.FinancialRepId = T.FinancialAdvisorId
GO

--Add advisors from v1 not yet entered
--Add advisors from v1 not yet entered
SET IDENTITY_INSERT Advisor.FinancialAdvisor ON
GO
INSERT INTO Advisor.FinancialAdvisor (FinancialAdvisorId, CompanyId, FirstName, LastName, OfficePhone, Title, PhysicalAddressLine, PhysicalAddressLine2, PhysicalCity, PhysicalState, PhysicalZip, LicenseText, IsCompanyAdmin, IsPasswordExpired, Username)
SELECT
	FinancialAdvisorId = S.FinancialRepId, 
	CompanyId = S.CompanyId, 
	FirstName =S. FirstName, 
	LastName = S.LastName, 
	OfficePhone = S.OfficePhone, 
	Title = S.Title, 
	PhysicalAddressLine = S.StreetAddress, 
	PhysicalAddressLine2 = S.StreetAddress2, 
	PhysicalCity = S.City, 
	PhysicalState = S.State, 
	PhysicalZip = S.ZipCode, 
	LicenseText = S.LicenseText, 
	IsCompanyAdmin = S.IsCompanyAdmin, 
	IsPasswordExpired = S.IsUserPasswordExpired, 
	Username = S.Username
FROM MOPro_Finance.Code.FinancialRep S
	LEFT JOIN Advisor.FinancialAdvisor T
		ON S.FinancialRepId = T.FinancialAdvisorId
WHERE T.FinancialAdvisorId IS NULL

GO
SET IDENTITY_INSERT Advisor.FinancialAdvisor OFF
GO

--Add integration partner entries based on rep field
INSERT INTO Integration.IntegrationAccount (FinancialAdvisorId, PartnerCode, Username, [Password])
SELECT
	FinancialAdvisorId = T.FinancialAdvisorId,
	PartnerCode = 'INT-RED',
	Username = S.IntegrationUsername,
	[Password] = ''
FROM
	MOPro_Finance.Code.FinancialRep S
	JOIN Advisor.FinancialAdvisor T
		ON S.FinancialRepId = T.FinancialAdvisorId
WHERE 
	LEN(NULLIF(S.IntegrationUsername, 'null')) > 0
GO


--Lookup updates:
UPDATE [Code].[LookupItem] 
SET [Name] = 'Life: Indexed Universal'
WHERE [Code] = 'INS-UNIV'

DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Insurance Type'
INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT @LookupId, 'Life: Group', 'INS-GRP', '', 25

GO


--A bunch of field additions after doing a gap analysis of v1 to v2
ALTER TABLE Consumer.PersonalAsset
ADD 
	DepreciationRate [decimal] NOT NULL DEFAULT(0)
ALTER TABLE Consumer.PersonalAsset
ALTER COLUMN DepreciationRate [Factor] NOT NULL


ALTER TABLE Consumer.OtherAsset
ADD 
	DepreciationRate [decimal] NOT NULL DEFAULT(0)
ALTER TABLE Consumer.PersonalAsset
ALTER COLUMN DepreciationRate [Factor] NOT NULL


ALTER TABLE Consumer.RealEstateAsset
ADD 
	GrossRentalIncome [money] NOT NULL DEFAULT(0),
	PropertyExpenses [money] NOT NULL DEFAULT(0),
	SummaryOfProperty [varchar] (150) NULL,
	EstimatedYield [decimal] NOT NULL DEFAULT(0)
GO
ALTER TABLE Consumer.RealEstateAsset
ALTER COLUMN GrossRentalIncome [Currency] NOT NULL
ALTER TABLE Consumer.RealEstateAsset
ALTER COLUMN PropertyExpenses [Currency] NOT NULL
UPDATE Consumer.RealEstateAsset SET SummaryOfProperty = ''
ALTER TABLE Consumer.RealEstateAsset 
ALTER COLUMN SummaryOfProperty [varchar] (150) NOT NULL 
ALTER TABLE Consumer.RealEstateAsset 
ALTER COLUMN EstimatedYield [Factor] NOT NULL
GO
EXEC sp_bindefault '[Default_String]', '[Consumer].[RealEstateAsset].[SummaryOfProperty]'


ALTER TABLE Consumer.AssetProtection
ADD 
	EstimatedYield [decimal] NOT NULL DEFAULT(0)
ALTER TABLE Consumer.AssetProtection
ALTER COLUMN EstimatedYield [Factor] NOT NULL


ALTER TABLE Consumer.BankAsset
ADD 
	EstimatedYield [decimal] NOT NULL DEFAULT(0)
ALTER TABLE Consumer.BankAsset
ALTER COLUMN EstimatedYield [Factor] NOT NULL


ALTER TABLE Consumer.TaxAdvantagedAsset
ADD 
	EstimatedYield [decimal] NOT NULL DEFAULT(0)
ALTER TABLE Consumer.TaxAdvantagedAsset
ALTER COLUMN EstimatedYield [Factor] NOT NULL


ALTER TABLE Consumer.RealEstateLiability
ADD 
	CreditorName [varchar] (40) NULL,
	InterestOnlyTerm [smallint] NOT NULL DEFAULT(0),
	InterestOnlyTermDate [smalldatetime] NULL,
	InterestOnlyMonthlyPayment [money] NOT NULL DEFAULT(0)
GO
UPDATE Consumer.RealEstateLiability SET CreditorName = ''
ALTER TABLE Consumer.RealEstateLiability 
ALTER COLUMN CreditorName [varchar] (40) NOT NULL 
ALTER TABLE Consumer.RealEstateLiability
ALTER COLUMN InterestOnlyTerm [smallint] NOT NULL
ALTER TABLE Consumer.RealEstateLiability
ALTER COLUMN InterestOnlyMonthlyPayment [Currency] NOT NULL
GO
EXEC sp_bindefault '[Default_String]', '[Consumer].[RealEstateLiability].[CreditorName]'


ALTER TABLE Consumer.OtherLiability
ADD 
	CreditorName [varchar] (40) NULL,
	InterestOnlyTerm [smallint] NOT NULL DEFAULT(0),
	InterestOnlyTermDate [smalldatetime] NULL,
	InterestOnlyMonthlyPayment [money] NOT NULL DEFAULT(0)
GO
UPDATE Consumer.OtherLiability SET CreditorName = ''
ALTER TABLE Consumer.OtherLiability 
ALTER COLUMN CreditorName [varchar] (40) NOT NULL 
ALTER TABLE Consumer.OtherLiability
ALTER COLUMN InterestOnlyTerm [smallint] NOT NULL
ALTER TABLE Consumer.OtherLiability
ALTER COLUMN InterestOnlyMonthlyPayment [Currency] NOT NULL
GO
EXEC sp_bindefault '[Default_String]', '[Consumer].[OtherLiability].[CreditorName]'
GO


ALTER TABLE Consumer.AssetProtection
ADD 
	IsAutoEntry [bit] NOT NULL DEFAULT(0)
GO

ALTER TABLE Consumer.TaxAdvantagedAsset
ADD 
	IsAutoEntry [bit] NOT NULL DEFAULT(0)
GO

EXEC sp_unbindefault 'Consumer.Budget.Disability'
GO
ALTER TABLE Consumer.Budget
DROP COLUMN Disability
GO


EXEC sp_unbindefault 'Consumer.TaxAdvantagedAsset.EmployerMonthlyDollarContributions'
GO
ALTER TABLE Consumer.TaxAdvantagedAsset
DROP COLUMN EmployerMonthlyDollarContributions
GO

--Add reporting roles, etc
CREATE ROLE [Reporting] AUTHORIZATION [MININT-VBR5CJB\ssrs_access]
--CREATE ROLE [Reporting] AUTHORIZATION [LP2012\ssrs_report_runner]
EXECUTE sp_AddRoleMember 'Reporting', 'MININT-VBR5CJB\ssrs_access'
--EXECUTE sp_AddRoleMember 'Reporting', 'LP2012\ssrs_report_runner'

--TODO: Still need to script or manually add the Reporting schema to the Reporting role
--TODO: Add ssrs user as datareader to Membership
GO






