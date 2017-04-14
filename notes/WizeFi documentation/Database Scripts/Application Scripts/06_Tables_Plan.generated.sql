SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO



IF SCHEMA_ID('Plan') IS NULL
	EXEC('CREATE SCHEMA [Plan]') 
GO




PRINT 'Add [RecommendationTemplate] table' 
IF OBJECT_ID(N'[Plan].[RecommendationTemplate]') IS NOT NULL 
	DROP TABLE [Plan].[RecommendationTemplate] 
GO
CREATE TABLE [Plan].[RecommendationTemplate] ( 

	[RecommendationTemplateId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_RecommendationTemplate] PRIMARY KEY CLUSTERED,
	[RecommendationCategoryCode] [AltKey] NOT NULL
		CONSTRAINT [FK_RecommendationTemplate_RecommendationCategory] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[Recommendation] [varchar](4000) NOT NULL,
	[SortOrder] [tinyint] NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Plan].[RecommendationTemplate].[Recommendation]'
GO



PRINT 'Add [PlanRevision] table' 
IF OBJECT_ID(N'[Plan].[PlanRevision]') IS NOT NULL 
	DROP TABLE [Plan].[PlanRevision] 
GO
CREATE TABLE [Plan].[PlanRevision] ( 

	[BaselineId] [ReferenceID] 
		CONSTRAINT [PK_PlanRevision] PRIMARY KEY CLUSTERED 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[PlanName] [varchar](50) NOT NULL,
	[ReportTitle] [varchar](50) NOT NULL,
	[CafrYears] [tinyint] NOT NULL,
	[IsScenario] [Boolean] NOT NULL,
	[Comments] [varchar](1000) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Plan].[PlanRevision].[PlanName]'
EXEC sp_bindrule '[Rule_Req_String]', '[Plan].[PlanRevision].[ReportTitle]'
EXEC sp_bindefault '[Default_String]', '[Plan].[PlanRevision].[Comments]'
GO



PRINT 'Add [RevisedBankAsset] table' 
IF OBJECT_ID(N'[Plan].[RevisedBankAsset]') IS NOT NULL 
	DROP TABLE [Plan].[RevisedBankAsset] 
GO
CREATE TABLE [Plan].[RevisedBankAsset] ( 

	[BankAssetId] [ReferenceID] 
		CONSTRAINT [PK_RevisedBankAsset] PRIMARY KEY CLUSTERED 
			REFERENCES [Consumer].[BankAsset] ([BankAssetId]), 
	[RevisedMonthlyContribution] [Currency] NOT NULL,
) ON [PRIMARY]
GO



PRINT 'Add [RevisedAssetProtection] table' 
IF OBJECT_ID(N'[Plan].[RevisedAssetProtection]') IS NOT NULL 
	DROP TABLE [Plan].[RevisedAssetProtection] 
GO
CREATE TABLE [Plan].[RevisedAssetProtection] ( 

	[AssetProtectionId] [ReferenceID] 
		CONSTRAINT [PK_RevisedAssetProtection] PRIMARY KEY CLUSTERED 
			REFERENCES [Consumer].[AssetProtection] ([AssetProtectionId]), 
	[RevisedAnnualPremium] [Currency] NOT NULL,
	[RevisedCoverageAmount] [Currency] NOT NULL,
) ON [PRIMARY]
GO



PRINT 'Add [RevisedTaxableInvestmentAsset] table' 
IF OBJECT_ID(N'[Plan].[RevisedTaxableInvestmentAsset]') IS NOT NULL 
	DROP TABLE [Plan].[RevisedTaxableInvestmentAsset] 
GO
CREATE TABLE [Plan].[RevisedTaxableInvestmentAsset] ( 

	[TaxableInvestmentAssetId] [ReferenceID] 
		CONSTRAINT [PK_RevisedTaxableInvestmentAsset] PRIMARY KEY CLUSTERED 
			REFERENCES [Consumer].[TaxableInvestmentAsset] ([TaxableInvestmentAssetId]), 
	[RevisedMonthlyContribution] [Currency] NOT NULL,
) ON [PRIMARY]
GO



PRINT 'Add [RevisedTaxAdvantagedAsset] table' 
IF OBJECT_ID(N'[Plan].[RevisedTaxAdvantagedAsset]') IS NOT NULL 
	DROP TABLE [Plan].[RevisedTaxAdvantagedAsset] 
