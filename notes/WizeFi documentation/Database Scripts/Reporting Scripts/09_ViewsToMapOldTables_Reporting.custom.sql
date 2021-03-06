
IF SCHEMA_ID('Reporting') IS NULL
	EXEC('CREATE SCHEMA [Reporting]') 
GO


/*HACK: 
	These views are used to help map v1 into v2, since v1 had easier asset and liability structures for rolling up, but 
	also faking out most of the previous Financial tables.
	So basically creating views to look like the old tables to simplify some of this logic that follows for reporting
*/


PRINT 'Add reporting calc views that are used to help map v1 into v2, since v1 had easier asset and liability structures for rolling up'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[vLiability]')) 
	DROP VIEW [Reporting].[vLiability]
GO
CREATE VIEW [Reporting].[vLiability]
AS

SELECT
	LiabilityId = RRL.RealEstateLiabilityId,
	PlanRevisionId = RL.BaselineId,
	OwnerTypeCode = CASE RL.OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetId = RL.RealEstateAssetId,
	LiabilityTypeCode = 'LT-RE',
	LiabilitySubTypeCode = CASE
		WHEN RA.PropertyTypeCode = 'REAL-PRI' AND IsSecondMortgage = 0 THEN 'LT-RE-FI' 
		WHEN RA.PropertyTypeCode = 'REAL-PRI' AND IsSecondMortgage = 1 THEN 'LT-RE-SE' 
		ELSE 'LT-RE-OT' END, 
	ActualLiabilityTypeCode = RA.PropertyTypeCode,
	LiabilityTypeName = LT.[Name],
	CreditorName,
	[Description] = RA.[Description], 
	FixedYears = Term / 12, 
	InterestOnlyYears = (InterestOnlyTerm / 12) / 100,
	InterestOnlyCeaseDate = InterestOnlyTermDate,
	InterestOnlyCurrentPayment = InterestOnlyMonthlyPayment,
	InterestRate = InterestRate / 100, 
	CurrentBalance,
	ImprovedBalance = ISNULL(RRL.RevisedCurrentBalance, 0),
	CurrentPayment = MonthlyPayment, 
	ImprovedPayment = ISNULL(RRL.RevisedMonthlyPayment, 0),
	AccountNumber = RL.AccountNumber
FROM 
	[Consumer].RealEstateLiability RL 
	LEFT JOIN [Plan].RevisedRealEstateLiability RRL 
		ON RL.RealEstateLiabilityId = RRL.RealEstateLiabilityId 
	JOIN Consumer.RealEstateAsset RA
		ON RL.RealEstateAssetId = RA.RealEstateAssetId
	JOIN Code.LookupItem OT
		ON RL.OwnerCode = OT.Code
	JOIN Code.LookupItem LT
		ON RA.PropertyTypeCode = LT.Code

UNION
SELECT
	LiabilityId = ROL.OtherLiabilityId, 
	PlanRevisionId = OL.BaselineId,
	OwnerTypeCode = CASE OL.OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetId = NULL,
	LiabilityTypeCode = CASE
			WHEN OL.LiabilityTypeCode IN ('LIA-AUTO') THEN 'LT-AL'
			WHEN OL.LiabilityTypeCode IN ('LIA-CC') THEN 'LT-CC'
			WHEN OL.LiabilityTypeCode IN ('LIA-RV') THEN 'LT-RV'
			ELSE 'LT-OT' END, --includes: LIA-BIZ, LIA-LOC, LIA-PERS, LIA-STUD
	LiabilitySubTypeCode = NULL,
	ActualLiabilityTypeCode = OL.LiabilityTypeCode,
	LiabilityTypeName = LT.[Name],
	CreditorName,
	[Description] = ISNULL(NULLIF(OL.[Description], ''), 'Unknown'), 
	FixedYears = Term / 12, 
	InterestOnlyYears = (InterestOnlyTerm / 12) / 100,
	InterestOnlyCeaseDate = InterestOnlyTermDate,
	InterestOnlyCurrentPayment = InterestOnlyMonthlyPayment,
	InterestRate = InterestRate / 100, 
	CurrentBalance,
	ImprovedBalance = ISNULL(ROL.RevisedCurrentBalance, 0),
	CurrentPayment = MonthlyPayment, 
	ImprovedPayment = ISNULL(ROL.RevisedMonthlyPayment, 0),
	AccountNumber = OL.AccountNumber
FROM
	[Consumer].OtherLiability OL 
	LEFT JOIN [Plan].RevisedOtherLiability ROL 
		ON OL.OtherLiabilityId = ROL.OtherLiabilityId 
	JOIN Code.LookupItem OT
		ON OL.OwnerCode = OT.Code
	JOIN Code.LookupItem LT
		ON OL.LiabilityTypeCode = LT.Code

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[vAsset]')) 
	DROP VIEW [Reporting].[vAsset]
