SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO



IF SCHEMA_ID('Consumer') IS NULL
	EXEC('CREATE SCHEMA [Consumer]') 
GO




PRINT 'Add [PrimaryConsumer] table' 
IF OBJECT_ID(N'[Consumer].[PrimaryConsumer]') IS NOT NULL 
	DROP TABLE [Consumer].[PrimaryConsumer] 
GO
CREATE TABLE [Consumer].[PrimaryConsumer] ( 

	[PrimaryConsumerId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_PrimaryConsumer] PRIMARY KEY CLUSTERED,
	[FirstName] [varchar](60) NOT NULL,
	[MiddleName] [varchar](60) NOT NULL,
	[LastName] [varchar](60) NOT NULL,
	[UserPin] [varchar](4) NOT NULL,
	[HomePhone] [varchar](30) NOT NULL,
	[WorkPhone] [varchar](30) NOT NULL,
	[MobilePhone] [varchar](30) NOT NULL,
	[Email] [varchar](200) NOT NULL,
	[AlsoKnownBy] [varchar](70) NOT NULL,
	[PhysicalAddressLine] [varchar](200) NOT NULL,
	[PhysicalCity] [varchar](70) NOT NULL,
	[PhysicalState] [varchar](2) NOT NULL,
	[PhysicalZip] [varchar](30) NOT NULL,
	[Country] [varchar](35) NOT NULL,
	[Citizenship] [varchar](25) NOT NULL,
	[Gender] [varchar](10) NOT NULL,
	[BirthDate] [smalldatetime] NULL,
	[DriverLicense] [varchar](30) NOT NULL,
	[Comments] [varchar](500) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[PrimaryConsumer].[FirstName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[MiddleName]'
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[PrimaryConsumer].[LastName]'
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[PrimaryConsumer].[UserPin]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[HomePhone]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[WorkPhone]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[MobilePhone]'
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[PrimaryConsumer].[Email]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[AlsoKnownBy]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[PhysicalAddressLine]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[PhysicalCity]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[PhysicalState]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[PhysicalZip]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[Country]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[Citizenship]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[Gender]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[DriverLicense]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumer].[Comments]'
GO



PRINT 'Add [Baseline] table' 
IF OBJECT_ID(N'[Consumer].[Baseline]') IS NOT NULL 
	DROP TABLE [Consumer].[Baseline] 
GO
CREATE TABLE [Consumer].[Baseline] ( 

	[BaselineId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_Baseline] PRIMARY KEY CLUSTERED,
	[PrimaryConsumerId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_Baseline_PrimaryConsumer] FOREIGN KEY 
			REFERENCES [Consumer].[PrimaryConsumer] ([PrimaryConsumerId]), 
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateDate] [smalldatetime] NULL,
	[PublishDate] [smalldatetime] NULL,
	[SubmitDate] [smalldatetime] NULL,
	[ArchiveDate] [smalldatetime] NULL,
	[Version] [tinyint] NOT NULL,
	[IsActive] [Boolean] NOT NULL,
	[IsLocked] [Boolean] NOT NULL,
	[NeedsReview] [Boolean] NOT NULL,
	[SyncSystemLinkingId] [int] NOT NULL,

	CONSTRAINT [AK_Baseline_Unique] UNIQUE NONCLUSTERED 
	( 
		[PrimaryConsumerId],
		[Version]
	)
) ON [PRIMARY]
GO



PRINT 'Add [BaselineStatus] table' 
IF OBJECT_ID(N'[Consumer].[BaselineStatus]') IS NOT NULL 
	DROP TABLE [Consumer].[BaselineStatus] 
GO
CREATE TABLE [Consumer].[BaselineStatus] ( 

	[BaselineStatusId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_BaselineStatus] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_BaselineStatus_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[SiteMapId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_BaselineStatus_SiteMap] FOREIGN KEY 
			REFERENCES [Application].[SiteMap] ([SiteMapId]), 
	[FirstAccessedDate] [smalldatetime] NULL,
	[LastAccessedDate] [smalldatetime] NULL,
	[IsSectionComplete] [Boolean] NOT NULL,

	CONSTRAINT [AK_BaselineStatus_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId],
		[SiteMapId]
	)
) ON [PRIMARY]
GO