GO
CREATE TABLE [Plan].[RevisedTaxAdvantagedAsset] ( 

	[TaxAdvantagedAssetId] [ReferenceID] 
		CONSTRAINT [PK_RevisedTaxAdvantagedAsset] PRIMARY KEY CLUSTERED 
			REFERENCES [Consumer].[TaxAdvantagedAsset] ([TaxAdvantagedAssetId]), 
	[RevisedEmployeeMonthlyPercentContributions] [Factor] NOT NULL,
	[RevisedEmployeeMonthlyDollarContributions] [Currency] NOT NULL,
) ON [PRIMARY]
GO



PRINT 'Add [RevisedRealEstateLiability] table' 
IF OBJECT_ID(N'[Plan].[RevisedRealEstateLiability]') IS NOT NULL 
	DROP TABLE [Plan].[RevisedRealEstateLiability] 
GO
CREATE TABLE [Plan].[RevisedRealEstateLiability] ( 

	[RealEstateLiabilityId] [ReferenceID] 
		CONSTRAINT [PK_RevisedRealEstateLiability] PRIMARY KEY CLUSTERED 
			REFERENCES [Consumer].[RealEstateLiability] ([RealEstateLiabilityId]), 
	[RevisedMonthlyPayment] [Currency] NOT NULL,
	[RevisedCurrentBalance] [Currency] NOT NULL,
) ON [PRIMARY]
GO



PRINT 'Add [RevisedOtherLiability] table' 
IF OBJECT_ID(N'[Plan].[RevisedOtherLiability]') IS NOT NULL 
	DROP TABLE [Plan].[RevisedOtherLiability] 
GO
CREATE TABLE [Plan].[RevisedOtherLiability] ( 

	[OtherLiabilityId] [ReferenceID] 
		CONSTRAINT [PK_RevisedOtherLiability] PRIMARY KEY CLUSTERED 
			REFERENCES [Consumer].[OtherLiability] ([OtherLiabilityId]), 
	[RevisedMonthlyPayment] [Currency] NOT NULL,
	[RevisedCurrentBalance] [Currency] NOT NULL,
) ON [PRIMARY]
GO



PRINT 'Add [RevisedBudget] table' 
IF OBJECT_ID(N'[Plan].[RevisedBudget]') IS NOT NULL 
	DROP TABLE [Plan].[RevisedBudget] 
GO
CREATE TABLE [Plan].[RevisedBudget] ( 

	[BudgetId] [ReferenceID] 
		CONSTRAINT [PK_RevisedBudget] PRIMARY KEY CLUSTERED 
			REFERENCES [Consumer].[Budget] ([BudgetId]), 
	[RevisedRent] [Currency] NOT NULL,
	[RevisedPropertyTaxes] [Currency] NOT NULL,
	[RevisedHomeMaintenance] [Currency] NOT NULL,
	[RevisedHoaDues] [Currency] NOT NULL,
	[RevisedHousekeeping] [Currency] NOT NULL,
	[RevisedCityUtility] [Currency] NOT NULL,
	[RevisedPowerUtility] [Currency] NOT NULL,
	[RevisedLandline] [Currency] NOT NULL,
	[RevisedCellPhone] [Currency] NOT NULL,
	[RevisedEntertainmentBundle] [Currency] NOT NULL,
	[RevisedFood] [Currency] NOT NULL,
	[RevisedDiningOut] [Currency] NOT NULL,
	[RevisedClothing] [Currency] NOT NULL,
	[RevisedLaundry] [Currency] NOT NULL,
	[RevisedMedicalCopays] [Currency] NOT NULL,
	[RevisedOtherCopays] [Currency] NOT NULL,
	[RevisedPrescriptions] [Currency] NOT NULL,
	[RevisedOrthodontist] [Currency] NOT NULL,
	[RevisedTithe] [Currency] NOT NULL,
	[RevisedCharitableContributions] [Currency] NOT NULL,
	[RevisedLegal] [Currency] NOT NULL,
	[RevisedAdditionalChildCare] [Currency] NOT NULL,
	[RevisedEducation] [Currency] NOT NULL,
	[RevisedKidsActivities] [Currency] NOT NULL,
	[RevisedHealthClub] [Currency] NOT NULL,
	[RevisedCosmetics] [Currency] NOT NULL,
	[RevisedPets] [Currency] NOT NULL,
	[RevisedVacations] [Currency] NOT NULL,
	[RevisedHobbies] [Currency] NOT NULL,
	[RevisedMovies] [Currency] NOT NULL,
	[RevisedMagazines] [Currency] NOT NULL,
	[RevisedOtherEntertainment] [Currency] NOT NULL,
	[RevisedAutoExpenses] [Currency] NOT NULL,
	[RevisedRecreationExpenses] [Currency] NOT NULL,
	[HousingStandardGuideline] [Factor] NOT NULL,
	[FoodStandardGuideline] [Factor] NOT NULL,
	[HealthStandardGuideline] [Factor] NOT NULL,
	[GivingStandardGuideline] [Factor] NOT NULL,
	[InvestmentsStandardGuideline] [Factor] NOT NULL,
	[ClothingStandardGuideline] [Factor] NOT NULL,
	[AutomobileFoodStandardGuideline] [Factor] NOT NULL,
	[MiscStandardGuideline] [Factor] NOT NULL,
	[OtherStandardGuideline] [Factor] NOT NULL,
	[DebtStandardGuideline] [Factor] NOT NULL,
) ON [PRIMARY]
GO