GO
CREATE VIEW [Reporting].[vAsset]
AS

SELECT
	AssetId = A.BankAssetId, 
	PlanRevisionId = BaselineId, 
	OwnerTypeCode = CASE OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetTypeCode = 'AT-V', 
	AssetSubTypeCode = CASE
			WHEN AccountTypeCode IN ('ACCT-EMG') THEN 'AT-V-EF'
			--WHEN AccountTypeCode IN ('') THEN 'AT-V-CS' --No panning for College Savings
			WHEN AccountTypeCode IN ('ACCT-VAC') THEN 'AT-V-VS'
			WHEN AccountTypeCode IN ('ACCT-XMS') THEN 'AT-V-XMS'
			ELSE 'AT-V-CR' END, --includes ACCT-GEN and ACCT-MMA
	AssetTypeName = 'Savings', 
	ActualAssetSubTypeCode = A.AccountTypeCode,
	[Description] = BankName, 
	Account = A.AccountNumber, 
	MarketValue = AverageMonthlyBalance, 
	Rate = EstimatedYield / 100,
	CurrentContributions = MonthlyContribution,
	ImprovedContributions = ISNULL(RevisedMonthlyContribution, 0),
	IsAutoEntry = 0
FROM Consumer.BankAsset A
	LEFT JOIN [Plan].RevisedBankAsset RBA
		ON A.BankAssetId = RBA.BankAssetId
	JOIN Code.LookupItem OT
		ON OwnerCode = OT.Code
UNION
SELECT
	AssetId = CdAssetId, 
	PlanRevisionId = BaselineId, 
	OwnerTypeCode = CASE OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetTypeCode = 'AT-V', 
	AssetSubTypeCode = 'AT-V-CR', 
	AssetTypeName = 'CDs', 
	ActualAssetSubTypeCode = NULL,
	A.[Description], 
	Account = A.AccountNumber, 
	MarketValue = CurrentValue, 
	Rate = InterestRate / 100,
	CurrentContributions = 0,
	ImprovedContributions = 0,
	IsAutoEntry = 0
FROM Consumer.CdAsset A
	JOIN Code.LookupItem OT
		ON OwnerCode = OT.Code
UNION
SELECT
	AssetId = PersonalAssetId, 
	PlanRevisionId = BaselineId, 
	OwnerTypeCode = CASE OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetTypeCode = CASE
			WHEN PersonalPropertyTypeCode IN ('PPT-AUTO') THEN 'AT-A'
			ELSE 'AT-O' END,  --includes PPT-COLL, PPT-RV and PPT-OTH
	AssetSubTypeCode = CASE
			WHEN PersonalPropertyTypeCode IN ('PPT-AUTO') THEN 'AT-A'
			ELSE 'AT-O' END,  --includes PPT-COLL, PPT-RV and PPT-OTH
	AssetTypeName = CASE
			WHEN PersonalPropertyTypeCode IN ('PPT-AUTO') THEN 'Automobile'
			ELSE 'Other' END,  
	ActualAssetSubTypeCode = A.PersonalPropertyTypeCode,
	A.[Description], 
	Account = '', 
	MarketValue = EstimatedValue, 
	Rate = DepreciationRate / 100,
	CurrentContributions = 0,
	ImprovedContributions = 0,
	IsAutoEntry = 0
FROM Consumer.PersonalAsset A
	JOIN Code.LookupItem OT
		ON OwnerCode = OT.Code
UNION
SELECT
	AssetId = TA.TaxableInvestmentAssetId, 
	PlanRevisionId = BaselineId, 
	OwnerTypeCode = CASE OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetTypeCode = 'AT-V', 
	AssetSubTypeCode = 'AT-V-NTA', 
	AssetTypeName = 'Taxable Investment', 
	ActualAssetSubTypeCode = NULL,
	TA.[Description], 
	Account = TA.AccountNumber, 
	MarketValue = TotalCurrentValue, 
	Rate = EstimatedYield / 100,
	CurrentContributions = MonthlyContribution,
	ImprovedContributions = ISNULL(RevisedMonthlyContribution, 0),
	IsAutoEntry = 0
FROM Consumer.TaxableInvestmentAsset TA
	LEFT JOIN [Plan].RevisedTaxableInvestmentAsset RTA
		ON TA.TaxableInvestmentAssetId = RTA.TaxableInvestmentAssetId
	JOIN Code.LookupItem OT
		ON OwnerCode = OT.Code