PRINT 'Add [SecondaryConsumer] table' 
IF OBJECT_ID(N'[Consumer].[SecondaryConsumer]') IS NOT NULL 
	DROP TABLE [Consumer].[SecondaryConsumer] 
GO
CREATE TABLE [Consumer].[SecondaryConsumer] ( 

	[SecondaryConsumerId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_SecondaryConsumer] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_SecondaryConsumer_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[RelationshipCode] [AltKey] NOT NULL
		CONSTRAINT [FK_SecondaryConsumer_Relationship] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[FirstName] [varchar](60) NOT NULL,
	[MiddleName] [varchar](60) NOT NULL,
	[LastName] [varchar](60) NOT NULL,
	[HomePhone] [varchar](30) NOT NULL,
	[WorkPhone] [varchar](30) NOT NULL,
	[MobilePhone] [varchar](30) NOT NULL,
	[Email] [varchar](200) NOT NULL,
	[AlsoKnownBy] [varchar](70) NOT NULL,
	[PhysicalAddressLine] [varchar](200) NOT NULL,
	[PhysicalCity] [varchar](70) NOT NULL,
	[PhysicalState] [varchar](2) NOT NULL,
	[PhysicalZip] [varchar](30) NOT NULL,
	[Country] [varchar](35) NOT NULL,
	[Citizenship] [varchar](25) NOT NULL,
	[DriverLicense] [varchar](30) NOT NULL,
	[Gender] [varchar](10) NOT NULL,
	[BirthDate] [smalldatetime] NULL,
	[Comments] [varchar](500) NOT NULL,

	CONSTRAINT [AK_SecondaryConsumer_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[SecondaryConsumer].[FirstName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[MiddleName]'
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[SecondaryConsumer].[LastName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[HomePhone]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[WorkPhone]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[MobilePhone]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[Email]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[AlsoKnownBy]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[PhysicalAddressLine]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[PhysicalCity]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[PhysicalState]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[PhysicalZip]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[Country]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[Citizenship]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[DriverLicense]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[Gender]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumer].[Comments]'
GO



PRINT 'Add [FamilyMember] table' 
IF OBJECT_ID(N'[Consumer].[FamilyMember]') IS NOT NULL 
	DROP TABLE [Consumer].[FamilyMember] 
GO
CREATE TABLE [Consumer].[FamilyMember] ( 

	[FamilyMemberId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_FamilyMember] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_FamilyMember_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[RelationshipCode] [AltKey] NOT NULL
		CONSTRAINT [FK_FamilyMember_Relationship] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[FirstName] [varchar](60) NOT NULL,
	[MiddleName] [varchar](60) NOT NULL,
	[LastName] [varchar](60) NOT NULL,
	[Gender] [varchar](10) NOT NULL,
	[BirthDate] [smalldatetime] NULL,
	[Phone] [varchar](30) NOT NULL,
	[Email] [varchar](200) NOT NULL,
	[PhysicalAddressLine] [varchar](200) NOT NULL,
	[PhysicalCity] [varchar](70) NOT NULL,
	[PhysicalState] [varchar](2) NOT NULL,
	[PhysicalZip] [varchar](30) NOT NULL,
	[Country] [varchar](35) NOT NULL,
	[Dependent] [Boolean] NOT NULL,
	[CollegeExpenses] [Boolean] NOT NULL,
	[Comments] [varchar](500) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[FamilyMember].[FirstName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[MiddleName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[LastName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[Gender]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[Phone]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[Email]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[PhysicalAddressLine]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[PhysicalCity]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[PhysicalState]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[PhysicalZip]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[Country]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FamilyMember].[Comments]'
GO



PRINT 'Add [PrimaryConsumerIncomeSource] table' 
IF OBJECT_ID(N'[Consumer].[PrimaryConsumerIncomeSource]') IS NOT NULL 
	DROP TABLE [Consumer].[PrimaryConsumerIncomeSource] 
GO
CREATE TABLE [Consumer].[PrimaryConsumerIncomeSource] ( 

	[PrimaryConsumerIncomeSourceId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_PrimaryConsumerIncomeSource] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_PrimaryConsumerIncomeSource_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[Employer] [varchar](100) NOT NULL,
	[Title] [varchar](100) NOT NULL,
	[YearsAtEmployer] [tinyint] NOT NULL,
	[EmploymentChanges] [varchar](20) NOT NULL,
	[WhenRetire] [varchar](4) NOT NULL,
	[OutstandingStock] [varchar](20) NOT NULL,
	[GrossSalary] [Currency] NOT NULL,
	[Salary] [Currency] NOT NULL,
	[BonusAndCommission] [Currency] NOT NULL,
	[SelfEmploymentIncome] [Currency] NOT NULL,
	[Pension] [Currency] NOT NULL,
	[SSI] [Currency] NOT NULL,
	[OtherIncome] [Currency] NOT NULL,
	[Comments] [varchar](500) NOT NULL,

	CONSTRAINT [AK_PrimaryConsumerIncomeSource_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[PrimaryConsumerIncomeSource].[Employer]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumerIncomeSource].[Title]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumerIncomeSource].[EmploymentChanges]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumerIncomeSource].[WhenRetire]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumerIncomeSource].[OutstandingStock]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PrimaryConsumerIncomeSource].[Comments]'
GO



PRINT 'Add [SecondaryConsumerIncomeSource] table' 
IF OBJECT_ID(N'[Consumer].[SecondaryConsumerIncomeSource]') IS NOT NULL 
	DROP TABLE [Consumer].[SecondaryConsumerIncomeSource] 
GO
CREATE TABLE [Consumer].[SecondaryConsumerIncomeSource] ( 

	[SecondaryConsumerIncomeSourceId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_SecondaryConsumerIncomeSource] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_SecondaryConsumerIncomeSource_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[Employer] [varchar](100) NOT NULL,
	[Title] [varchar](100) NOT NULL,
	[YearsAtEmployer] [tinyint] NOT NULL,
	[EmploymentChanges] [varchar](20) NOT NULL,
	[WhenRetire] [varchar](4) NOT NULL,
	[OutstandingStock] [varchar](20) NOT NULL,
	[GrossSalary] [Currency] NOT NULL,
	[Salary] [Currency] NOT NULL,
	[BonusAndCommission] [Currency] NOT NULL,
	[SelfEmploymentIncome] [Currency] NOT NULL,
	[Pension] [Currency] NOT NULL,
	[SSI] [Currency] NOT NULL,
	[OtherIncome] [Currency] NOT NULL,
	[Comments] [varchar](500) NOT NULL,

	CONSTRAINT [AK_SecondaryConsumerIncomeSource_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[SecondaryConsumerIncomeSource].[Employer]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumerIncomeSource].[Title]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumerIncomeSource].[EmploymentChanges]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumerIncomeSource].[WhenRetire]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumerIncomeSource].[OutstandingStock]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[SecondaryConsumerIncomeSource].[Comments]'
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
	[RetirementPlanTypeCode] [AltKey] NULL
		CONSTRAINT [FK_PrimaryConsumerIncomeDeductions_RetirementPlanType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[RetirementMonthlyPercentContributions] [Factor] NOT NULL,
	[RetirementMonthlyDollarContributions] [Currency] NOT NULL,
	[RetirementLoanBalance] [Currency] NOT NULL,
	[RetirementLoanRepaymemt] [Currency] NOT NULL,
	[OtherPayrollDeductionDescription] [varchar](50) NOT NULL,
	[OtherPayrollDeductionAmount] [Currency] NOT NULL,
	[OtherNonPayrollDeductionDescription] [varchar](50) NOT NULL,
	[OtherNonPayrollDeductionAmount] [Currency] NOT NULL,
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
	[RetirementPlanTypeCode] [AltKey] NULL
		CONSTRAINT [FK_SecondaryConsumerIncomeDeductions_RetirementPlanType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[RetirementMonthlyPercentContributions] [Factor] NOT NULL,
	[RetirementMonthlyDollarContributions] [Currency] NOT NULL,
	[RetirementLoanBalance] [Currency] NOT NULL,
	[RetirementLoanRepaymemt] [Currency] NOT NULL,
	[OtherPayrollDeductionDescription] [varchar](50) NOT NULL,
	[OtherPayrollDeductionAmount] [Currency] NOT NULL,
	[OtherNonPayrollDeductionDescription] [varchar](50) NOT NULL,
	[OtherNonPayrollDeductionAmount] [Currency] NOT NULL,
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



PRINT 'Add [EstatePlanning] table' 
IF OBJECT_ID(N'[Consumer].[EstatePlanning]') IS NOT NULL 
	DROP TABLE [Consumer].[EstatePlanning] 
GO
CREATE TABLE [Consumer].[EstatePlanning] ( 

	[EstatePlanningId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_EstatePlanning] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_EstatePlanning_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[EstatePlanningTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_EstatePlanning_EstatePlanningType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Executed] [Boolean] NOT NULL,
	[YearDrafted] [varchar](4) NOT NULL,
	[State] [varchar](2) NOT NULL,
	[Comments] [varchar](1000) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[EstatePlanning].[YearDrafted]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[EstatePlanning].[State]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[EstatePlanning].[Comments]'
GO



PRINT 'Add [BankAsset] table' 
IF OBJECT_ID(N'[Consumer].[BankAsset]') IS NOT NULL 
	DROP TABLE [Consumer].[BankAsset] 
GO
CREATE TABLE [Consumer].[BankAsset] ( 

	[BankAssetId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_BankAsset] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_BankAsset_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_BankAsset_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[AccountTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_BankAsset_AccountType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[BankName] [varchar](60) NOT NULL,
	[AccountNumber] [varchar](60) NOT NULL,
	[AverageMonthlyBalance] [Currency] NOT NULL,
	[MonthlyContribution] [Currency] NOT NULL,
	[EstimatedYield] [Factor] NOT NULL,
	[IsPrimary] [Boolean] NOT NULL,
	[Comments] [varchar](500) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[BankAsset].[BankName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[BankAsset].[AccountNumber]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[BankAsset].[Comments]'
GO



PRINT 'Add [AssetProtection] table' 
IF OBJECT_ID(N'[Consumer].[AssetProtection]') IS NOT NULL 
	DROP TABLE [Consumer].[AssetProtection] 
GO
CREATE TABLE [Consumer].[AssetProtection] ( 

	[AssetProtectionId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_AssetProtection] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_AssetProtection_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_AssetProtection_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[InsuranceTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_AssetProtection_InsuranceType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[AccountNumber] [varchar](60) NOT NULL,
	[Insured] [varchar](70) NOT NULL,
	[InsuranceCompanyName] [varchar](100) NOT NULL,
	[YearIssued] [varchar](4) NOT NULL,
	[YearExpiry] [varchar](4) NOT NULL,
	[AnnualPremium] [Currency] NOT NULL,
	[CoverageAmount] [Currency] NOT NULL,
	[IsEmployerProvided] [Boolean] NOT NULL,
	[CurrentValue] [Currency] NOT NULL,
	[EstimatedYield] [Factor] NOT NULL,
	[PrimaryBeneficiaryCode] [AltKey] NULL
		CONSTRAINT [FK_AssetProtection_PrimaryBeneficiary] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[SecondaryBeneficiaryCode] [AltKey] NULL
		CONSTRAINT [FK_AssetProtection_SecondaryBeneficiary] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[IsAutoEntry] [Boolean] NOT NULL,
	[Comments] [varchar](500) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[AssetProtection].[AccountNumber]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[AssetProtection].[Insured]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[AssetProtection].[InsuranceCompanyName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[AssetProtection].[YearIssued]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[AssetProtection].[YearExpiry]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[AssetProtection].[Comments]'
GO



PRINT 'Add [CdAsset] table' 
IF OBJECT_ID(N'[Consumer].[CdAsset]') IS NOT NULL 
	DROP TABLE [Consumer].[CdAsset] 
GO
CREATE TABLE [Consumer].[CdAsset] ( 

	[CdAssetId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_CdAsset] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_CdAsset_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_CdAsset_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Description] [varchar](100) NOT NULL,
	[AccountNumber] [varchar](60) NOT NULL,
	[InterestRate] [Factor] NOT NULL,
	[MaturityDate] [smalldatetime] NULL,
	[CurrentValue] [Currency] NOT NULL,
	[Comments] [varchar](500) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[CdAsset].[Description]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[CdAsset].[AccountNumber]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[CdAsset].[Comments]'
GO



PRINT 'Add [TaxableInvestmentAsset] table' 
IF OBJECT_ID(N'[Consumer].[TaxableInvestmentAsset]') IS NOT NULL 
	DROP TABLE [Consumer].[TaxableInvestmentAsset] 
GO
CREATE TABLE [Consumer].[TaxableInvestmentAsset] ( 

	[TaxableInvestmentAssetId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_TaxableInvestmentAsset] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_TaxableInvestmentAsset_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_TaxableInvestmentAsset_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Description] [varchar](100) NOT NULL,
	[AccountNumber] [varchar](60) NOT NULL,
	[TotalCurrentValue] [Currency] NOT NULL,
	[TotalCostBasis] [Currency] NOT NULL,
	[MonthlyContribution] [Currency] NOT NULL,
	[EstimatedYield] [Factor] NOT NULL,
	[Comments] [varchar](500) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[TaxableInvestmentAsset].[Description]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[TaxableInvestmentAsset].[AccountNumber]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[TaxableInvestmentAsset].[Comments]'
GO



PRINT 'Add [TaxAdvantagedAsset] table' 
IF OBJECT_ID(N'[Consumer].[TaxAdvantagedAsset]') IS NOT NULL 
	DROP TABLE [Consumer].[TaxAdvantagedAsset] 
GO
CREATE TABLE [Consumer].[TaxAdvantagedAsset] ( 

	[TaxAdvantagedAssetId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_TaxAdvantagedAsset] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_TaxAdvantagedAsset_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_TaxAdvantagedAsset_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[PlanTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_TaxAdvantagedAsset_PlanType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Description] [varchar](100) NOT NULL,
	[AccountNumber] [varchar](60) NOT NULL,
	[EmployeeMonthlyPercentContributions] [Factor] NOT NULL,
	[EmployeeMonthlyDollarContributions] [Currency] NOT NULL,
	[CurrentAccountValue] [Currency] NOT NULL,
	[EstimatedYield] [Factor] NOT NULL,
	[PrimaryBeneficiaryCode] [AltKey] NULL
		CONSTRAINT [FK_TaxAdvantagedAsset_PrimaryBeneficiary] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[SecondaryBeneficiaryCode] [AltKey] NULL
		CONSTRAINT [FK_TaxAdvantagedAsset_SecondaryBeneficiary] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Comments] [varchar](500) NOT NULL,
	[EmployerMonthlyPercentMaximum] [Factor] NOT NULL,
	[EmployerMonthlyPercentContributions] [Factor] NOT NULL,
	[EmployerMonthlyDollarContributions] [Currency] NOT NULL,
	[IsAutoEntry] [Boolean] NOT NULL,
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[TaxAdvantagedAsset].[Description]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[TaxAdvantagedAsset].[AccountNumber]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[TaxAdvantagedAsset].[Comments]'
GO



PRINT 'Add [RealEstateAsset] table' 
IF OBJECT_ID(N'[Consumer].[RealEstateAsset]') IS NOT NULL 
	DROP TABLE [Consumer].[RealEstateAsset] 
GO
CREATE TABLE [Consumer].[RealEstateAsset] ( 

	[RealEstateAssetId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_RealEstateAsset] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_RealEstateAsset_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_RealEstateAsset_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[PropertyTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_RealEstateAsset_PropertyType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Description] [varchar](140) NOT NULL,
	[EstimatedValue] [Currency] NOT NULL,
	[OriginalPurchasePrice] [Currency] NOT NULL,
	[EstimatedYield] [Factor] NOT NULL,
	[SummaryOfProperty] [varchar](150) NOT NULL,
	[GrossRentalIncome] [Currency] NOT NULL,
	[PropertyExpenses] [Currency] NOT NULL,
	[Comments] [varchar](1000) NOT NULL,

	CONSTRAINT [AK_RealEstateAsset_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId],
		[OwnerCode],
		[PropertyTypeCode],
		[Description]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[RealEstateAsset].[Description]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[RealEstateAsset].[SummaryOfProperty]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[RealEstateAsset].[Comments]'
GO



PRINT 'Add [PersonalAsset] table' 
IF OBJECT_ID(N'[Consumer].[PersonalAsset]') IS NOT NULL 
	DROP TABLE [Consumer].[PersonalAsset] 
GO
CREATE TABLE [Consumer].[PersonalAsset] ( 

	[PersonalAssetId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_PersonalAsset] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_PersonalAsset_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_PersonalAsset_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[PersonalPropertyTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_PersonalAsset_PersonalPropertyType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Description] [varchar](100) NOT NULL,
	[EstimatedValue] [Currency] NOT NULL,
	[DepreciationRate] [Factor] NOT NULL,
	[OriginalPurchasePrice] [Currency] NOT NULL,
	[Comments] [varchar](500) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[PersonalAsset].[Description]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[PersonalAsset].[Comments]'
GO



PRINT 'Add [OtherAsset] table' 
IF OBJECT_ID(N'[Consumer].[OtherAsset]') IS NOT NULL 
	DROP TABLE [Consumer].[OtherAsset] 
GO
CREATE TABLE [Consumer].[OtherAsset] ( 

	[OtherAssetId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_OtherAsset] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_OtherAsset_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_OtherAsset_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Description] [varchar](100) NOT NULL,
	[EstimatedValue] [Currency] NOT NULL,
	[DepreciationRate] [Factor] NOT NULL,
	[Comments] [varchar](500) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[OtherAsset].[Description]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[OtherAsset].[Comments]'
GO



PRINT 'Add [RealEstateLiability] table' 
IF OBJECT_ID(N'[Consumer].[RealEstateLiability]') IS NOT NULL 
	DROP TABLE [Consumer].[RealEstateLiability] 
GO
CREATE TABLE [Consumer].[RealEstateLiability] ( 

	[RealEstateLiabilityId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_RealEstateLiability] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_RealEstateLiability_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_RealEstateLiability_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[RealEstateAssetId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_RealEstateLiability_RealEstateAsset] FOREIGN KEY 
			REFERENCES [Consumer].[RealEstateAsset] ([RealEstateAssetId]), 
	[MortgageTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_RealEstateLiability_MortgageType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[AccountNumber] [varchar](60) NOT NULL,
	[IsSecondMortgage] [Boolean] NOT NULL,
	[CreditorName] [varchar](80) NOT NULL,
	[InstallmentDate] [smalldatetime] NULL,
	[Term] [smallint] NOT NULL,
	[InterestRate] [Factor] NOT NULL,
	[MonthlyPayment] [Currency] NOT NULL,
	[OriginalBalance] [Currency] NOT NULL,
	[CurrentBalance] [Currency] NOT NULL,
	[InterestOnlyTerm] [smallint] NOT NULL,
	[InterestOnlyTermDate] [smalldatetime] NULL,
	[InterestOnlyMonthlyPayment] [Currency] NOT NULL,
	[Comments] [varchar](1000) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[RealEstateLiability].[AccountNumber]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[RealEstateLiability].[CreditorName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[RealEstateLiability].[Comments]'
GO



PRINT 'Add [OtherLiability] table' 
IF OBJECT_ID(N'[Consumer].[OtherLiability]') IS NOT NULL 
	DROP TABLE [Consumer].[OtherLiability] 
GO
CREATE TABLE [Consumer].[OtherLiability] ( 

	[OtherLiabilityId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_OtherLiability] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_OtherLiability_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_OtherLiability_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[LiabilityTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_OtherLiability_LiabilityType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Description] [varchar](100) NOT NULL,
	[CreditorName] [varchar](80) NOT NULL,
	[AccountNumber] [varchar](60) NOT NULL,
	[InstallmentDate] [smalldatetime] NULL,
	[Term] [smallint] NOT NULL,
	[InterestRate] [Factor] NOT NULL,
	[MonthlyPayment] [Currency] NOT NULL,
	[OriginalBalance] [Currency] NOT NULL,
	[CurrentBalance] [Currency] NOT NULL,
	[InterestOnlyTerm] [smallint] NOT NULL,
	[InterestOnlyTermDate] [smalldatetime] NULL,
	[InterestOnlyMonthlyPayment] [Currency] NOT NULL,
	[Comments] [varchar](1000) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[OtherLiability].[Description]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[OtherLiability].[CreditorName]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[OtherLiability].[AccountNumber]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[OtherLiability].[Comments]'
GO



PRINT 'Add [Budget] table' 
IF OBJECT_ID(N'[Consumer].[Budget]') IS NOT NULL 
	DROP TABLE [Consumer].[Budget] 
GO
CREATE TABLE [Consumer].[Budget] ( 

	[BudgetId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_Budget] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_Budget_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[Rent] [Currency] NOT NULL,
	[PropertyTaxes] [Currency] NOT NULL,
	[HomeMaintenance] [Currency] NOT NULL,
	[HoaDues] [Currency] NOT NULL,
	[Housekeeping] [Currency] NOT NULL,
	[CityUtility] [Currency] NOT NULL,
	[PowerUtility] [Currency] NOT NULL,
	[Landline] [Currency] NOT NULL,
	[CellPhone] [Currency] NOT NULL,
	[EntertainmentBundle] [Currency] NOT NULL,
	[Food] [Currency] NOT NULL,
	[DiningOut] [Currency] NOT NULL,
	[Clothing] [Currency] NOT NULL,
	[Laundry] [Currency] NOT NULL,
	[MedicalCopays] [Currency] NOT NULL,
	[OtherCopays] [Currency] NOT NULL,
	[Prescriptions] [Currency] NOT NULL,
	[Orthodontist] [Currency] NOT NULL,
	[Tithe] [Currency] NOT NULL,
	[CharitableContributions] [Currency] NOT NULL,
	[Legal] [Currency] NOT NULL,
	[AdditionalChildCare] [Currency] NOT NULL,
	[Education] [Currency] NOT NULL,
	[KidsActivities] [Currency] NOT NULL,
	[HealthClub] [Currency] NOT NULL,
	[Cosmetics] [Currency] NOT NULL,
	[Pets] [Currency] NOT NULL,
	[Vacations] [Currency] NOT NULL,
	[Hobbies] [Currency] NOT NULL,
	[Movies] [Currency] NOT NULL,
	[Magazines] [Currency] NOT NULL,
	[OtherEntertainment] [Currency] NOT NULL,
	[AutoExpenses] [Currency] NOT NULL,
	[RecreationExpenses] [Currency] NOT NULL,
	[Comments] [varchar](500) NOT NULL,

	CONSTRAINT [AK_Budget_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId]
	)
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[Budget].[Comments]'
GO



PRINT 'Add [FinancialGoal] table' 
IF OBJECT_ID(N'[Consumer].[FinancialGoal]') IS NOT NULL 
	DROP TABLE [Consumer].[FinancialGoal] 
GO
CREATE TABLE [Consumer].[FinancialGoal] ( 

	[FinancialGoalId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_FinancialGoal] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_FinancialGoal_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[OwnerCode] [AltKey] NOT NULL
		CONSTRAINT [FK_FinancialGoal_Owner] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Goal] [varchar](150) NOT NULL,
	[Amount] [Currency] NOT NULL,
	[IsShortTerm] [Boolean] NOT NULL,
	[Priority] [varchar](30) NOT NULL,
	[CompletedBy] [varchar](50) NOT NULL,
	[Comments] [varchar](1000) NOT NULL,

	CONSTRAINT [AK_FinancialGoal_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId],
		[OwnerCode],
		[Goal]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Consumer].[FinancialGoal].[Goal]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FinancialGoal].[Priority]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FinancialGoal].[CompletedBy]'
EXEC sp_bindefault '[Default_String]', '[Consumer].[FinancialGoal].[Comments]'
GO



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



PRINT 'Add [AdvisorSurvey] table' 
IF OBJECT_ID(N'[Consumer].[AdvisorSurvey]') IS NOT NULL 
	DROP TABLE [Consumer].[AdvisorSurvey] 
GO
CREATE TABLE [Consumer].[AdvisorSurvey] ( 

	[AdvisorSurveyId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_AdvisorSurvey] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_AdvisorSurvey_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[AdvisorTypeCode] [AltKey] NOT NULL
		CONSTRAINT [FK_AdvisorSurvey_AdvisorType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[AdvisorRankingCode] [AltKey] NOT NULL
		CONSTRAINT [FK_AdvisorSurvey_AdvisorRanking] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Comments] [varchar](500) NOT NULL,

	CONSTRAINT [AK_AdvisorSurvey_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId],
		[AdvisorTypeCode],
		[AdvisorRankingCode]
	)
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Consumer].[AdvisorSurvey].[Comments]'
GO

--<<#SQL_TABLE_SCRIPT#>>

