PRINT 'Add [Recommendation] table' 
IF OBJECT_ID(N'[Plan].[Recommendation]') IS NOT NULL 
	DROP TABLE [Plan].[Recommendation] 
GO
CREATE TABLE [Plan].[Recommendation] ( 

	[RecommendationId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_Recommendation] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_Recommendation_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[RecommendationCategoryCode] [AltKey] NOT NULL
		CONSTRAINT [FK_Recommendation_RecommendationCategory] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[RecommendationTemplateId] [ReferenceID] NULL
		CONSTRAINT [FK_Recommendation_RecommendationTemplate] FOREIGN KEY 
			REFERENCES [Plan].[RecommendationTemplate] ([RecommendationTemplateId]), 
	[Priority] [tinyint] NOT NULL,
	[RecommendationDescription] [varchar](4000) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Plan].[Recommendation].[RecommendationDescription]'
GO



PRINT 'Add [RecommendedRestructureAndTargets] table' 
IF OBJECT_ID(N'[Plan].[RecommendedRestructureAndTargets]') IS NOT NULL 
	DROP TABLE [Plan].[RecommendedRestructureAndTargets] 
GO
CREATE TABLE [Plan].[RecommendedRestructureAndTargets] ( 

	[RecommendedRestructureAndTargetsId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_RecommendedRestructureAndTargets] PRIMARY KEY CLUSTERED,
	[BaselineId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_RecommendedRestructureAndTargets_Baseline] FOREIGN KEY 
			REFERENCES [Consumer].[Baseline] ([BaselineId]), 
	[PrimaryPreRetirementReturnRate] [Factor] NOT NULL,
	[PrimaryMiscellaneousDebtRate] [Factor] NOT NULL,
	[RefinanceTypeCode] [AltKey] NULL
		CONSTRAINT [FK_RecommendedRestructureAndTargets_RefinanceType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[RefinanceAmount] [Currency] NOT NULL,
	[RefinanceInterest] [Factor] NOT NULL,
	[RefinanceMonthlyPayment] [Currency] NOT NULL,
	[RefinanceCosts] [Currency] NOT NULL,
	[RefinanceDescription] [varchar](50) NOT NULL,
	[PrimaryRecommendedCoverage] [Currency] NOT NULL,
	[PrimaryEstimatedPremium] [Currency] NOT NULL,
	[SecondaryRecommendedCoverage] [Currency] NOT NULL,
	[SecondaryEstimatedPremium] [Currency] NOT NULL,
	[RecommendedEmergencyFund] [Currency] NOT NULL,
	[DepositToEmergencyFund] [Currency] NOT NULL,
	[RecommendedCashReserve] [Currency] NOT NULL,
	[Phase2NonFirstMortgageDebtReduction] [Factor] NOT NULL,
	[Phase2CashReservesRate] [Factor] NOT NULL,
	[Phase2AlternateNonFirstMortgageDebtReduction] [Factor] NOT NULL,
	[Phase3FirstMortgageDebtReduction] [Factor] NOT NULL,
	[Phase3CashReservesRate] [Factor] NOT NULL,
	[Phase4CashReservesRate] [Factor] NOT NULL,

	CONSTRAINT [AK_RecommendedRestructureAndTargets_Unique] UNIQUE NONCLUSTERED 
	( 
		[BaselineId]
	)
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Plan].[RecommendedRestructureAndTargets].[RefinanceDescription]'
GO

--<<#SQL_TABLE_SCRIPT#>>