UNION
SELECT
	AssetId = TA.TaxAdvantagedAssetId, 
	PlanRevisionId = BaselineId, 
	OwnerTypeCode = CASE OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetTypeCode = 'AT-V', 
	AssetSubTypeCode = 'AT-V-TA', 
	AssetTypeName = 'Tax-Advantaged', 
	ActualAssetSubTypeCode = TA.PlanTypeCode,
	[Description] = TA.[Description], 
	Account = TA.AccountNumber, 
	MarketValue = CurrentAccountValue, 
	Rate = EstimatedYield / 100,
	CurrentContributions = EmployeeMonthlyDollarContributions,
	ImprovedContributions = ISNULL(RevisedEmployeeMonthlyDollarContributions, 0),
	IsAutoEntry
FROM Consumer.TaxAdvantagedAsset TA 
	JOIN Code.LookupItem LI ON TA.PlanTypeCode = LI.[Code]
	LEFT JOIN [Plan].RevisedTaxAdvantagedAsset RTA
		ON TA.TaxAdvantagedAssetId = RTA.TaxAdvantagedAssetId
	JOIN Code.LookupItem OT
		ON OwnerCode = OT.Code
UNION
SELECT
	AssetId = OtherAssetId, 
	PlanRevisionId = BaselineId, 
	OwnerTypeCode = CASE OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetTypeCode = 'AT-O', 
	AssetSubTypeCode = 'AT-O', 
	AssetTypeName = 'Other', 
	ActualAssetSubTypeCode = NULL,
	A.[Description], 
	Account = '', 
	MarketValue = EstimatedValue, 
	Rate = DepreciationRate / 100,
	CurrentContributions = 0,
	ImprovedContributions = 0,
	IsAutoEntry = 0
FROM Consumer.OtherAsset A
	JOIN Code.LookupItem OT
		ON OwnerCode = OT.Code
UNION
SELECT
	AssetId = AP.AssetProtectionId, 
	PlanRevisionId = BaselineId, 
	OwnerTypeCode = CASE OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetTypeCode = 'AT-I', 
	AssetSubTypeCode = CASE
			WHEN InsuranceTypeCode IN ('INS-GRP') THEN 'AT-I-GL'
			WHEN InsuranceTypeCode IN ('INS-TERM') THEN 'AT-I-TL'
			WHEN InsuranceTypeCode IN ('INS-VARU') THEN 'AT-I-VL'
			ELSE 'AT-I-PL' END, --includes INS-WHOL and INS-UNIV
	AssetTypeName = 'Insurance', 
	ActualAssetSubTypeCode = InsuranceTypeCode,
	[Description] = InsuranceCompanyName, 
	Account = AP.AccountNumber, 
	MarketValue = CurrentValue, 
	Rate = EstimatedYield / 100,
	CurrentContributions = AnnualPremium,
	ImprovedContributions = ISNULL(RevisedAnnualPremium, 0),
	IsAutoEntry
FROM Consumer.AssetProtection AP
	LEFT JOIN [Plan].RevisedAssetProtection RAP
		ON AP.AssetProtectionId = RAP.AssetProtectionId
	JOIN Code.LookupItem OT
		ON OwnerCode = OT.Code
WHERE InsuranceTypeCode IN ('INS-UNIV', 'INS-GRP', 'INS-TERM', 'INS-VARU', 'INS-WHOL')
UNION
SELECT
	AssetId = RealEstateAssetId, 
	PlanRevisionId = BaselineId, 
	OwnerTypeCode = CASE OwnerCode
			WHEN 'CO-PRI' THEN 'CO-CLI'
			WHEN 'CO-SEC' THEN 'CO-SPO'
			ELSE 'CO-CLI' END, --includes CO-OTH
	OwnerTypeName = OT.[Name],
	AssetTypeCode = 'AT-P', 
	AssetSubTypeCode = CASE
			WHEN PropertyTypeCode IN ('REAL-PRI') THEN 'AT-P-PH'
			WHEN PropertyTypeCode IN ('REAL-SEC') THEN 'AT-P-SH'
			WHEN PropertyTypeCode IN ('REAL-COM') THEN 'AT-P-C'
			WHEN PropertyTypeCode IN ('REAL-REN') THEN 'AT-P-R'
			ELSE 'AT-P-OP' END, --includes REAL-LND and REAL-OTH
	AssetTypeName = 'Property', 
	ActualAssetSubTypeCode = PropertyTypeCode,
	A.[Description], 
	Account = '', 
	MarketValue = EstimatedValue, 
	Rate = EstimatedYield / 100,
	CurrentContributions = 0,
	ImprovedContributions = 0,
	IsAutoEntry = 0
FROM Consumer.RealEstateAsset A
	JOIN Code.LookupItem OT
		ON OwnerCode = OT.Code

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[vPlanRevision]')) 
	DROP VIEW [Reporting].[vPlanRevision]
GO
CREATE VIEW [Reporting].[vPlanRevision]
AS

SELECT
	PlanRevisionId = B.BaselineId, 
	PlanId = PrimaryConsumerId, 
	Name = PlanName, 
	CreateDate, 
	Comment = '', 
	ReportName = ReportTitle, 
	GoalComment = '', 
	CafrYears, 
	AdjustedHouseBudgetRatio = ISNULL(HousingStandardGuideline, 0) / 100, 
	AdjustedFoodBudgetRatio = ISNULL(FoodStandardGuideline, 0) / 100, 
	AdjustedInsuranceBudgetRatio = ISNULL(HealthStandardGuideline, 0) / 100, 
	AdjustedGivingBudgetRatio = ISNULL(GivingStandardGuideline, 0) / 100, 
	AdjustedSavingBudgetRatio = ISNULL(InvestmentsStandardGuideline, 0) / 100, 
	AdjustedClothingBudgetRatio = ISNULL(ClothingStandardGuideline, 0) / 100, 
	AdjustedAutoBudgetRatio = ISNULL(AutomobileFoodStandardGuideline, 0) / 100, 
	AdjustedMiscBudgetRatio = ISNULL(MiscStandardGuideline, 0) / 100, 
	AdjustedDebtBudgetRatio = ISNULL(DebtStandardGuideline, 0) / 100, 
	AdjustedOtherBudgetRatio = ISNULL(OtherStandardGuideline, 0) / 100

FROM 
	Consumer.Baseline B
	LEFT JOIN [Plan].PlanRevision P
		ON B.BaselineId = P.BaselineId
	LEFT JOIN (
		Consumer.Budget BUD
		JOIN [Plan].RevisedBudget RB
			ON BUD.BudgetId = RB.BudgetId 
		) ON B.BaselineId = BUD.BaselineId

GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[vPlanRevisionWithAdvisor]')) 
	DROP VIEW [Reporting].[vPlanRevisionWithAdvisor]
GO
CREATE VIEW [Reporting].[vPlanRevisionWithAdvisor]
AS
	SELECT PR.*,
		AdvisorFirstName = FR.FirstName, 
		AdvisorLastName = FR.LastName, 
		FR.FinancialAdvisorId 
		
	FROM 
		[Reporting].[vPlanRevision] PR 
		JOIN dbo.MEMBERSHIP_USER_MAPPING UM 
			ON PR.PlanRevisionId = UM.ApplicationMappingId 
				AND ApplicationAccountType = 'Inclusive'
		JOIN dbo.MEMBERSHIP_USER_MAPPING AM 
			ON UM.ParentId = AM.UserId
		JOIN Advisor.FinancialAdvisor FR 
			ON AM.ApplicationMappingId = FR.FinancialAdvisorId
GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[vRecommendedRestructureAndTargets]')) 
	DROP VIEW [Reporting].[vRecommendedRestructureAndTargets]
GO
CREATE VIEW [Reporting].[vRecommendedRestructureAndTargets]
AS
	SELECT 
		RecommendedRestructureAndTargetsId, 
		BaselineId, 
		PrimaryPreRetirementReturnRate = PrimaryPreRetirementReturnRate / 100, 
		PrimaryMiscellaneousDebtRate = PrimaryMiscellaneousDebtRate / 100, 
		RefinanceTypeCode, 
		RefinanceAmount, 
		RefinanceInterest = RefinanceInterest / 100, 
		RefinanceMonthlyPayment, 
		RefinanceCosts, 
		RefinanceDescription, 
		PrimaryRecommendedCoverage, 
		PrimaryEstimatedPremium, 
		SecondaryRecommendedCoverage, 
		SecondaryEstimatedPremium, 
		RecommendedEmergencyFund, 
		DepositToEmergencyFund, 
		RecommendedCashReserve, 
		Phase2NonFirstMortgageDebtReduction = Phase2NonFirstMortgageDebtReduction / 100, 
		Phase2CashReservesRate = Phase2CashReservesRate / 100, 
		Phase2AlternateNonFirstMortgageDebtReduction = Phase2AlternateNonFirstMortgageDebtReduction / 100, 
		Phase3FirstMortgageDebtReduction = Phase3FirstMortgageDebtReduction / 100, 
		Phase3CashReservesRate = Phase3CashReservesRate / 100, 
		Phase4CashReservesRate = Phase4CashReservesRate / 100
	FROM [Plan].[RecommendedRestructureAndTargets]
		
GO
