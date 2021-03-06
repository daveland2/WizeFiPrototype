
IF SCHEMA_ID('Reporting') IS NULL
	EXEC('CREATE SCHEMA [Reporting]') 
GO


/*HACK: This is just a port over from v1 which was largely a port over from the MS Access DB.
		This report and underlying artifacts need to be deleted and the whole thing started from scratch
*/



PRINT 'Add reporting procs'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.sprptDebtConsumerGraph')) 
	DROP PROCEDURE [Reporting].[sprptDebtConsumerGraph]
GO
CREATE PROCEDURE [Reporting].[sprptDebtConsumerGraph] (
		@PlanRevisionId int
)
AS
	SET NOCOUNT ON 

	SELECT CEILING((CAFRMth + 0.0) / 12) AS CAFRYr, 
		DebtCloseBalConsumerCurrent AS [Current Plan],
		DebtCloseBalConsumer AS [With MOP Plan]
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND CAFRMth/12 = CEILING((CAFRMth + 0.0) / 12)
	ORDER BY CAFRMth

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.sprptDebtMortGraph')) 
	DROP PROCEDURE [Reporting].[sprptDebtMortGraph]
GO
CREATE PROCEDURE [Reporting].[sprptDebtMortGraph] (
		@PlanRevisionId int
)
AS
	SET NOCOUNT ON 

	SELECT CEILING((CAFRMth + 0.0) / 12) AS CAFRYr, 
		DebtCloseBalMortCurrent AS [Current Plan],
		DebtCloseBalMort AS [With MOP Plan]
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND CAFRMth/12 = CEILING((CAFRMth + 0.0) / 12)
	ORDER BY CAFRMth

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.sprptDebtTotalGraph')) 
	DROP PROCEDURE [Reporting].[sprptDebtTotalGraph]
GO
CREATE PROCEDURE [Reporting].[sprptDebtTotalGraph](
		@PlanRevisionId int
)
AS
	SET NOCOUNT ON 

	SELECT CEILING((CAFRMth + 0.0) / 12) AS CAFRYr, 
		DebtCloseBalCurrent AS [Current Plan],
		DebtCloseBal AS [With MOP Plan]
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND CAFRMth/12 = CEILING((CAFRMth + 0.0) / 12)
	ORDER BY CAFRMth

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.sprptDebtTotalInterestGraph')) 
	DROP PROCEDURE [Reporting].[sprptDebtTotalInterestGraph]
GO
CREATE PROCEDURE [Reporting].[sprptDebtTotalInterestGraph](
		@PlanRevisionId int
)
AS
	SET NOCOUNT ON 

	SELECT 0, SUM(DebtInterestCurrent) AS [Current Plan], SUM(DebtInterest) AS [With MOP Plan]
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId 

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.sprptNetWorthGraph')) 
	DROP PROCEDURE [Reporting].[sprptNetWorthGraph]
GO
CREATE PROCEDURE [Reporting].[sprptNetWorthGraph](
		@PlanRevisionId int
)
AS
	SET NOCOUNT ON 

	SELECT CEILING((CAFRMth + 0.0) / 12) AS CAFRYr, 
		RealEstateValue + EmergCloseBal + CashResCloseBal + InvestCloseBalCurrent + AutoValue + PersonalPropValue - DebtCloseBalCurrent AS [Current Plan],
		RealEstateValue + EmergCloseBal + CashResCloseBal + InvestCloseBal + AutoValue + PersonalPropValue - DebtCloseBal AS [With MOP Plan]
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND CAFRMth/12 = CEILING((CAFRMth + 0.0) / 12)
	ORDER BY CAFRMth

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.spsrpNetWorth')) 
	DROP PROCEDURE [Reporting].[spsrpNetWorth]
GO
CREATE PROCEDURE [Reporting].[spsrpNetWorth](
		@PlanRevisionId int
)
AS
	SET NOCOUNT ON 
	 
	SELECT CAFRMth, 'Year ' + Cast(CEILING((CAFRMth + 0.0) / 12) AS varchar(3)) AS CAFRYr, RealEstateValue, EmergCloseBal + CashResCloseBal AS EmerCashResBal,
		InvestCloseBal, AutoValue, PersonalPropValue, DebtCloseBal
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND CAFRMth/12 = CEILING((CAFRMth + 0.0) / 12)
	ORDER BY CEILING((CAFRMth + 0.0) / 12)

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.sprptDebtManage')) 
	DROP PROCEDURE [Reporting].[sprptDebtManage]
GO
CREATE PROCEDURE [Reporting].[sprptDebtManage](
		@PlanRevisionId int
)
AS
	SET NOCOUNT ON 

	DECLARE @MaxCAFR real, @MaxCAFRDebt real, @MaxCAFRDebtCurrent real

	SELECT @MaxCAFR = ISNULL(MAX(CAFRMth),-1) -- 1 subtracted so adjustment below ends with month 0
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId 

	SELECT @MaxCAFRDebt = ISNULL(MAX(CAFRMth),-1) -- 1 subtracted so adjustment below ends with month 0
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND DebtCloseBalConsumer <> 0

	SELECT @MaxCAFRDebtCurrent = MAX(CAFRMth)
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND DebtCloseBalConsumerCurrent <> 0

	--1 added because debt repaid in following month
	SELECT ROUND((@MaxCAFR+1)/12,2) as MaxCAFR, ROUND((@MaxCAFRDebt+1)/12,2) AS MaxCAFRDebt, 
		ROUND((@MaxCAFRDebtCurrent+1)/12,2) AS MaxCAFRDebtCurrent

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.sprptDebtManage2')) 
	DROP PROCEDURE [Reporting].[sprptDebtManage2]
GO
CREATE PROCEDURE [Reporting].[sprptDebtManage2](
		@PlanRevisionId int
)
AS
	SET NOCOUNT ON 

	DECLARE @MaxCAFR real, @MaxCAFRDebt real, @MaxCAFRDebtCurrent real, @DebtOpenBal money, @DebtOpenBalCurrent money

	SELECT @DebtOpenBalCurrent = DebtCloseBalCurrent, @DebtOpenBal = DebtCloseBal
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND CAFRMth = 0

	SELECT @MaxCAFR = ISNULL(MAX(CAFRMth),-1) -- 1 subtracted so adjustment below ends with month 0
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId 

	SELECT @MaxCAFRDebt = ISNULL(MAX(CAFRMth),-1) -- 1 subtracted so adjustment below ends with month 0
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND DebtCloseBal <> 0

	SELECT @MaxCAFRDebtCurrent = MAX(CAFRMth)
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND DebtCloseBalCurrent <> 0

	--1 added because debt repaid in following month
	SELECT @DebtOpenBal AS DebtOpenBal, @DebtOpenBalCurrent AS DebtOpenBalCurrent, ROUND((@MaxCAFR+1)/12,2) as MaxCAFR, 
		ROUND((@MaxCAFRDebt+1)/12,2) AS MaxCAFRDebt, ROUND((@MaxCAFRDebtCurrent+1)/12,2) AS MaxCAFRDebtCurrent,
		SUM(DebtInterest) AS DebtInterest, SUM(DebtInterestCurrent) AS DebtInterestCurrent
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId 

GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.spsrpCAFRCalculations')) 
	DROP PROCEDURE [Reporting].[spsrpCAFRCalculations]
GO
CREATE PROCEDURE [Reporting].[spsrpCAFRCalculations](
		@PlanRevisionId int
)
AS
	SET NOCOUNT ON 

	DECLARE @NetIncomeTotal [Currency]
	SELECT @NetIncomeTotal = [Reporting].GetTotalNetIncome(@PlanRevisionId, 1)
	 
	SELECT CAFRMth AS CAFRID, CAST (CAFRMth As varchar(3)) AS CAFRMth, CAFR AS CAFR, @NetIncomeTotal AS NetIncomeTotal, DebtExtraCAFRPrev AS DebtExtraCAFRPrev, DebtExtraCAFR AS DebtExtraCAFR, 
		EmergOpenBal AS EmergOpenBal, EmergBudgetCont AS EmergBudgetCont, EmergCAFRCont AS EmergCAFRCont, EmergCloseBal AS EmergCloseBal, 
		CashResOpenBal AS CashResOpenBal, CashResBudgetCont AS CashResBudgetCont, CashResCAFRCont AS CashResCAFRCont, 
		CashResCloseBal AS CashResCloseBal, DebtOpenBal AS DebtOpenBal, DebtMinPayment AS DebtMinPayment, DebtCAFRCont AS DebtCAFRCont, 
		DebtCAFRContMort AS DebtCAFRContMort, DebtCAFRContConsumer AS DebtCAFRContConsumer, DebtPrincipal AS DebtPrincipal, 
		DebtInterest AS DebtInterest, DebtCloseBal AS DebtCloseBal, InvestCAFRCont AS InvestCAFRCont, CAFRAmtLeft AS CAFRAmtLeft
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND CAFRMth <= 24
	UNION SELECT MAX(CAFRMth), 'Year ' + Cast(CEILING((CAFRMth + 0.0) / 12) AS varchar(3)) AS CAFRMth, SUM(CAFR) AS CAFR, @NetIncomeTotal AS NetIncomeTotal, 
		SUM(DebtExtraCAFRPrev) AS DebtExtraCAFRPrev, SUM(DebtExtraCAFR) AS DebtExtraCAFR, MIN(EmergOpenBal) AS EmergOpenBal, SUM(EmergBudgetCont) AS EmergBudgetCont, 
		SUM(EmergCAFRCont) AS EmergCAFRCont, MAX(EmergCloseBal) AS EmergCloseBal, MIN(CashResOpenBal) AS CashResOpenBal, 
		SUM(CashResBudgetCont) AS CashResBudgetCont, SUM(CashResCAFRCont) AS CashResCAFRCont, MAX(CashResCloseBal) AS CashResCloseBal, 
		MAX(DebtOpenBal) AS DebtOpenBal, SUM(DebtMinPayment) AS DebtMinPayment, SUM(DebtCAFRCont) AS DebtCAFRCont, 
		SUM(DebtCAFRContMort) AS DebtCAFRContMort, SUM(DebtCAFRContConsumer) AS DebtCAFRContConsumer,
		SUM(DebtPrincipal) AS DebtPrincipal, SUM(DebtInterest) AS DebtInterest, MIN(DebtCloseBal) AS DebtCloseBal, SUM(InvestCAFRCont) AS InvestCAFRCont, 
		SUM(CAFRAmtLeft) AS CAFRAmtLeft
	FROM Reporting.CafrCalculation
	WHERE [PlanRevisionId] = @PlanRevisionId AND CAFRMth > 24
	GROUP BY 'Year ' + Cast(CEILING((CAFRMth + 0.0) / 12) AS varchar(3))

GO




IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.spsrpOtherIncome')) 
	DROP PROCEDURE [Reporting].[spsrpOtherIncome]
GO
CREATE PROCEDURE [Reporting].[spsrpOtherIncome]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT Reporting.GetLookupItemName(I.OwnerTypeCode) [Owner], I.[Source] [Description], I.[NetMonthlyAmount] Amount, 'Other Income' As IncType
	FROM [Reporting].[vIncome] I 
	WHERE PlanRevisionId = @PlanRevisionId AND I.IsPaycheck = 0 AND NetMonthlyAmount <> 0

	UNION SELECT Reporting.GetLookupItemName(A.OwnerTypeCode) [Owner], A.[Description], R.[GrossRentalIncome] --- Reporting.fnGetRealEstateBalance(A.AssetId, 'Payment')
		- R.[PropertyExpenses] AS Amount, 'Real Estate' As IncType
	FROM [Reporting].[vAsset] A INNER JOIN Consumer.RealEstateAsset R ON A.AssetId = R.RealEstateAssetId
	WHERE PlanRevisionId = @PlanRevisionId AND R.[GrossRentalIncome] <> 0

GO


--This one used to reference that nasty vPlanRevision that we dumped. 
--Changing references where they come up, to just be the scaled down needs for that report
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptClientRevision]')) 
	DROP PROCEDURE [Reporting].[sprptClientRevision]
GO
CREATE PROCEDURE [Reporting].[sprptClientRevision]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT 
		PR.AdvisorFirstName Rep1stName, 
		PR.AdvisorLastName RepLastName, 
		PR.*,
		
		CInsPurpose = IP.PrimaryLifeInsurancePurpose, 
		CHealthProb = IP.PrimaryHaveHealthIssues, 
		CHeight = IP.PrimaryHeight, 
		CWeight = IP.PrimaryWeight, 
		CUseTabacco = IP.PrimaryUseTobacco, 
		CQuitTabacco = IP.PrimaryWhenQuitTobacco, 
		CBenNotWork = IP.PrimaryHaveBenNotWork, 
		CBenNotWorkYrs = IP.PrimaryYearsBenNotWork, 
		CKidCollege = IP.PrimaryHaveCollegePlans, 
		CPrivatePublic = IP.PrimaryIsCollegePrivate, 
		CInsCollege = IP.PrimaryFundCollege,
		
		SInsPurpose = IP.SecondaryLifeInsurancePurpose, 
		SHealthProb = IP.SecondaryHaveHealthIssues, 
		SHeight = IP.SecondaryHeight, 
		SWeight = IP.SecondaryWeight, 
		SUseTabacco = IP.SecondaryUseTobacco, 
		SQuitTabacco = IP.SecondaryWhenQuitTobacco, 
		SBenNotWork = IP.SecondaryHaveBenNotWork, 
		SBenNotWorkYrs = IP.SecondaryYearsBenNotWork, 
		SKidCollege = IP.SecondaryHaveCollegePlans, 
		SPrivatePublic = IP.SecondaryIsCollegePrivate, 
		SInsCollege = IP.SecondaryFundCollege
		
	FROM 
		[Reporting].[vPlanRevisionWithAdvisor] PR
		LEFT JOIN Consumer.InsuranceProfile IP
			ON PR.PlanRevisionId = IP.BaselineId
	WHERE PR.PlanRevisionId = @PlanRevisionId 

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptRetirementGoals]')) 
	DROP PROCEDURE [Reporting].[sprptRetirementGoals]
GO
CREATE PROCEDURE [Reporting].[sprptRetirementGoals]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT PR.PlanRevisionId, 
		GoalComment = FG.Comments,
		FLOOR(DATEDIFF(day, C.BirthDate, getDate()) / 365.25) CAge, FG.PrimaryRetirementAge CRetireAge, FG.PrimaryRetiredMonthlyExpenses CRetireExp, FG.PrimaryDeathFund CDeathFund, FG.PrimaryCurrentPlanProjection CCurPlanAchieveGoal, FG.PrimaryNewPlanProjection CHappen3Yrs,
		FLOOR(DATEDIFF(day, S.BirthDate, getDate()) / 365.25) SAge, FG.SecondaryRetirementAge SRetireAge, FG.SecondaryRetiredMonthlyExpenses SRetireExp, FG.SecondaryDeathFund SDeathFund, FG.SecondaryCurrentPlanProjection SCurPlanAchieveGoal, FG.SecondaryNewPlanProjection SHappen3Yrs
	FROM 
		[Reporting].[vPlanRevision] PR
		JOIN Consumer.PrimaryConsumer C
			ON PR.PlanId = C.PrimaryConsumerId
		LEFT JOIN Consumer.SecondaryConsumer S
			ON PR.PlanRevisionId = S.BaselineId
		LEFT JOIN Consumer.FinancialPlan FG
			ON PR.PlanRevisionId = FG.BaselineId

	WHERE PR.PlanRevisionId = @PlanRevisionId 

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptIncomeWithholding]')) 
	DROP PROCEDURE [Reporting].[sprptIncomeWithholding]
GO
CREATE PROCEDURE [Reporting].[sprptIncomeWithholding]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT PR.PlanRevisionId,
	
		PayCkCFreq = 'Monthly', 
		CGrossIncome = PS.GrossSalary, 
		PayCkCFedTax = PD.FederalTax, 
		PayCkCFICA = PD.Fica, 
		PayCkCMedicare = PD.Medicare, 
		PayCkCStateTax = PD.StateTax, 
		PayCkCStateDI = PD.StateDisabilityInsurance, 
		PayCkCUnionDue = PD.UnionDue, 
		PayCkCMedHealth = PD.MedicalHealth, 
		PayCkCDental = PD.Dental, 
		PayCkCLifeIns = PD.GroupLifeInsurance, 
		PayCkCDI = PD.DisabilityInsurance, 
		PayCkCLegalChild = 0, --TODO: Confirm OK to ignore
		PayCkCLegalAlimony = 0, --TODO: Confirm OK to ignore 
		PayCkCEmplStock = 0, --TODO: Confirm OK to ignore 
		PayCkCCalPERS = 0, --TODO: Confirm OK to ignore 
		PayCkCOtherDeduct = PD.OtherPayrollDeductionAmount + PD.OtherNonPayrollDeductionAmount, 
		PayCkCOtherChild = 0, --TODO: Confirm OK to ignore 
		PayCkCOtherChildCare = 0, --TODO: Confirm OK to ignore 
		PayCkCOtherAlimony = 0, --TODO: Confirm OK to ignore 
		C401KEmployerCont = PRP.EmployerMonthlyPercentMaximum / 100, --This really means
		C401KEmployeeCont = PRP.EmployeeMonthlyDollarContributions, 
		C401KEmployerPer = PRP.EmployerMonthlyPercentContributions / 100, 
		C401KEmployeePer = PRP.EmployeeMonthlyPercentContributions / 100, 
		PayCkC401KLoan = PD.RetirementLoanRepaymemt, 
		C401KLoanBal = PD.RetirementLoanBalance, 
		
		PayCkSFreq = 'Monthly', 
		SGrossIncome = SS.GrossSalary, 
		PayCkSFedTax = SD.FederalTax, 
		PayCkSFICA = SD.Fica, 
		PayCkSMedicare = SD.Medicare, 
		PayCkSStateTax = SD.StateTax, 
		PayCkSStateDI = SD.StateDisabilityInsurance, 
		PayCkSUnionDue = SD.UnionDue, 
		PayCkSMedHealth = SD.MedicalHealth, 
		PayCkSDental = SD.Dental, 
		PayCkSLifeIns = SD.GroupLifeInsurance, 
		PayCkSDI = SD.DisabilityInsurance, 
		PayCkSLegalChild = 0, --TODO: Confirm OK to ignore
		PayCkSLegalAlimony = 0, --TODO: Confirm OK to ignore 
		PayCkSEmplStock = 0, --TODO: Confirm OK to ignore 
		PayCkSCalPERS = 0, --TODO: Confirm OK to ignore 
		PayCkSOtherDeduct = SD.OtherPayrollDeductionAmount + SD.OtherNonPayrollDeductionAmount, 
		PayCkSOtherChild = 0, --TODO: Confirm OK to ignore 
		PayCkSOtherChildCare = 0, --TODO: Confirm OK to ignore 
		PayCkSOtherAlimony = 0, --TODO: Confirm OK to ignore 
		S401KEmployerCont = SRP.EmployerMonthlyPercentMaximum / 100, 
		S401KEmployeeCont = SRP.EmployeeMonthlyDollarContributions, 
		S401KEmployerPer = SRP.EmployerMonthlyPercentContributions / 100, 
		S401KEmployeePer = SRP.EmployeeMonthlyPercentContributions / 100,
		PayCkS401KLoan = SD.RetirementLoanRepaymemt, 
		S401KLoanBal = SD.RetirementLoanBalance 

	FROM 
		[Reporting].[vPlanRevision] PR
		LEFT JOIN Consumer.PrimaryConsumerIncomeSource PS
			ON PR.PlanRevisionId = PS.BaselineId
		LEFT JOIN Consumer.PrimaryConsumerIncomeDeductions PD
			ON PR.PlanRevisionId = PD.BaselineId
		LEFT JOIN Consumer.SecondaryConsumerIncomeSource SS
			ON PR.PlanRevisionId = SS.BaselineId
		LEFT JOIN Consumer.SecondaryConsumerIncomeDeductions SD
			ON PR.PlanRevisionId = SD.BaselineId
		OUTER APPLY (
			SELECT TOP 1
				EmployerMonthlyPercentMaximum, EmployerMonthlyDollarContributions, EmployerMonthlyPercentContributions, EmployeeMonthlyDollarContributions, EmployeeMonthlyPercentContributions
			FROM Consumer.TaxAdvantagedAsset
			WHERE BaselineId = @PlanRevisionId
				AND OwnerCode = 'CO-PRI'
				--AND PlanTypeCode IN ('TAX-401K', 'TAX-403B')
				AND (EmployerMonthlyPercentMaximum > 0
					OR EmployerMonthlyPercentContributions > 0
					OR EmployeeMonthlyPercentContributions > 0)
		) PRP
		OUTER APPLY (
			SELECT TOP 1
				EmployerMonthlyPercentMaximum, EmployerMonthlyDollarContributions, EmployerMonthlyPercentContributions, EmployeeMonthlyDollarContributions, EmployeeMonthlyPercentContributions
			FROM Consumer.TaxAdvantagedAsset
			WHERE BaselineId = @PlanRevisionId
				AND OwnerCode = 'CO-SEC'
				--AND PlanTypeCode IN ('TAX-401K', 'TAX-403B')
				AND (EmployerMonthlyPercentMaximum > 0
					OR EmployerMonthlyPercentContributions > 0
					OR EmployeeMonthlyPercentContributions > 0)
		) SRP

	WHERE PR.PlanRevisionId = @PlanRevisionId

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsrpLiability]')) 
	DROP PROCEDURE [Reporting].[spsrpLiability]
GO
CREATE PROCEDURE [Reporting].[spsrpLiability]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 

	SELECT sp.Header1, sp.LiabilityDescription Description, sp.DebtType, sp.LiabiltySortOrder, sp.CreditorName, sp.[FixedYears] YrsFixed, sp.[InterestOnlyYears] YrsIntOnly, sp.InterestRate,
		sp.[CurrentBalance] CurrentBalance, sp.[ImprovedBalance] CurrentBalanceImp, sp.[CurrentPayment] MthlyPayment, sp.[ImprovedPayment] MthlyPaymentImp, SortOrder = 0, sp.PlanRevisionId AS ClientRevisionID
	FROM (
		SELECT 
			AT.Name AS Header1, 
			(CASE L.LiabilitySubTypeCode WHEN 'LT-RE-SE' THEN 'Second Mortgage' ELSE 'First Mortgage' END) AS LiabilityDescription, 
			(CASE L.LiabilitySubTypeCode WHEN 'LT-RE-SE' THEN 'Second Mortgage' ELSE 'First Mortgage' END) AS DebtType, 
			L.*, 0 LiabiltySortOrder
		FROM 
			[Reporting].[vLiability] L 
			JOIN Code.LookupItem AT 
				ON L.ActualLiabilityTypeCode = AT.Code
		WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-RE'

		UNION SELECT LT.Name AS Header1, L.Description LiabilityDescription, LT.Name AS DebtType, L.*, LT.SortOrder LiabiltySortOrder
		FROM [Reporting].[vLiability] L INNER JOIN Code.LookupItem LT ON L.ActualLiabilityTypeCode = LT.Code
		WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode IN ('LT-AL', 'LT-RV', 'LT-CC', 'LT-OT')

	) AS sp 
	ORDER BY sp.LiabiltySortOrder

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptCurrentBalance]')) 
	DROP PROCEDURE [Reporting].[sprptCurrentBalance]
GO
CREATE PROCEDURE [Reporting].[sprptCurrentBalance]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 

	DECLARE @IntOnlyLoan int

	SET @IntOnlyLoan = 0

	SELECT @IntOnlyLoan = SUM([InterestOnlyYears])
	FROM [Reporting].[vLiability]
	WHERE PlanRevisionId = @PlanRevisionId
	 
	SELECT Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'PrimRes') AS PrimaryRes, Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'SecRes') AS SecondRes,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InvestProp') AS InvestProp, Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OthProp') AS OtherProp, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'TxInv') AS TaxDef, Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'NTxInv') AS NonTxDef, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'CashInv') + Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'EmergInv') AS CashEm,	
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OtherInv') AS OtherInv, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'Insure') AS Insure, Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'Auto') AS Auto, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OtherAsset') AS OtherAsset,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'PrimResMort') AS PrimResMort, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'SecResMort') AS SecResMort, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InvestPropMort') AS InvestPropMort,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OthPropMort') AS OthPropMort, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'AutoLoan') AS AutoLoan, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'CreditCard') AS CreditCard, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OtherLoan') AS OtherLoan,
		@IntOnlyLoan AS IntOnlyLoanTotYrs

GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptAssetProtectionSpGraph]')) 
	DROP PROCEDURE [Reporting].[sprptAssetProtectionSpGraph]
GO
CREATE PROCEDURE [Reporting].[sprptAssetProtectionSpGraph]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT 'Current Coverage' AS InsType, Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureSpTerm') AS [Term Life Coverage], 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureSpGroup') AS [Group Life Coverage],
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureSpPerm') AS [Permanent Life Coverage],
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureSpVar') AS [Varable Life Coverage]
	UNION SELECT 'Recommended' AS InsType, ISNULL(RT.SecondaryRecommendedCoverage, 0) AS [Term Life Coverage], 0 AS [Group Life Coverage], 
		0 AS [Permanent Life Coverage], 0 AS [Varable Life Coverage]
	FROM 
		[Reporting].[vPlanRevision] PR 
		LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] RT 
			ON PR.PlanRevisionId = RT.BaselineId
	WHERE PR.PlanRevisionId = @PlanRevisionId
	ORDER BY InsType DESC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptAssetProtection]')) 
	DROP PROCEDURE [Reporting].[sprptAssetProtection]
GO
CREATE PROCEDURE [Reporting].[sprptAssetProtection]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT @PlanRevisionId AS ClientRevisionID, LifeInsuranceCoverage = ISNULL(RT.PrimaryRecommendedCoverage, 0), LifeInsuranceEstimatedPremium = ISNULL(RT.PrimaryEstimatedPremium, 0), 
		SpouseLifeInsuranceCoverage = ISNULL(RT.SecondaryRecommendedCoverage, 0), SpouseLifeInsuranceEstimatedPremium = ISNULL(RT.SecondaryEstimatedPremium, 0),
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureClTerm') AS InsureClTerm, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureClGroup') AS InsureClGroup,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureClPerm') AS InsureClPerm,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureClVar') AS InsureClVar,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureSpTerm') AS InsureSpTerm, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureSpGroup') AS InsureSpGroup,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureSpPerm') AS InsureSpPerm,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureSpVar') AS InsureSpVar
	FROM [Reporting].[vPlanRevision] PR LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] RT ON PR.PlanRevisionId = RT.BaselineId
	WHERE PR.PlanRevisionId = @PlanRevisionId

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptAssetProtectionClGraph]')) 
	DROP PROCEDURE [Reporting].[sprptAssetProtectionClGraph]
GO
CREATE PROCEDURE [Reporting].[sprptAssetProtectionClGraph]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT 'Current Coverage' AS InsType, Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureClTerm') AS [Term Life Coverage], 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureClGroup') AS [Group Life Coverage],
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureClPerm') AS [Permanent Life Coverage],
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureClVar') AS [Varable Life Coverage]
	UNION SELECT 'Recommended' AS InsType, ISNULL(RT.PrimaryRecommendedCoverage, 0) AS [Term Life Coverage], 0 AS [Group Life Coverage], 
		0 AS [Permanent Life Coverage], 0 AS [Varable Life Coverage]
	FROM [Reporting].[vPlanRevision] PR LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] RT ON PR.PlanRevisionId = RT.BaselineId
	WHERE PR.PlanRevisionId = @PlanRevisionId
	ORDER BY InsType DESC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptMortRecommend]')) 
	DROP PROCEDURE [Reporting].[sprptMortRecommend]
GO
CREATE PROCEDURE [Reporting].[sprptMortRecommend]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT PR.PlanRevisionId ClientRevisionID, RT.RefinanceAmount MortRefinAmt, RT.RefinanceInterest MortRefinRate, RT.DepositToEmergencyFund EmergencyFundDeposit, 
		RT.RefinanceMonthlyPayment MortRefinPaymt, MT.Name MortRefinType, RT.RefinanceCosts MortRefinCost, PAY.CurrentPayments, PAY.ImprovedPayments,
		PAY.CurrentBalance - PAY.ImprovedBalance RepaymentOfExistingLoans, 
		(RT.RefinanceAmount - RT.RefinanceCosts - RT.DepositToEmergencyFund - (PAY.CurrentBalance - PAY.ImprovedBalance)) CashReserveDeposit
	FROM 
		[Reporting].[vPlanRevision] PR 
		LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] RT ON PR.PlanRevisionId = RT.BaselineId 
		LEFT JOIN Code.LookupItem MT ON RT.RefinanceTypeCode = MT.Code,
		(
			SELECT ISNULL(SUM(CurrentPayment), 0) CurrentPayments, ISNULL(SUM(ImprovedPayment), 0) ImprovedPayments,
				ISNULL(SUM(CurrentBalance), 0) CurrentBalance, ISNULL(SUM(ImprovedBalance), 0) ImprovedBalance  
			FROM [Reporting].[vLiability] 
			WHERE PlanRevisionId = @PlanRevisionId
		) PAY
	WHERE PR.PlanRevisionId = @PlanRevisionId

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptInvestRetirementGraph]')) 
	DROP PROCEDURE [Reporting].[sprptInvestRetirementGraph]
GO
CREATE PROCEDURE [Reporting].[sprptInvestRetirementGraph]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 

	DECLARE @CDoB datetime, @RevisionDate datetime, @StartAge int, @CRetireAge int, @ClientAge int
	 
	SELECT @CDoB = C.BirthDate, @RevisionDate = PR.CreateDate, @CRetireAge = FG.PrimaryRetirementAge, @ClientAge = FLOOR(DATEDIFF(day, C.BirthDate, getDate()) / 365.25)
	FROM 
		[Reporting].[vPlanRevision] PR
		JOIN Consumer.PrimaryConsumer C
			ON PR.PlanId = C.PrimaryConsumerId
		LEFT JOIN Consumer.SecondaryConsumer S
			ON PR.PlanRevisionId = S.BaselineId
		LEFT JOIN Consumer.FinancialPlan FG
			ON PR.PlanRevisionId = FG.BaselineId
	WHERE PR.PlanRevisionId = @PlanRevisionId

	SELECT @ClientAge + CAFRMth/12 AS [Client Age], InvestCloseBalCurrent AS [Current], InvestCloseBal AS [With MOP Plan], @ClientAge AS ClientAge
	FROM Reporting.CafrCalculation
	WHERE PlanRevisionId = @PlanRevisionId AND (@ClientAge + CAFRMth/12.0) <= @CRetireAge AND ROUND(CAFRMth/12.0,2) = CAFRMth/12
	ORDER BY (@ClientAge + CAFRMth/12.0)

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptClientProfile]')) 
	DROP PROCEDURE [Reporting].[sprptClientProfile]
GO
CREATE PROCEDURE [Reporting].[sprptClientProfile]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	
	SELECT
		C.PrimaryConsumerId ClientID, 
		PR.FinancialAdvisorId FinRepIDNo, 
		
		FLOOR(DATEDIFF(day, C.BirthDate, getDate()) / 365.25) CAge, 
		ISNULL(FG.PrimaryRetirementAge, 65) CRetireAge,
		C.FirstName C1stName, 
		C.MiddleName CMidNames, 
		C.LastName CLastName, 
		'' CTitle, --Dont collect this 
		'' CNameEnd, --Dont collect this 
		C.AlsoKnownBy CKnownName, 
		C.HomePhone CHomePhone, 
		C.MobilePhone CCellPhone, 
		C.WorkPhone CWorkPhone, 
		C.Email CHomeEmail, 
		'' CWorkEmail, --Dont collect this 
		'' CSSNumber, --Dont collect this 
		C.BirthDate CDoB, 
		C.DriverLicense CDrivLicense, 
		'' CDLState, --Dont collect this 
		NULL CDLIssueDate, --Dont collect this 
		NULL CDLExpDate, --Dont collect this
		C.PhysicalAddressLine CHAddress1, 
		'' CHAddress2, --Dont collect this
		C.PhysicalCity CHCity, 
		C.PhysicalState CHState, 
		C.PhysicalZip CHZipCode, 
		C.PhysicalAddressLine CMAddress1, 
		'' CMAddress2, --Dont collect this
		C.PhysicalCity CMCity, 
		C.PhysicalState CMState, 
		C.PhysicalZip CMZipCode, 
		PE.Title COccupation, 
		PE.Employer CEmployer, 
		'' CDivSchool, --Dont collect this
		'' CWAddress1, --Dont collect this
		'' CWAddress2, --Dont collect this
		'' CWCity, --Dont collect this
		'' CWState, --Dont collect this
		'' CWZipCode, --Dont collect this
		'' CTimeOnJob, --Dont collect this
		'' CPOccupation, --Dont collect this
		'' CPEmployer, --Dont collect this
		'' CPDivSchool, --Dont collect this
		'' CPWAddress1, --Dont collect this
		'' CPWAddress2, --Dont collect this
		'' CPWCity, --Dont collect this
		'' CPWState, --Dont collect this
		'' CPWZipCode, --Dont collect this
		CASE WHEN S.RelationshipCode = 'PRT-SPO' THEN 'Married' ELSE '' END CMaritalStatus, 
		DEP.Number CNoDependent, 

		FLOOR(DATEDIFF(day, S.BirthDate, getDate()) / 365.25) SAge, 
		CASE WHEN S.BaselineId IS NULL THEN NULL ELSE ISNULL(FG.SecondaryRetirementAge, 0) END SRetireAge,
		S.FirstName S1stName, 
		S.MiddleName SMidNames, 
		S.LastName SLastName, 
		'' STitle, --Dont collect this 
		'' SNameEnd, --Dont collect this 
		S.AlsoKnownBy SKnownName, 
		ISNULL(S.HomePhone, '') SHomePhone, 
		ISNULL(S.MobilePhone, '') SCellPhone, 
		ISNULL(S.WorkPhone, '') SWorkPhone, 
		S.Email SHomeEmail, 
		'' SWorkEmail, --Dont collect this 
		'' SSSNumber, --Dont collect this 
		S.BirthDate SDoB, 
		S.DriverLicense SDrivLicense, 
		'' SDLState, --Dont collect this 
		NULL SDLIssueDate, --Dont collect this 
		NULL SDLExpDate, --Dont collect this
		S.PhysicalAddressLine SHAddress1, 
		'' SHAddress2, --Dont collect this
		S.PhysicalCity SHCity, 
		S.PhysicalState SHState, 
		S.PhysicalZip SHZipCode, 
		S.PhysicalAddressLine SMAddress1, 
		'' SMAddress2, --Dont collect this
		S.PhysicalCity SMCity, 
		S.PhysicalState SMState, 
		S.PhysicalZip SMZipCode, 
		SE.Title SOccupation, 
		SE.Employer SEmployer, 
		'' SDivSchool, --Dont collect this
		'' SWAddress1, --Dont collect this
		'' SWAddress2, --Dont collect this
		'' SWCity, --Dont collect this
		'' SWState, --Dont collect this
		'' SWZipCode, --Dont collect this
		'' STimeOnJob, --Dont collect this
		'' SPOccupation, --Dont collect this
		'' SPEmployer, --Dont collect this
		'' SPDivSchool, --Dont collect this
		'' SPWAddress1, --Dont collect this
		'' SPWAddress2, --Dont collect this
		'' SPWCity, --Dont collect this
		'' SPWState, --Dont collect this
		'' SPWZipCode, --Dont collect this
		CASE WHEN S.RelationshipCode = 'PRT-SPO' THEN 'Married' ELSE '' END SMaritalStatus, 
		CASE WHEN S.BaselineId IS NULL THEN NULL ELSE DEP.Number END SNoDependent 

	FROM  [Reporting].[vPlanRevisionWithAdvisor] PR 
		JOIN Consumer.PrimaryConsumer C
			ON PR.PlanId = C.PrimaryConsumerId
		LEFT JOIN Consumer.PrimaryConsumerIncomeSource PE
			ON PR.PlanRevisionId = PE.BaselineId
		LEFT JOIN Consumer.SecondaryConsumer S
			ON PR.PlanRevisionId = S.BaselineId
		LEFT JOIN Consumer.SecondaryConsumerIncomeSource SE
			ON PR.PlanRevisionId = SE.BaselineId
		LEFT JOIN Consumer.FinancialPlan FG
			ON PR.PlanRevisionId = FG.BaselineId
		OUTER APPLY (
			SELECT Number = COUNT(*)
			FROM Consumer.FamilyMember FM
			WHERE FM.BaseLineId = PR.PlanRevisionId
				AND FM.[Dependent] = 1
		) DEP

	WHERE PR.PlanRevisionId = @PlanRevisionId

GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptClientRecommend]')) 
	DROP PROCEDURE [Reporting].[sprptClientRecommend]
GO
CREATE PROCEDURE [Reporting].[sprptClientRecommend]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT 
		R.RecommendationId, PlanRevisionId = BaselineId, RecommendationCategoryId = RecommendationCategoryCode, Description = RecommendationDescription, R.Priority,
		RC.SortOrder RecommendCatOrder, RC.Description RecommendDescFull
	FROM [Plan].Recommendation R INNER JOIN Code.LookupItem RC ON R.RecommendationCategoryCode = RC.Code
	WHERE R.BaselineId = @PlanRevisionId
	ORDER BY R.[Priority], RC.SortOrder

GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptCAFRCalculations]')) 
	DROP PROCEDURE [Reporting].[sprptCAFRCalculations]
GO
CREATE PROCEDURE [Reporting].[sprptCAFRCalculations]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 


	--TODO: when time permits, redo this entire thing. instead, it is just a port from the old system (just like the report)
	DECLARE @CAFR money, @ClientAgeCalc int,  @CAFRCurrent money

	DECLARE @RevisionDate datetime, @intNoOfYrs int, @EmergObjective money, @EmergRefinance money, @CashResObjective money, @CashResRefinance money
	DECLARE @CAFRP2Debt real, @CAFRP2Reserve real, @CAFRP2Debt2 real, @CAFRP3Debt real, @CAFRP3Reserve real, @CAFRP4Reserve real
	DECLARE @MortRefinAmt money, @MortRefinRate real, @MortRefinPaymt money
	DECLARE @intCurMth int, @CAFRAmtLeft money, @EmergSavCAFR money, @CashResSavCAFR money, @CashResCloseBal money, @ExtraCAFR money
	DECLARE @DebtCAFR money, @DebtTotalBalance money, @DebtRepaid bit, @intDebtRow int, @intDebtRowMax int
	DECLARE @intInvestRow int, @intInvestRowMax int, @intAssetRow int, @intAssetRowMax int, @AssetType varchar(20)
	DECLARE @EmergBal money, @EmergSav money, @EmergBalCurrent money, @EmergSavCurrent money, @CashResBal money, @CashResSav money 
	DECLARE @CashResBalCurrent money, @CashResSavCurrent money, @CAFRPhase money, @CAFRAdjust money, @CAFRDebtAdjust money
	DECLARE @InvestOpenBal money, @InvestInterest money, @InvestIntRate real, @InvestCont money, @InvestCAFRCont money, @InvestCloseBal money 
	DECLARE @InvestCloseBalCurrent money
	DECLARE @LiabilityType varchar(20), @YrsFixed smallint, @YrsIntOnly smallint, @IntOnlyCeaseDte datetime 
	DECLARE @IntOnlyCAFRAdjust smallint, @InterestRate real, @CurrentBalance money, @MthlyPaymentIntOnly money 
	DECLARE @MthlyPaymentImp money, @Principal money, @InterestAmt money, @CurrentBalanceCurrent money, @MthlyPayment money, @InterestAmtCurrent money
	DECLARE @RealEstateValue money, @AutoValue money, @PersonalPropValue money
	DECLARE @DebtCAFRPayment money, @DebtExtraCAFR money, @DebtExtraCAFRNew money, @DebtOpenBal money, @DebtMinPayment money 
	DECLARE @DebtCAFRCont money, @DebtPrincipal money, @DebtInterest money, @DebtInterestMort money, @DebtInterestConsumer money, @DebtCloseBal money
	DECLARE @DebtCloseBalMort money, @DebtCloseBalConsumer money
	DECLARE @DebtInterestCurrent money, @DebtInterestMortCurrent money
	DECLARE @DebtInterestConsumerCurrent money, @DebtCloseBalCurrent money, @DebtCloseBalMortCurrent money, @DebtCloseBalConsumerCurrent money
	DECLARE @DebtExtraCAFRPrev money
	DECLARE @DebtMortRepaid bit, @DebtMortExtraCAFRNew money, @DebtCAFRPaymentMort money, @DebtCAFRPaymentConsumer money
	DECLARE @CPreRetireRate real, @SPreRetireRate real, @AvgPreRetireRate real, @CPostRetireRate real, @SPostRetireRate real, @AvgPostRetireRate real
	DECLARE @CRetireAge int, @CMiscDebtRate real, @SMiscDebtRate real, @AvgMiscDebtRate real, @Phase2 bit, @Phase3 bit

	SELECT 
		@RevisionDate = PR.CreateDate, 
		@intNoOfYrs = PR.CafrYears, 
		@EmergRefinance = RT.DepositToEmergencyFund, 
		@EmergObjective = RT.RecommendedEmergencyFund, 
		@CashResRefinance = [Reporting].[GetCashReserveDeposit](PR.PlanRevisionId),
		@MortRefinAmt = RT.RefinanceAmount, 
		@MortRefinRate = RT.RefinanceInterest, 
		@MortRefinPaymt = RT.RefinanceMonthlyPayment,
		@CashResObjective = RT.RecommendedCashReserve, 
		@CAFRP2Debt = RT.Phase2NonFirstMortgageDebtReduction, 
		@CAFRP2Reserve = RT.Phase2CashReservesRate, 
		@CAFRP2Debt2 = RT.Phase2AlternateNonFirstMortgageDebtReduction, 
		@CAFRP3Debt = RT.Phase3FirstMortgageDebtReduction, 
		@CAFRP3Reserve = RT.Phase3CashReservesRate, 
		@CAFRP4Reserve = RT.Phase4CashReservesRate, 
		@CPreRetireRate = RT.PrimaryPreRetirementReturnRate, 
		@SPreRetireRate = 0, --Dont have sec anymore
		@CPostRetireRate = RT.PrimaryPreRetirementReturnRate,  --Dont have post anymore
		@SPostRetireRate = 0,  --Dont have sec anymore
		@CRetireAge = ISNULL(FG.PrimaryRetirementAge, 65),
		@CMiscDebtRate = RT.PrimaryMiscellaneousDebtRate, 
		@SMiscDebtRate = 0 --Dont have sec anymore
	FROM  
		[Reporting].[vPlanRevision] PR
		LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] RT
			ON PR.PlanRevisionId = RT.BaselineID
		LEFT JOIN Consumer.FinancialPlan FG
			ON PR.PlanRevisionId = FG.BaselineId
	WHERE PR.PlanRevisionId = @PlanRevisionId



	SELECT @ClientAgeCalc = FLOOR(DATEDIFF(day, C.BirthDate, getDate()) / 365.25)
	FROM  [Reporting].[vPlanRevision] PR 
		JOIN Consumer.PrimaryConsumer C
			ON PR.PlanId = C.PrimaryConsumerId
	WHERE PR.PlanRevisionId = @PlanRevisionId

	SELECT @CAFR = (ISNULL([Reporting].GetTotalNetIncome(@PlanRevisionId, 1), 0) - 
		ISNULL(L.TotalPaymentsImp, 0) - ISNULL(IV.TotalDepositsImp, 0) - ISNULL(B.TotalExpensesImp, 0) - @MortRefinPaymt - 
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'LifeImp') - [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'TxSavImp')),

		@CAFRCurrent = ISNULL([Reporting].GetTotalNetIncome(@PlanRevisionId, 1), 0) - 
		ISNULL(L.TotalPayments, 0) - ISNULL(IV.TotalDeposits, 0) - ISNULL(B.TotalExpenses, 0) - 
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'Life') - [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'TxSav')
	FROM 
		(
			SELECT SUM(L.ImprovedPayment) TotalPaymentsImp, SUM(L.CurrentPayment) TotalPayments
			FROM [Reporting].[vLiability] L
			WHERE L.PlanRevisionId = @PlanRevisionId
		) L,
		(
			SELECT SUM(A.ImprovedContributions) TotalDepositsImp, SUM(A.CurrentContributions) TotalDeposits
			FROM [Reporting].[vAsset] A 
			WHERE A.PlanRevisionId = @PlanRevisionId AND AssetSubTypeCode NOT IN ('AT-V-TA') AND AssetTypeCode NOT IN ('AT-I')
		) IV,
		(
			SELECT B.TotalExpensesImproved TotalExpensesImp, B.TotalExpenses
			FROM [Reporting].[vBudgetSummary] B
			WHERE B.PlanRevisionId = @PlanRevisionId
		) B 



	IF @SPreRetireRate <> 0
		SET @AvgPreRetireRate = ROUND((@CPreRetireRate + @SPreRetireRate) / 2, 2)
	ELSE
		SET @AvgPreRetireRate = @CPreRetireRate

	IF @SPostRetireRate <> 0
		SET @AvgPostRetireRate = ROUND((@CPostRetireRate + @SPostRetireRate) / 2, 2)
	ELSE
		SET @AvgPostRetireRate = @CPostRetireRate

	IF @SMiscDebtRate <> 0
		SET @AvgMiscDebtRate = ROUND((@CMiscDebtRate + @SMiscDebtRate) / 2, 2)
	ELSE
		SET @AvgMiscDebtRate = @CMiscDebtRate


	--Clear reporting tables
	DELETE FROM Reporting.CafrCalculation WHERE [PlanRevisionId] = @PlanRevisionId
	DELETE FROM Reporting.ClientDebt WHERE [PlanRevisionId] = @PlanRevisionId
	DELETE FROM Reporting.ClientDebtCafr WHERE [PlanRevisionId] = @PlanRevisionId
	DELETE FROM Reporting.ClientInvest WHERE [PlanRevisionId] = @PlanRevisionId
	DELETE FROM Reporting.ClientInvestCafr WHERE [PlanRevisionId] = @PlanRevisionId
	DELETE FROM Reporting.ClientAsset WHERE [PlanRevisionId] = @PlanRevisionId

	DECLARE @Counter int
	SET @Counter = 1

	IF ROUND(@CAFRCurrent,0) < 0 BEGIN
		INSERT INTO Reporting.ClientDebt (PlanRevisionId, Counter, LiabilityType, LiabilityType2, ClientAssetIDNo, LiabilityDescription, Owner, YrsFixed, YrsIntOnly, IntOnlyCeaseDte, 
			IntOnlyCAFRAdjust, InterestRate, CurrentBalance, CurrentBalanceCurrent, MthlyPaymentIntOnly, MthlyPayment, MthlyPaymentImp, SortOrder)
		VALUES (@PlanRevisionId, @Counter, 'Other', 'Other', NULL, 'Negative CAFR', 'Client', 0, 0, NULL , 0, @AvgMiscDebtRate, 0, 0.01, 0, @CAFRCurrent, 0, 0)
	
		SET @Counter = @Counter + 1
	END

	IF ROUND(@CAFR,0) < 0 BEGIN
		INSERT INTO Reporting.ClientDebt (PlanRevisionId, Counter, LiabilityType, LiabilityType2, ClientAssetIDNo, LiabilityDescription, Owner, YrsFixed, YrsIntOnly, IntOnlyCeaseDte, 
			IntOnlyCAFRAdjust, InterestRate, CurrentBalance, CurrentBalanceCurrent, MthlyPaymentIntOnly, MthlyPayment, MthlyPaymentImp, SortOrder)
		VALUES (@PlanRevisionId, @Counter, 'Other', 'Other', NULL, 'Negative MOPro CAFR', 'Client', 0, 0, NULL , 0, @AvgMiscDebtRate, 0.01, 0, 0, 0, @CAFR, 0)
	
		SET @Counter = @Counter + 1
	END


	INSERT INTO Reporting.ClientDebt (PlanRevisionId, Counter, LiabilityType, LiabilityType2, ClientAssetIDNo, LiabilityDescription, Owner, YrsFixed, YrsIntOnly, IntOnlyCeaseDte, 
		IntOnlyCAFRAdjust, InterestRate, CurrentBalance, CurrentBalanceCurrent, MthlyPaymentIntOnly, MthlyPayment, MthlyPaymentImp, SortOrder)
	SELECT @PlanRevisionId, @Counter, 'Property' AS LiabilityType, 'Refinance' AS LiabilityType2, 0 AS ClientAssetIDNo, '' AS LiabilityDescription, '' AS Owner, 0 AS YrsFixed, 0 AS YrsIntOnly, 
		NULL AS IntOnlyCeaseDte, 0, @MortRefinRate, @MortRefinAmt AS CurrentBalance, 0, 0, 0, 
		@MortRefinPaymt, 0
	UNION SELECT @PlanRevisionId, row_number() over (order by L.ImprovedBalance) + @Counter as Counter, CASE L.LiabilityTypeCode WHEN 'LT-RE' THEN 'Property' ELSE 'Other' END LiabilityType, L.LiabilityTypeName LiabilityType2, 
		L.AssetId ClientAssetIDNo, L.Description LiabilityDescription, L.OwnerTypeName Owner, L.FixedYears YrsFixed, L.InterestOnlyYears YrsIntOnly, L.InterestOnlyCeaseDate IntOnlyCeaseDte, 
		0, L.InterestRate, L.ImprovedBalance CurrentBalance, L.CurrentBalance CurrentBalanceCurrent, L.InterestOnlyCurrentPayment MthlyPaymentIntOnly, L.CurrentPayment MthlyPayment, L.ImprovedPayment MthlyPaymentImp, 0 SortOrder
	FROM 
		[Reporting].[vLiability] L 
	WHERE L.PlanRevisionId = @PlanRevisionId
	ORDER BY CurrentBalance

	SET @intDebtRowMax = @@ROWCOUNT + @Counter - 1


	IF ROUND(@CAFRCurrent,0) < 0 
		SET @CAFRCurrent = 0

	IF ROUND(@CAFR,0) < 0 
		SET @CAFR = 0



	INSERT INTO Reporting.ClientInvest (PlanRevisionId, Counter, Owner, Description, Description2, AccountNo, MarketValue, MarketValueCurrent, Contributions, ContributionsImp, InterestRate, InvestmentType,
		SortOrder)
	SELECT @PlanRevisionId, row_number() over (order by A.AssetId) as Counter, A.OwnerTypeName Owner, A.Description, A.Account Description2, '' AccountNo, A.MarketValue, A.MarketValue, A.CurrentContributions + ISNULL(TA.EmployerMonthlyDollarContributions, 0) Contributions, 
		A.ImprovedContributions + ISNULL(TA.EmployerMonthlyDollarContributions, 0) ContributionsImp, A.Rate InterestRate, A.AssetSubTypeCode InvestmentType, 0 SortOrder
	FROM
		[Reporting].[vAsset] A 
		LEFT JOIN Consumer.TaxAdvantagedAsset TA 
			ON A.AssetId = TA.TaxAdvantagedAssetId
				AND A.AssetSubTypeCode = 'AT-V-TA'
	WHERE A.PlanRevisionId = @PlanRevisionId AND AssetTypeCode = 'AT-V' AND A.AssetSubTypeCode NOT IN ('AT-V-CR', 'AT-V-EF')
	ORDER BY A.Rate DESC, A.MarketValue DESC

	SET @intInvestRowMax = @@ROWCOUNT



	INSERT INTO Reporting.ClientAsset (PlanRevisionId, Counter, AssetType, MarketValue, InterestRate)
	SELECT @PlanRevisionId, row_number() over (order by A.AssetId) as Counter, A.AssetTypeName AssetType, CASE WHEN A.AssetSubTypeCode IN ('AT-P-R', 'AT-P-C') THEN ROUND(A.MarketValue* 0.9,0) ELSE A.MarketValue END, A.Rate InterestRate
	FROM
		[Reporting].[vAsset] A 
	WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetTypeCode IN ('AT-P', 'AT-A', 'AT-O')

	SET @intAssetRowMax = @@ROWCOUNT


	SET @intCurMth = 1
	SET @EmergBal = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'EmergInv') + @EmergRefinance
	SET @EmergBalCurrent = @EmergBal
	SET @EmergSav = [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'EmergSavImp')
	SET @EmergSavCurrent = [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'EmergSav')
	SET @CashResBal = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'CashInv') + @CashResRefinance
	SET @CashResCloseBal = @CashResBal
	SET @CashResBalCurrent = @CashResBal
	SET @CashResSav = [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'CashSavImp')
	SET @CashResSavCurrent = [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'CashSav')
	SET @InvestOpenBal = 0
	SET @InvestCloseBal = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'TxInv') + Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'NTxInv') +
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OtherInv')
	SET @InvestCloseBalCurrent = @InvestCloseBal
	SET @DebtOpenBal =  Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'AllLoan')

	SET @DebtCloseBalMortCurrent = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'AllProperty')
	SET @DebtCloseBalConsumerCurrent = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'AllOtherLoan')
	SET @DebtCloseBalMort = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'AllPropertyImp') + @MortRefinAmt
	SET @DebtCloseBalConsumer = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'AllOtherLoanImp')

	SET @DebtRepaid = 0
	SET @DebtExtraCAFR = 0
	SET @DebtExtraCAFRPrev = 0
	SET @DebtMortRepaid = 0
	SET @RealEstateValue = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'AllProp')
	SET @AutoValue = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'Auto')
	SET @PersonalPropValue = Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OtherAsset')

	INSERT INTO Reporting.CafrCalculation (PlanRevisionId, CAFRMth, CAFR, EmergOpenBal, EmergBudgetCont, EmergCAFRCont, EmergCloseBal, EmergCloseBalCurrent, 
		CashResOpenBal, CashResBudgetCont, CashResCAFRCont, CashResCloseBal, CashResCloseBalCurrent, DebtOpenBal, DebtMinPayment, DebtCAFRCont,  
		DebtCAFRContMort, DebtCAFRContConsumer, DebtPrincipal, DebtInterest, DebtCloseBal, DebtCloseBalMort, DebtCloseBalConsumer, DebtInterestCurrent, 
		DebtCloseBalCurrent, DebtCloseBalMortCurrent, DebtCloseBalConsumerCurrent, InvestOpenBal, 
		InvestInterest, InvestCont, InvestCAFRCont, InvestCloseBal, InvestCloseBalCurrent, RealEstateValue, AutoValue, PersonalPropValue, ExtraCAFR, 
		DebtExtraCAFRPrev, DebtExtraCAFR, CAFRAmtLeft)
	SELECT @PlanRevisionId, 0, 0, @EmergBal, 0, 0, @EmergBal, @EmergBalCurrent, @CashResBal, 0, 0, @CashResBal, @CashResBalCurrent, @DebtCloseBalMort + @DebtCloseBalConsumer, 0, 0, 0, 0, 0, 0, 
		@DebtCloseBalMort + @DebtCloseBalConsumer, @DebtCloseBalMort, @DebtCloseBalConsumer, 0, @DebtOpenBal, @DebtCloseBalMortCurrent, @DebtCloseBalConsumerCurrent,
		@InvestOpenBal, 0, 0, 0, @InvestCloseBal, @InvestCloseBalCurrent, @RealEstateValue, @AutoValue, @PersonalPropValue, 0, 0, 0, 0  

	WHILE @intCurMth <= (@intNoOfYrs * 12)
	BEGIN
		SET @CAFRAmtLeft = @CAFR
		SET @ExtraCAFR = 0
		SET @CAFRAdjust = 0
		SET @CAFRDebtAdjust = 0
		SET @EmergSavCAFR = 0
		SET @CashResSavCAFR = 0
		SET @DebtCAFR = 0
		SET @DebtExtraCAFRNew = 0
		SET @InvestCAFRCont = 0
		SET @DebtMortExtraCAFRNew = 0
		IF @ClientAgeCalc < @CRetireAge
			SET @InvestIntRate = @AvgPreRetireRate
		ELSE
			SET @InvestIntRate = @AvgPostRetireRate
		SET @EmergBalCurrent = @EmergBalCurrent + @EmergSavCurrent
		SET @CashResBalCurrent = @CashResBalCurrent + @CashResSavCurrent
		SET @Phase2 = 0
		SET @Phase3 = 0

		IF @intCurMth/12 = CEILING((@intCurMth + 0.0) / 12)
			BEGIN
				SET @RealEstateValue = 0
				SET @AutoValue = 0
				SET @PersonalPropValue = 0

				--Loop through ##ttmpClientAsset and update balances
				Set @intAssetRow = 1
				WHILE @intAssetRow <= @intAssetRowMax
					BEGIN
						SELECT @AssetType = AssetType, @CurrentBalance = MarketValue, @InterestRate = InterestRate
						FROM Reporting.ClientAsset
						WHERE Counter = @intAssetRow AND PlanRevisionId = @PlanRevisionId

						IF @AssetType = 'Property'
							BEGIN
								SET @CurrentBalance = ROUND(@CurrentBalance * (1 + @InterestRate),0)

								UPDATE  Reporting.ClientAsset 
								SET MarketValue = @CurrentBalance
								WHERE Counter = @intAssetRow AND PlanRevisionId = @PlanRevisionId

								SET @RealEstateValue = @RealEstateValue + @CurrentBalance
							END
						ELSE
							BEGIN
								SET @CurrentBalance = ROUND(@CurrentBalance * (1 - @InterestRate),0)

								UPDATE  Reporting.ClientAsset 
								SET MarketValue = @CurrentBalance
								WHERE Counter = @intAssetRow AND PlanRevisionId = @PlanRevisionId

								IF @AssetType = 'Automobile'
									SET @AutoValue = @AutoValue + @CurrentBalance
								ELSE
									SET @PersonalPropValue = @PersonalPropValue + @CurrentBalance
							END

						Set @intAssetRow = @intAssetRow + 1
					END
			END

-- Phase 1
		IF @EmergBal < @EmergObjective 
			IF (@EmergBal + @EmergSav + @CAFRAmtLeft) < @EmergObjective and (@CAFRAmtLeft > 0)-- Add all to Emergency Fund
				BEGIN
					SET @EmergSavCAFR = @CAFRAmtLeft
					SET @CAFRAmtLeft = 0
				END
			ELSE
				BEGIN
					IF (@EmergBal + @EmergSav) >= @EmergObjective -- Use EmergSav to complete Emergency Fund
						BEGIN
							SET @ExtraCAFR = @ExtraCAFR + @EmergSav
							SET @CAFRAmtLeft = @CAFRAmtLeft + @EmergSav - (@EmergObjective - @EmergBal)
							SET @CAFRAdjust = @EmergSav - (@EmergObjective - @EmergBal)
							SET @EmergSav = @EmergObjective - @EmergBal
						END
					ELSE -- Use CAFR to complete Emergency Fund
						BEGIN
							IF @CAFRAmtLeft > 0
								BEGIN
									SET @ExtraCAFR = @ExtraCAFR + @EmergSav
									SET @EmergSavCAFR = @EmergObjective - @EmergBal - @EmergSav
									SET @CAFRAmtLeft = @CAFRAmtLeft - @EmergSavCAFR
								END
					END
				END

-- Phase 2
		IF @DebtRepaid = 0 
			BEGIN
				-- Cash Reserves
				SET @Phase2 = 1
				SET @CAFRPhase = @CAFRAmtLeft -- What is available at start of phase
				IF @CashResBal < @CashResObjective
					BEGIN 
						IF (@CashResBal + @CashResSav + ROUND(@CAFRAmtLeft * @CAFRP2Reserve, 2)) < @CashResObjective and (@CAFRAmtLeft > 0)
							BEGIN
								SET @CashResSavCAFR = ROUND(@CAFRAmtLeft * @CAFRP2Reserve, 2)
								SET @CAFRAmtLeft = @CAFRAmtLeft - (ROUND(@CAFRAmtLeft * @CAFRP2Reserve, 2))
							END
						ELSE
							BEGIN
								IF (@CashResBal + @CashResSav) >= @CashResObjective -- Use CashResSav to complete Cash Reserves
									BEGIN
										SET @ExtraCAFR = @ExtraCAFR + @CashResSav
										SET @CAFRAmtLeft = @CAFRAmtLeft + @CashResSav - (@CashResObjective - @CashResBal)
										SET @CAFRAdjust = @CAFRAdjust + @CashResSav - (@CashResObjective - @CashResBal)
										SET @CashResSav = @CashResObjective - @CashResBal
									END
								ELSE -- Use CAFR to complete Cash Reserves
									BEGIN
										IF @CAFRAmtLeft > 0
											BEGIN
												SET @ExtraCAFR = @ExtraCAFR + @CashResSav
												SET @CashResSavCAFR = @CashResObjective - @CashResBal - @CashResSav
												SET @CAFRAmtLeft = @CAFRAmtLeft - @CashResSavCAFR
											END
									END
							END
						SET @CashResCloseBal = @CashResBal + @CashResSav + @CashResSavCAFR
					END

				-- Debt Reduction
				IF @CAFRPhase > 0
					BEGIN
						IF ROUND(@CAFRAmtLeft - (@CAFRPhase - (ROUND(@CAFRPhase * @CAFRP2Reserve, 2))),0) = 0 
							SET @DebtCAFR = ROUND(@CAFRPhase * @CAFRP2Debt, 2) -- 1st Debt percentage
						ELSE -- Cash Reserves completed
							SET @DebtCAFR = ROUND(@CAFRAmtLeft * @CAFRP2Debt2, 2) -- 2nd debt percentage
					END
				ELSE
					SET @DebtCAFR = 0

				SET @CAFRAmtLeft = @CAFRAmtLeft - @DebtCAFR
				SET @DebtCAFR = @DebtCAFR + @DebtExtraCAFR
				SET @DebtTotalBalance = 0

				--Loop through ##ttmpClientDebt using CAFR to repay where can and create records in ttmpClientDebtCAFR
				Set @intDebtRow = 1
				SET @DebtMortRepaid = 1
				WHILE @intDebtRow <= @intDebtRowMax
					BEGIN
						SELECT @LiabilityType = LiabilityType, @YrsFixed = YrsFixed, @YrsIntOnly = YrsIntOnly, 
							@IntOnlyCeaseDte = IntOnlyCeaseDte, @IntOnlyCAFRAdjust = IntOnlyCAFRAdjust,
							@InterestRate = InterestRate, @CurrentBalance = CurrentBalance, 
							@CurrentBalanceCurrent = CurrentBalanceCurrent, @MthlyPaymentIntOnly = MthlyPaymentIntOnly, @MthlyPaymentImp = MthlyPaymentImp,
							@MthlyPayment = MthlyPayment
						FROM  Reporting.ClientDebt
						WHERE Counter = @intDebtRow AND PlanRevisionId = @PlanRevisionId

						SET @DebtCAFRPayment = 0
						SET @DebtCAFRPaymentMort = 0
						SET @DebtCAFRPaymentConsumer = 0

						IF (@LiabilityType = 'Property' OR @DebtCAFR = 0)
							BEGIN
								SET @InterestAmt = ROUND(@CurrentBalance * @InterestRate / 12, 2)
								IF DATEADD(m, @intCurMth, @RevisionDate) > ISNULL(@IntOnlyCeaseDte, @RevisionDate)
									BEGIN
										SET @Principal = @MthlyPaymentImp - @InterestAmt
										IF @CurrentBalance = 0
											SET @Principal = 0
										IF @IntOnlyCAFRAdjust = 0 AND @YrsIntOnly > 0
											BEGIN -- Adjust CAFR for extra loan payment amt
												SET @ExtraCAFR = @ExtraCAFR - @Principal
												SET @CAFRAdjust = @CAFRAdjust - @Principal
												SET @CAFRAmtLeft = @CAFRAmtLeft - @Principal
												SET @IntOnlyCAFRAdjust = 1
											END
									END
								ELSE -- Interest only period
									BEGIN
										SET @Principal = @MthlyPaymentIntOnly - @InterestAmt
										IF @CurrentBalance = 0
											SET @Principal = 0
									END

								IF @Principal >= @CurrentBalance AND (@CurrentBalance >= 0)
									BEGIN
										SET @DebtCAFR = @DebtCAFR + (@Principal - @CurrentBalance)
										SET @CAFRDebtAdjust = @CAFRDebtAdjust + (@Principal - @CurrentBalance)
										SET @Principal = @CurrentBalance
										IF @Principal <> 0
											SET @DebtExtraCAFRNew = @DebtExtraCAFRNew + @MthlyPaymentImp
									END

								SET @InterestAmtCurrent = ROUND(@CurrentBalanceCurrent * @InterestRate / 12, 2)
								IF DATEADD(m, @intCurMth, @RevisionDate) <= ISNULL(@IntOnlyCeaseDte, @RevisionDate)
									SET @MthlyPayment = @MthlyPaymentIntOnly -- Interest only period
								IF @CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent) < 0
									SET @MthlyPayment = (@CurrentBalanceCurrent + @InterestAmtCurrent)

								INSERT INTO Reporting.ClientDebtCafr (PlanRevisionId, ClientDebtIDNo, CAFRMth, LiabilityType, DebtOpenBal, 
									DebtMinPayment, DebtCAFRPayment, DebtCAFRPaymtMort, DebtCAFRPaymtConsumer, DebtPrincipal, 
									DebtInterest, DebtCloseBal, DebtInterestCurrent, DebtCloseBalCurrent)
								SELECT @PlanRevisionId, @intDebtRow, @intCurMth, @LiabilityType, @CurrentBalance, @MthlyPaymentImp, @DebtCAFRPayment, 
									@DebtCAFRPaymentMort, @DebtCAFRPaymentConsumer, @Principal, @InterestAmt, 
									@CurrentBalance - @Principal - @DebtCAFRPayment, @InterestAmtCurrent,
									@CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent)

								UPDATE Reporting.ClientDebt 
								SET CurrentBalance = @CurrentBalance - @Principal - @DebtCAFRPayment,
									CurrentBalanceCurrent = @CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent),
									IntOnlyCAFRAdjust = @IntOnlyCAFRAdjust
								WHERE Counter = @intDebtRow AND PlanRevisionId = @PlanRevisionId

								IF @LiabilityType <> 'Property' 
									SET @DebtTotalBalance = @DebtTotalBalance + 
										(@CurrentBalance - @Principal - @DebtCAFRPayment)
								ELSE
									IF @CurrentBalance - @Principal - @DebtCAFRPayment <> 0
										SET @DebtMortRepaid = 0 -- Not all mortgages repaid
							END
						ELSE
							BEGIN
								SET @InterestAmt = ROUND(@CurrentBalance * @InterestRate / 12, 2)
								IF DATEADD(m, @intCurMth, @RevisionDate) > ISNULL(@IntOnlyCeaseDte, @RevisionDate)
									BEGIN
										SET @Principal = @MthlyPaymentImp - @InterestAmt

										IF @IntOnlyCAFRAdjust = 0 AND @YrsIntOnly > 0
											BEGIN -- Adjust CAFR for extra loan payment amt
												SET @ExtraCAFR = @ExtraCAFR - @Principal
												SET @CAFRAdjust = @CAFRAdjust - @Principal
												SET @CAFRAmtLeft = @CAFRAmtLeft - @Principal
												SET @IntOnlyCAFRAdjust = 1
											END
									END
								ELSE -- Interest only period
									BEGIN
										SET @Principal = @MthlyPaymentIntOnly - @InterestAmt
										IF @CurrentBalance = 0
											SET @Principal = 0
									END

								IF @CurrentBalance > 0
									BEGIN
										IF @Principal >= @CurrentBalance -- Repay all from principal
											BEGIN
												SET @DebtCAFR = @DebtCAFR + (@Principal - @CurrentBalance)
												SET @CAFRDebtAdjust = @CAFRDebtAdjust + (@Principal - @CurrentBalance)
												SET @Principal = @CurrentBalance
												SET @DebtExtraCAFRNew = @DebtExtraCAFRNew + @MthlyPaymentImp
											END
										ELSE
											IF @CurrentBalance > (@Principal + @DebtCAFR) -- Use all DebtCAFR
												BEGIN
													SET @DebtCAFRPayment = @DebtCAFR
													SET @DebtCAFR = 0
												END
											ELSE -- Repay with DebtCAFR
												BEGIN
													SET @DebtCAFRPayment = @CurrentBalance - @Principal
													SET @DebtCAFR = @DebtCAFR - @DebtCAFRPayment

													IF DATEADD(m, @intCurMth, @RevisionDate) > ISNULL(@IntOnlyCeaseDte, @RevisionDate)
														SET @DebtExtraCAFRNew = @DebtExtraCAFRNew + @MthlyPaymentImp
													ELSE
														SET @DebtExtraCAFRNew = @DebtExtraCAFRNew + @MthlyPaymentIntOnly
												END
									END
								ELSE
										SET @Principal = 0

								SET @DebtCAFRPaymentConsumer = @DebtCAFRPayment

								SET @InterestAmtCurrent = ROUND(@CurrentBalanceCurrent * @InterestRate / 12, 2)
								IF DATEADD(m, @intCurMth, @RevisionDate) <= ISNULL(@IntOnlyCeaseDte, @RevisionDate)
									SET @MthlyPayment = @MthlyPaymentIntOnly -- Interest only period
								IF @CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent) < 0
									SET @MthlyPayment = (@CurrentBalanceCurrent + @InterestAmtCurrent)

								INSERT INTO Reporting.ClientDebtCafr (PlanRevisionId, ClientDebtIDNo, CAFRMth, LiabilityType, DebtOpenBal, 
									DebtMinPayment, DebtCAFRPayment, DebtCAFRPaymtMort, DebtCAFRPaymtConsumer, DebtPrincipal, 
									DebtInterest, DebtCloseBal, DebtInterestCurrent, DebtCloseBalCurrent)
								SELECT @PlanRevisionId, @intDebtRow, @intCurMth, @LiabilityType, @CurrentBalance, @MthlyPaymentImp, @DebtCAFRPayment, 
									@DebtCAFRPaymentMort, @DebtCAFRPaymentConsumer, @Principal, @InterestAmt, 
									@CurrentBalance - @Principal - @DebtCAFRPayment, @InterestAmtCurrent,
									@CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent)
	
								UPDATE  Reporting.ClientDebt 
								SET CurrentBalance = @CurrentBalance - @Principal - @DebtCAFRPayment,
									CurrentBalanceCurrent = @CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent),
									IntOnlyCAFRAdjust = @IntOnlyCAFRAdjust
								WHERE Counter = @intDebtRow AND PlanRevisionId = @PlanRevisionId

								IF @LiabilityType <> 'Property' 
									SET @DebtTotalBalance = @DebtTotalBalance + 
										(@CurrentBalance - @Principal - @DebtCAFRPayment)
							END

						SET @intDebtRow = @intDebtRow + 1
					END
				
				SET @DebtExtraCAFR = @DebtExtraCAFR + @DebtExtraCAFRNew
				SET @CAFRAmtLeft = @CAFRAmtLeft + @DebtCAFR -- added to Investment accounts when last loan (apart from Mortgages) repaid
				IF @DebtTotalBalance = 0 SET @DebtRepaid = 1

				-- Balance left CAFR to Investment accounts
				--Loop through ##ttmpClientInvest using CAFR to invest where can and create records in ttmpClientInvestCAFR
				SET @intInvestRow = 1
				WHILE @intInvestRow <= @intInvestRowMax
					BEGIN
						SELECT @InterestRate = InterestRate, @CurrentBalance = MarketValue, @MthlyPaymentImp = ContributionsImp,
							@CurrentBalanceCurrent = MarketValueCurrent, @MthlyPayment = Contributions
						FROM  Reporting.ClientInvest
						WHERE Counter = @intInvestRow AND PlanRevisionId = @PlanRevisionId

						SET @InterestAmt = ROUND(@CurrentBalance * @InvestIntRate / 12, 2)
						SET @InterestAmtCurrent = ROUND(@CurrentBalanceCurrent * @InvestIntRate / 12, 2)
						
						IF @CAFRAmtLeft > 0 
							BEGIN
								INSERT INTO Reporting.ClientInvestCafr (PlanRevisionId, ClientInvestIDNo, CAFRMth, InvestOpenBal, InvestInterest, 
									InvestCont, InvestCAFRCont, InvestCloseBal, InvestCloseBalCurrent)
								SELECT @PlanRevisionId, @intInvestRow, @intCurMth, @CurrentBalance, @InterestAmt, @MthlyPaymentImp, @CAFRAmtLeft, 
									@CurrentBalance + @InterestAmt + @MthlyPaymentImp + @CAFRAmtLeft,
									@CurrentBalanceCurrent + @InterestAmtCurrent + @MthlyPayment

								UPDATE  Reporting.ClientInvest 
								SET MarketValue = @CurrentBalance + @InterestAmt + @MthlyPaymentImp + @CAFRAmtLeft,
									MarketValueCurrent = @CurrentBalanceCurrent + @InterestAmtCurrent + @MthlyPayment
								WHERE Counter = @intInvestRow AND PlanRevisionId = @PlanRevisionId

								SET @InvestCAFRCont = @CAFRAmtLeft
								SET @CAFRAmtLeft = 0
							END
						ELSE
							BEGIN
								INSERT INTO Reporting.ClientInvestCafr (PlanRevisionId, ClientInvestIDNo, CAFRMth, InvestOpenBal, InvestInterest, 
									InvestCont, InvestCAFRCont, InvestCloseBal, InvestCloseBalCurrent)
								SELECT @PlanRevisionId, @intInvestRow, @intCurMth, @CurrentBalance, @InterestAmt, @MthlyPaymentImp, 0, 
									@CurrentBalance + @InterestAmt + @MthlyPaymentImp,
									@CurrentBalanceCurrent + @InterestAmtCurrent + @MthlyPayment

								UPDATE  Reporting.ClientInvest 
								SET MarketValue = @CurrentBalance + @InterestAmt + @MthlyPaymentImp,
									MarketValueCurrent = @CurrentBalanceCurrent + @InterestAmtCurrent + @MthlyPayment
								WHERE Counter = @intInvestRow AND PlanRevisionId = @PlanRevisionId
							END

						SET @intInvestRow = @intInvestRow + 1
					END
			END

-- Phase 3  (Mortgages to be paid off)
--		IF (@CAFRAmtLeft + @DebtExtraCAFR > 0) and @DebtMortRepaid = 0 and (@Phase2 = 0)
		IF @DebtMortRepaid = 0 and (@Phase2 = 0)
			BEGIN
				SET @Phase3 = 1
				-- Cash Reserves
				SET @CAFRAmtLeft = @CAFRAmtLeft + @DebtExtraCAFR -- What is available at start of phase
				SET @CAFRPhase = @CAFRAmtLeft -- What is available at start of phase
				IF @CashResBal < @CashResObjective
					BEGIN
						IF (@CashResBal + @CashResSav + ROUND(@CAFRAmtLeft * @CAFRP3Reserve, 2)) < @CashResObjective 
							BEGIN
								SET @CashResSavCAFR = ROUND(@CAFRAmtLeft * @CAFRP3Reserve, 2)
								SET @CAFRAmtLeft = @CAFRAmtLeft - (ROUND(@CAFRAmtLeft * @CAFRP3Reserve, 2))
							END
						ELSE
							BEGIN
								IF (@CashResBal + @CashResSav) >= @CashResObjective -- Use CashResSav to complete Cash Reserves
									BEGIN
										SET @ExtraCAFR = @ExtraCAFR + @CashResSav
										SET @CAFRAmtLeft = @CAFRAmtLeft + @CashResSav - (@CashResObjective - @CashResBal)
										SET @CAFRAdjust = @CAFRAdjust + @CashResSav - (@CashResObjective - @CashResBal)
										SET @CashResSav = @CashResObjective - @CashResBal
									END
								ELSE -- Use CAFR to complete Cash Reserves
									BEGIN
										SET @ExtraCAFR = @ExtraCAFR + @CashResSav
										SET @CashResSavCAFR = @CashResObjective - @CashResBal - @CashResSav
										SET @CAFRAmtLeft = @CAFRAmtLeft - @CashResSavCAFR
									END
							END

						SET @CashResCloseBal = @CashResBal + @CashResSav + @CashResSavCAFR
					END

				-- Debt Reduction
				SET @DebtCAFR = ROUND(@CAFRPhase * @CAFRP3Debt, 2) 
				SET @CAFRAmtLeft = @CAFRAmtLeft - @DebtCAFR
				SET @DebtTotalBalance = 0

				--Loop through ##ttmpClientDebt using CAFR to repay where can and create records in ttmpClientDebtCAFR
				Set @intDebtRow = 1
				WHILE @intDebtRow <= @intDebtRowMax
					BEGIN
						SELECT @LiabilityType = LiabilityType, @YrsFixed = YrsFixed, @YrsIntOnly = YrsIntOnly, 
							@IntOnlyCeaseDte = IntOnlyCeaseDte, @IntOnlyCAFRAdjust = IntOnlyCAFRAdjust,
							@InterestRate = InterestRate, @CurrentBalance = CurrentBalance, 
							@CurrentBalanceCurrent = CurrentBalanceCurrent, @MthlyPaymentImp = MthlyPaymentImp,
							@MthlyPayment = MthlyPayment
						FROM  Reporting.ClientDebt
						WHERE Counter = @intDebtRow AND PlanRevisionId = @PlanRevisionId

						SET @DebtCAFRPayment = 0
						SET @DebtCAFRPaymentMort = 0
						SET @DebtCAFRPaymentConsumer = 0

						SET @InterestAmt = ROUND(@CurrentBalance * @InterestRate / 12, 2)
						IF DATEADD(m, @intCurMth, @RevisionDate) > ISNULL(@IntOnlyCeaseDte, @RevisionDate)
							BEGIN
								SET @Principal = @MthlyPaymentImp - @InterestAmt
								IF @IntOnlyCAFRAdjust = 0  AND @YrsIntOnly > 0
									BEGIN -- Adjust CAFR for extra loan payment amt
										SET @ExtraCAFR = @ExtraCAFR - @Principal
										SET @CAFRAdjust = @CAFRAdjust - @Principal
										SET @CAFRAmtLeft = @CAFRAmtLeft - @Principal
										SET @IntOnlyCAFRAdjust = 1
									END
							END
						ELSE -- Interest only period
							BEGIN
								SET @Principal = @MthlyPaymentIntOnly - @InterestAmt
								IF @CurrentBalance = 0
									SET @Principal = 0
							END

						IF @CurrentBalance > 0
							BEGIN
								IF @Principal >= @CurrentBalance -- Repay all from principal
									BEGIN
										SET @DebtCAFR = @DebtCAFR + (@Principal - @CurrentBalance)
										SET @CAFRDebtAdjust = @CAFRDebtAdjust + (@Principal - @CurrentBalance)
										SET @Principal = @CurrentBalance
										SET @DebtMortExtraCAFRNew = @DebtMortExtraCAFRNew + @MthlyPaymentImp
									END
								ELSE
									IF @CurrentBalance > (@Principal + @DebtCAFR) -- Use all DebtCAFR
										BEGIN
											SET @DebtCAFRPayment = @DebtCAFR
											SET @DebtCAFR = 0
										END
									ELSE -- Repay with DebtCAFR
										BEGIN
											SET @DebtCAFRPayment = @CurrentBalance - @Principal
											SET @DebtCAFR = @DebtCAFR - @DebtCAFRPayment
											IF DATEADD(m, @intCurMth, @RevisionDate) > ISNULL(@IntOnlyCeaseDte, @RevisionDate)
												SET @DebtExtraCAFRNew = @DebtExtraCAFRNew + @MthlyPaymentImp
											ELSE
												SET @DebtExtraCAFRNew = @DebtExtraCAFRNew + @MthlyPaymentIntOnly
										END
							END
						ELSE
							SET @Principal = 0

						SET @DebtCAFRPaymentMort = @DebtCAFRPayment

						SET @InterestAmtCurrent = ROUND(@CurrentBalanceCurrent * @InterestRate / 12, 2)
						IF DATEADD(m, @intCurMth, @RevisionDate) <= ISNULL(@IntOnlyCeaseDte, @RevisionDate)
							SET @MthlyPayment = @MthlyPaymentIntOnly -- Interest only period
						IF @CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent) < 0
							SET @MthlyPayment = (@CurrentBalanceCurrent + @InterestAmtCurrent)

						INSERT INTO Reporting.ClientDebtCafr (PlanRevisionId, ClientDebtIDNo, CAFRMth, LiabilityType, DebtOpenBal, 
							DebtMinPayment, DebtCAFRPayment, DebtCAFRPaymtMort, DebtCAFRPaymtConsumer, DebtPrincipal, 
							DebtInterest, DebtCloseBal, DebtInterestCurrent, DebtCloseBalCurrent)
						SELECT @PlanRevisionId, @intDebtRow, @intCurMth, @LiabilityType, @CurrentBalance, @MthlyPaymentImp, @DebtCAFRPayment, 
							@DebtCAFRPaymentMort, @DebtCAFRPaymentConsumer, @Principal, @InterestAmt, 
							@CurrentBalance - @Principal - @DebtCAFRPayment, @InterestAmtCurrent,
							@CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent)

						UPDATE  Reporting.ClientDebt 
						SET CurrentBalance = @CurrentBalance - @Principal - @DebtCAFRPayment,
							CurrentBalanceCurrent = @CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent),
							IntOnlyCAFRAdjust = @IntOnlyCAFRAdjust
						WHERE Counter = @intDebtRow AND PlanRevisionId = @PlanRevisionId

						SET @DebtTotalBalance = @DebtTotalBalance + 
							(@CurrentBalance - @Principal - @DebtCAFRPayment)

						SET @intDebtRow = @intDebtRow + 1
					END
				
				SET @DebtExtraCAFR = @DebtExtraCAFR + @DebtMortExtraCAFRNew
				SET @CAFRAmtLeft = @CAFRAmtLeft + @DebtCAFR -- added to Investment accounts when last loan repaid
				IF @DebtTotalBalance = 0 SET @DebtMortRepaid = 1

				-- Balance left CAFR to Investment accounts
				--Loop through ##ttmpClientInvest using CAFR to invest where can and create records in ttmpClientInvestCAFR
				SET @intInvestRow = 1
				WHILE @intInvestRow <= @intInvestRowMax
					BEGIN
						SELECT @InterestRate = InterestRate, @CurrentBalance = MarketValue, @MthlyPaymentImp = ContributionsImp,
							@CurrentBalanceCurrent = MarketValueCurrent, @MthlyPayment = Contributions
						FROM  Reporting.ClientInvest
						WHERE Counter = @intInvestRow AND PlanRevisionId = @PlanRevisionId

						SET @InterestAmt = ROUND(@CurrentBalance * @InvestIntRate / 12, 2)
						SET @InterestAmtCurrent = ROUND(@CurrentBalanceCurrent * @InvestIntRate / 12, 2)

						INSERT INTO Reporting.ClientInvestCafr (PlanRevisionId, ClientInvestIDNo, CAFRMth, InvestOpenBal, InvestInterest, 
							InvestCont, InvestCAFRCont, InvestCloseBal, InvestCloseBalCurrent)
						SELECT @PlanRevisionId, @intInvestRow, @intCurMth, @CurrentBalance, @InterestAmt, @MthlyPaymentImp, @CAFRAmtLeft, 
							@CurrentBalance + @InterestAmt + @MthlyPaymentImp + @CAFRAmtLeft,
							@CurrentBalanceCurrent + @InterestAmtCurrent + @MthlyPayment

						UPDATE  Reporting.ClientInvest 
						SET MarketValue = @CurrentBalance + @InterestAmt + @MthlyPaymentImp + @CAFRAmtLeft,
							MarketValueCurrent = @CurrentBalanceCurrent + @InterestAmtCurrent + @MthlyPayment
						WHERE Counter = @intInvestRow AND PlanRevisionId = @PlanRevisionId

						IF @CAFRAmtLeft <> 0 
							BEGIN
								SET @InvestCAFRCont = @CAFRAmtLeft
								SET @CAFRAmtLeft = 0
							END
						SET @intInvestRow = @intInvestRow + 1
					END
			END

-- Phase 4
		IF (@Phase2 = 0) and (@Phase3 = 0) 
			BEGIN
				-- Cash Reserves
				SET @CAFRAmtLeft = @CAFRAmtLeft + @DebtExtraCAFR -- What is available at start of phase
				IF @CashResBal < @CashResObjective
					BEGIN
						IF (@CashResBal + @CashResSav + ROUND(@CAFRAmtLeft * @CAFRP4Reserve, 2)) < @CashResObjective 
							BEGIN
								SET @CashResSavCAFR = ROUND(@CAFRAmtLeft * @CAFRP4Reserve, 2)
								SET @CAFRAmtLeft = @CAFRAmtLeft - (ROUND(@CAFRAmtLeft * @CAFRP4Reserve, 2))
							END
						ELSE
							BEGIN
								IF (@CashResBal + @CashResSav) >= @CashResObjective -- Use CashResSav to complete Cash Reserves
									BEGIN
										SET @ExtraCAFR = @ExtraCAFR + @CashResSav
										SET @CAFRAmtLeft = @CAFRAmtLeft + @CashResSav - (@CashResObjective - @CashResBal)
										SET @CashResSav = @CashResObjective - @CashResBal
									END
								ELSE -- Use CAFR to complete Cash Reserves
									BEGIN
										SET @ExtraCAFR = @ExtraCAFR + @CashResSav
										SET @CashResSavCAFR = @CashResObjective - @CashResBal - @CashResSav
										SET @CAFRAmtLeft = @CAFRAmtLeft - @CashResSavCAFR
									END
							END
						SET @CashResCloseBal = @CashResBal + @CashResSav + @CashResSavCAFR
					END

				-- Balance left CAFR to Investment accounts
				--Loop through ##ttmpClientInvest using CAFR to invest where can and create records in ttmpClientInvestCAFR
				SET @intInvestRow = 1
				WHILE @intInvestRow <= @intInvestRowMax
					BEGIN
						SELECT @InterestRate = InterestRate, @CurrentBalance = MarketValue, @MthlyPaymentImp = ContributionsImp,
							@CurrentBalanceCurrent = MarketValueCurrent, @MthlyPayment = Contributions
						FROM  Reporting.ClientInvest
						WHERE Counter = @intInvestRow AND PlanRevisionId = @PlanRevisionId

						SET @InterestAmt = ROUND(@CurrentBalance * @InvestIntRate / 12, 2)
						SET @InterestAmtCurrent = ROUND(@CurrentBalanceCurrent * @InvestIntRate / 12, 2)

						INSERT INTO Reporting.ClientInvestCafr (PlanRevisionId, ClientInvestIDNo, CAFRMth, InvestOpenBal, InvestInterest, 
							InvestCont, InvestCAFRCont, InvestCloseBal, InvestCloseBalCurrent)
						SELECT @PlanRevisionId, @intInvestRow, @intCurMth, @CurrentBalance, @InterestAmt, @MthlyPaymentImp, @CAFRAmtLeft, 
							@CurrentBalance + @InterestAmt + @MthlyPaymentImp + @CAFRAmtLeft,
							@CurrentBalanceCurrent + @InterestAmtCurrent + @MthlyPayment

						UPDATE  Reporting.ClientInvest 
						SET MarketValue = @CurrentBalance + @InterestAmt + @MthlyPaymentImp + @CAFRAmtLeft,
							MarketValueCurrent = @CurrentBalanceCurrent + @InterestAmtCurrent + @MthlyPayment
						WHERE Counter = @intInvestRow AND PlanRevisionId = @PlanRevisionId

						IF @CAFRAmtLeft <> 0 
							BEGIN
								SET @InvestCAFRCont = @CAFRAmtLeft
								SET @CAFRAmtLeft = 0
							END
						SET @intInvestRow = @intInvestRow + 1
					END

				-- Debt Reduction (Current loan situation calculations)
				--Loop through ##ttmpClientDebt and create records in ttmpClientDebtCAFR
				Set @intDebtRow = 1
				WHILE @intDebtRow <= @intDebtRowMax
					BEGIN
						SELECT @LiabilityType = LiabilityType, @YrsIntOnly = YrsIntOnly, 
							@IntOnlyCeaseDte = IntOnlyCeaseDte, @InterestRate = InterestRate, 
							@CurrentBalanceCurrent = CurrentBalanceCurrent, @MthlyPayment = MthlyPayment
						FROM  Reporting.ClientDebt
						WHERE Counter = @intDebtRow AND PlanRevisionId = @PlanRevisionId

						IF @CurrentBalanceCurrent > 0
							BEGIN
								SET @InterestAmtCurrent = ROUND(@CurrentBalanceCurrent * @InterestRate / 12, 2)
								IF DATEADD(m, @intCurMth, @RevisionDate) <= ISNULL(@IntOnlyCeaseDte, @RevisionDate)
									SET @MthlyPayment = @MthlyPaymentIntOnly -- Interest only period
								IF @CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent) < 0
									SET @MthlyPayment = (@CurrentBalanceCurrent + @InterestAmtCurrent)

								INSERT INTO Reporting.ClientDebtCafr (PlanRevisionId, ClientDebtIDNo, CAFRMth, LiabilityType, DebtOpenBal, 
									DebtMinPayment, DebtCAFRPayment, DebtCAFRPaymtMort, DebtCAFRPaymtConsumer, 
									DebtPrincipal, DebtInterest, DebtCloseBal, DebtInterestCurrent, DebtCloseBalCurrent)
								SELECT @PlanRevisionId, @intDebtRow, @intCurMth, @LiabilityType, 0, 0, 0, 0, 0, 0, 0, 0, @InterestAmtCurrent,
									@CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent)

								UPDATE  Reporting.ClientDebt 
								SET CurrentBalanceCurrent = @CurrentBalanceCurrent - (@MthlyPayment - @InterestAmtCurrent)
								WHERE Counter = @intDebtRow AND PlanRevisionId = @PlanRevisionId
							END

						SET @intDebtRow = @intDebtRow + 1
					END
			END

-- Create summary records
		SELECT @InvestOpenBal = ISNULL(SUM(InvestOpenBal), 0), @InvestInterest = ISNULL(SUM(InvestInterest), 0), @InvestCont = ISNULL(SUM(InvestCont), 0), 
			@InvestCAFRCont = ISNULL(SUM(InvestCAFRCont), 0), @InvestCloseBal = ISNULL(SUM(InvestCloseBal), 0), 
			@InvestCloseBalCurrent = ISNULL(SUM(InvestCloseBalCurrent), 0)
		FROM Reporting.ClientInvestCafr
		WHERE PlanRevisionId = @PlanRevisionId
		GROUP BY CAFRMth
		HAVING CAFRMth = @intCurMth

		SELECT @DebtOpenBal = ISNULL(SUM(DebtOpenBal), 0), @DebtMinPayment = ISNULL(SUM(DebtMinPayment), 0), @DebtCAFRPayment = ISNULL(SUM(DebtCAFRPayment), 0), 
			@DebtCAFRPaymentMort = ISNULL(SUM(DebtCAFRPaymtMort), 0), @DebtCAFRPaymentConsumer = ISNULL(SUM(DebtCAFRPaymtConsumer), 0),
			@DebtPrincipal = ISNULL(SUM(DebtPrincipal), 0), @DebtInterest = ISNULL(SUM(DebtInterest), 0), 
			@DebtInterestMort = ISNULL(SUM(CASE WHEN LiabilityType = 'Property' THEN DebtInterest ELSE 0 END), 0),
			@DebtInterestConsumer = ISNULL(SUM(CASE WHEN LiabilityType <> 'Property' THEN DebtInterest ELSE 0 END), 0),
			@DebtCloseBal = ISNULL(SUM(DebtCloseBal), 0), @DebtInterestCurrent = ISNULL(SUM(DebtInterestCurrent), 0), 
			@DebtCloseBalMort = ISNULL(SUM(CASE WHEN LiabilityType = 'Property' THEN DebtCloseBal ELSE 0 END), 0),
			@DebtCloseBalConsumer = ISNULL(SUM(CASE WHEN LiabilityType <> 'Property' THEN DebtCloseBal ELSE 0 END), 0),
			@DebtInterestMortCurrent = ISNULL(SUM(CASE WHEN LiabilityType = 'Property' THEN DebtInterestCurrent ELSE 0 END), 0),
			@DebtInterestConsumerCurrent = ISNULL(SUM(CASE WHEN LiabilityType <> 'Property' THEN DebtInterestCurrent ELSE 0 END), 0),
			@DebtCloseBalCurrent = ISNULL(SUM(DebtCloseBalCurrent), 0),
			@DebtCloseBalMortCurrent = ISNULL(SUM(CASE WHEN LiabilityType = 'Property' THEN DebtCloseBalCurrent ELSE 0 END), 0),
			@DebtCloseBalConsumerCurrent = ISNULL(SUM(CASE WHEN LiabilityType <> 'Property' THEN DebtCloseBalCurrent ELSE 0 END), 0)
		FROM Reporting.ClientDebtCafr
		WHERE PlanRevisionId = @PlanRevisionId
		GROUP BY CAFRMth
		HAVING CAFRMth = @intCurMth

		INSERT INTO Reporting.CafrCalculation (PlanRevisionId, CAFRMth, CAFR, EmergOpenBal, EmergBudgetCont, EmergCAFRCont, EmergCloseBal, EmergCloseBalCurrent, 
			CashResOpenBal, CashResBudgetCont, CashResCAFRCont, CashResCloseBal, CashResCloseBalCurrent, DebtOpenBal, DebtMinPayment, 
			DebtCAFRCont, DebtCAFRContMort, DebtCAFRContConsumer, DebtPrincipal, DebtInterest, DebtInterestMort, DebtInterestConsumer, DebtCloseBal, 
			DebtCloseBalMort, DebtCloseBalConsumer, DebtInterestCurrent, DebtInterestMortCurrent, DebtInterestConsumerCurrent, DebtCloseBalCurrent, 
			DebtCloseBalMortCurrent, DebtCloseBalConsumerCurrent, InvestOpenBal, InvestInterest, InvestCont, 
			InvestCAFRCont, InvestCloseBal, InvestCloseBalCurrent, RealEstateValue, AutoValue, PersonalPropValue, ExtraCAFR, DebtExtraCAFRPrev, 
			DebtExtraCAFR, CAFRAmtLeft)
		SELECT @PlanRevisionId, @intCurMth, @CAFR + @CAFRAdjust, @EmergBal, @EmergSav, @EmergSavCAFR, @EmergBal + @EmergSav + @EmergSavCAFR, 
			@EmergBalCurrent, @CashResBal, @CashResSav, @CashResSavCAFR, @CashResCloseBal, @CashResBalCurrent, @DebtOpenBal, 
			@DebtMinPayment, @DebtCAFRPayment, @DebtCAFRPaymentMort,
			@DebtCAFRPaymentConsumer, @DebtPrincipal, @DebtInterest, @DebtInterestMort, @DebtInterestConsumer, @DebtCloseBal, @DebtCloseBalMort, 
			@DebtCloseBalConsumer, @DebtInterestCurrent, @DebtInterestMortCurrent, @DebtInterestConsumerCurrent, @DebtCloseBalCurrent, 
			@DebtCloseBalMortCurrent, @DebtCloseBalConsumerCurrent, @InvestOpenBal, @InvestInterest, @InvestCont, 
			@InvestCAFRCont, @InvestCloseBal, @InvestCloseBalCurrent, @RealEstateValue, @AutoValue, @PersonalPropValue, @ExtraCAFR, 
			@DebtExtraCAFRPrev + @CAFRDebtAdjust, @DebtExtraCAFR, @CAFRAmtLeft  

		SET @intCurMth = @intCurMth + 1
		SET @EmergBal = @EmergBal + @EmergSav + @EmergSavCAFR
		SET @CashResBal = @CashResCloseBal
		IF @EmergBal >= @EmergObjective AND @EmergSav <> 0 
			SET @EmergSav = 0
		IF @CashResBal >= @CashResObjective AND @CashResSav <> 0 
			SET @CashResSav = 0
		SET @CAFR = @CAFR + @ExtraCAFR
		SET @DebtExtraCAFRPrev = @DebtExtraCAFR

	END

	--HACK: Need to return something for NH so it can feel it saved the world
	SELECT * FROM [Reporting].[vPlanRevision] WHERE PlanRevisionId = @PlanRevisionId

GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptInvestRetirement]')) 
	DROP PROCEDURE [Reporting].[sprptInvestRetirement]
GO
CREATE PROCEDURE [Reporting].[sprptInvestRetirement]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 

	DECLARE @CPreRetireRate [Rate], @SPreRetireRate [Rate], @AvgPreRetireRate [Rate], @CRetireAge int, @ClientAge int
	SELECT @CPreRetireRate = RT.PrimaryPreRetirementReturnRate, @SPreRetireRate = 0,  @CRetireAge = FG.PrimaryRetirementAge,
		@ClientAge = FLOOR(DATEDIFF(day, C.BirthDate, getDate()) / 365.25)
	FROM  [Reporting].[vPlanRevision] PR
		JOIN Consumer.PrimaryConsumer C
			ON PR.PlanId = C.PrimaryConsumerId
		LEFT JOIN Consumer.SecondaryConsumer S
			ON PR.PlanRevisionId = S.BaselineId
		LEFT JOIN Consumer.FinancialPlan FG
			ON PR.PlanRevisionId = FG.BaselineId
		LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] RT 
			ON PR.PlanRevisionId = RT.BaselineId
	WHERE PR.PlanRevisionId = @PlanRevisionId

	DECLARE @FutValueCurrent [Currency], @FutValue [Currency]
	SELECT @FutValueCurrent = 0, @FutValue = 0
	SELECT @FutValueCurrent = ISNULL(InvestCloseBalCurrent, 0), @FutValue = ISNULL(InvestCloseBal, 0)
	FROM Reporting.CafrCalculation
	WHERE PlanRevisionId = @PlanRevisionId AND CAFRMth = ((@CRetireAge - @ClientAge) * 12)

	SELECT @AvgPreRetireRate = CASE WHEN @SPreRetireRate <> 0 THEN ROUND((@CPreRetireRate + @SPreRetireRate) / 2, 2) ELSE @CPreRetireRate END
	 
	SELECT Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'TxInv') AS TaxDef, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'NTxInv') + Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OtherInv') AS NonTxDef, 
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'TxSavFull') + [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'TxSavEmp') AS TaxDeferSav, 
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'NTxSav') +
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'CollSav') + [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'XmasSav') + 
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'VacSav') AS NonTaxDeferSav, 
		@AvgPreRetireRate AS AvgPreRetireRate, @CRetireAge AS CRetireAge, @ClientAge AS ClientAge, 
		@FutValueCurrent AS FutValueCurrent, @FutValue AS FutValue, @PlanRevisionId AS ClientRevisionID

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptCurrentCornerstone]')) 
	DROP PROCEDURE [Reporting].[sprptCurrentCornerstone]
GO
CREATE PROCEDURE [Reporting].[sprptCurrentCornerstone]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 

	DECLARE @DebtFreeMth integer

	SELECT @DebtFreeMth = ISNULL(FIRST_MONTH.Mon, MONTHS.TotalCafrMonths)
	FROM (
			SELECT TotalCafrMonths = COUNT(*) 
			FROM Reporting.CafrCalculation
			WHERE PlanRevisionId = @PlanRevisionId
		) MONTHS
		CROSS JOIN (
			SELECT Mon = MIN(CAFRMth) 
			FROM Reporting.CafrCalculation
			WHERE PlanRevisionId = @PlanRevisionId
				AND DebtCloseBalConsumer = 0
		) FIRST_MONTH
	 
	SELECT Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'EmergInv') AS EmergBal, 
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'EmergSav') AS EmergSav,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'CashInv') AS CashBal, 
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'CashSav') AS CashSav,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureCl') AS ClientInsBal,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureSp') AS SpouseInsBal,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InsureJt') AS JointInsBal,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'AutoLoan') + Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'CreditCard') +  
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OtherLoan') AS CurrDebtBal,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'PrimResMort') AS PrimResMortBal, Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'SecResMort') + 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'InvestPropMort') + Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OthPropMort') AS OthPropMortBal, 
		FLOOR(ISNULL(@DebtFreeMth, 1)/12) AS DebtFreeYear,
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'TxInv') AS TaxDefBal, 
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'TxSavFull') + [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'TxSavEmp') AS 'TaxDeferSav', 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'NTxInv') + Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'OtherInv') AS NonTxDefBal, 
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'NTxSav') + [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'CollSav') +
		[Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'XmasSav') + [Reporting].[GetBudgetAssetAmt](@PlanRevisionId, 'VacSav') AS 'NonTaxDeferSav',
		FLOOR(DATEDIFF(day, C.BirthDate, getDate()) / 365.25) ClientAge, 
		ISNULL([Reporting].GetTotalNetIncome(@PlanRevisionId, 1), 0) NetIncome
	FROM
		[Reporting].[vPlanRevision] PR
		JOIN Consumer.PrimaryConsumer C
			ON PR.PlanId = C.PrimaryConsumerId
	WHERE PR.PlanRevisionid = @PlanRevisionId

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptEmergeCashResBalance]')) 
	DROP PROCEDURE [Reporting].[sprptEmergeCashResBalance]
GO
CREATE PROCEDURE [Reporting].[sprptEmergeCashResBalance]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT @PlanRevisionId AS ClientRevisionID, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'CashInv') AS CashInv, 
		Reporting.fnGetCurrentBalanceAmt(@PlanRevisionId, 'EmergInv') AS EmergInv, 
		ISNULL([Reporting].GetTotalNetIncome(@PlanRevisionId, 1), 0) NetIncome,
		[Reporting].[GetCashReserveDeposit](@PlanRevisionId) CashResDeposit, ISNULL(RT.DepositToEmergencyFund, 0) EmergencyFundDeposit,
		ISNULL(RT.RecommendedCashReserve, 0) CashReserveBalance, ISNULL(RT.RecommendedEmergencyFund, 0) EmergencyFundBalance
	FROM
		[Reporting].[vPlanRevision] PR
		LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] RT ON PR.PlanRevisionId = RT.BaselineId
	WHERE PR.PlanRevisionid = @PlanRevisionId

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptEmergeCashResBalanceGraph]')) 
	DROP PROCEDURE [Reporting].[sprptEmergeCashResBalanceGraph]
GO
CREATE PROCEDURE [Reporting].[sprptEmergeCashResBalanceGraph]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 

	DECLARE @CashResObjective money, @EmergObjective money
	 
	SELECT @CashResObjective = RT.RecommendedCashReserve, @EmergObjective = RT.RecommendedEmergencyFund
	FROM [Reporting].[vRecommendedRestructureAndTargets] RT 
	WHERE RT.BaselineId = @PlanRevisionId

	SELECT CC.CAFRMth, CC.CashResCloseBalCurrent + CC.EmergCloseBalCurrent AS [Cash Reserve Balance Current Plan], @CashResObjective + @EmergObjective AS [Cash Reserve Recommended Balance], 
		@EmergObjective AS [Emergency Fund], CC.CashResCloseBal + CC.EmergCloseBal AS [Cash Reserve Balance with MOP] 
	FROM 
		Reporting.CafrCalculation CC
	WHERE CC.PlanRevisionId = @PlanRevisionId AND CC.CAFRMth <= 48 --AND CC.CashResCloseBal + CC.EmergCloseBal <= @CashResObjective + @EmergObjective
	ORDER BY CC.CAFRMth

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientInsurance]')) 
	DROP PROCEDURE [Reporting].[spsfrClientInsurance]
GO
CREATE PROCEDURE [Reporting].[spsfrClientInsurance]
	(
		@PlanRevisionId int,
		@Mode bit = 0 --0 for all types, 1 for just true asset types
	)
AS 
	SET NOCOUNT ON 

	SELECT 
		A.AssetId ClientAssetID, A.PlanRevisionId ClientRevisionIDNo, A.AssetTypeName AssetType, A.OwnerTypeName Owner, A.Description, BEN.Name Description2, A.Account AccountNo, I.Comments Comment, 0 SortOrder, A.MarketValue, A.Rate InterestRate,
		IT.Name InsuranceType, I.CoverageAmount InsCover, RI.RevisedCoverageAmount InsCoverImp, I.AnnualPremium Contributions, RI.RevisedAnnualPremium ContributionsImp, I.YearExpiry InsPolicyExpireDate	
	FROM 
		[Reporting].[vAsset] A 
		JOIN Consumer.AssetProtection I ON A.AssetId = I.AssetProtectionId
		LEFT JOIN [Plan].RevisedAssetProtection RI ON I.AssetProtectionId = RI.AssetProtectionId
		JOIN Code.LookupItem IT ON I.InsuranceTypeCode = IT.Code
		LEFT JOIN Code.LookupItem BEN ON I.PrimaryBeneficiaryCode = BEN.Code
	WHERE 
		A.PlanRevisionId = @PlanRevisionId
		AND A.AssetTypeCode = 'AT-I'
		AND (A.AssetSubTypeCode NOT IN ('AT-I-TL', 'AT-I-GL') OR @Mode = 0)
	--ORDER BY A.SortOrder
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientInvestment]')) 
	DROP PROCEDURE [Reporting].[spsfrClientInvestment]
GO
CREATE PROCEDURE [Reporting].[spsfrClientInvestment]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	SELECT 
		A.AssetId ClientAssetID, A.PlanRevisionId ClientRevisionIDNo, A.AssetTypeName AssetType, A.OwnerTypeName Owner, A.Description, A.Account Description2, '' AccountNo, '' Comment, 0 SortOrder, A.MarketValue, A.Rate InterestRate,
		ISNULL(IT.Name, A.AssetTypeName) InvestmentType, A.CurrentContributions Contributions, A.ImprovedContributions ContributionsImp	
	FROM 
		[Reporting].[vAsset] A 
		LEFT JOIN Code.LookupItem IT ON A.ActualAssetSubTypeCode = IT.Code
	WHERE A.PlanRevisionId = @PlanRevisionId 
		AND A.AssetTypeCode = 'AT-V'
	--ORDER BY A.SortOrder
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientOtherAsset]')) 
	DROP PROCEDURE [Reporting].[spsfrClientOtherAsset]
GO
CREATE PROCEDURE [Reporting].[spsfrClientOtherAsset]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT 
		A.AssetId ClientAssetID, A.PlanRevisionId ClientRevisionIDNo, A.AssetTypeName AssetType, A.OwnerTypeName Owner, A.Description, A.Account Description2, '' AccountNo, '' Comment, 0 SortOrder, A.MarketValue, A.Rate InterestRate
	FROM 
		[Reporting].[vAsset] A 
	WHERE A.PlanRevisionId = @PlanRevisionId  AND A.AssetTypeCode IN ('AT-A', 'AT-O')
	--ORDER BY A.SortOrder
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientOtherLiability]')) 
	DROP PROCEDURE [Reporting].[spsfrClientOtherLiability]
GO
CREATE PROCEDURE [Reporting].[spsfrClientOtherLiability]
	(
		@PlanRevisionId int
		
	)
AS
	SET NOCOUNT ON 
	 
	SELECT 
		L.LiabilityId ClientLiabilityID, L.PlanRevisionId ClientRevisionIDNo, 'Other' LiabilityType, L.LiabilityTypeName LiabilityType2, L.AssetId ClientAssetIDNo, 
		L.Description LiabilityDescription, L.OwnerTypeName Owner, L. CreditorName, L.FixedYears YrsFixed, L.InterestOnlyYears YrsIntOnly, L.InterestOnlyCeaseDate IntOnlyCeaseDte, 
		L.InterestRate, L.CurrentBalance, L.ImprovedBalance CurrentBalanceImp, L.CurrentPayment MthlyPayment, L.ImprovedPayment MthlyPaymentImp, '' Comment, 0 SortOrder
	FROM 
		[Reporting].[vLiability] L 
	WHERE L.PlanRevisionId = @PlanRevisionId  AND L.LiabilityTypeCode = 'LT-OT'
	--ORDER BY L.SortOrder
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientRealEstate]')) 
	DROP PROCEDURE [Reporting].[spsfrClientRealEstate]
GO
CREATE PROCEDURE [Reporting].[spsfrClientRealEstate]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT 
		A.AssetId ClientAssetID, A.PlanRevisionId ClientRevisionIDNo, A.AssetTypeName AssetType, A.OwnerTypeName Owner, A.Description, A.Account Description2, '' AccountNo, '' Comment, 0 SortOrder, A.MarketValue, A.Rate InterestRate,
		RET.Name PropertyType, RE.GrossRentalIncome Contributions, RE.PropertyExpenses PropertyExpenses, [Reporting].fnGetRealEstateBalance(A.AssetId, 'Balance') AS MortgageBal, 
		[Reporting].fnGetRealEstateBalance(A.AssetId, 'Payment') AS MortgagePay
	FROM 
		[Reporting].[vAsset] A 
		JOIN Consumer.RealEstateAsset RE ON A.AssetId = RE.RealEstateAssetId
		INNER JOIN Code.LookupItem RET ON A.ActualAssetSubTypeCode = RET.Code
	WHERE A.PlanRevisionId = @PlanRevisionId 
		AND A.AssetTypeCode = 'AT-P'
	--ORDER BY A.SortOrder
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientRealLiability]')) 
	DROP PROCEDURE [Reporting].[spsfrClientRealLiability]
GO
CREATE PROCEDURE [Reporting].[spsfrClientRealLiability]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT 
		L.LiabilityId ClientLiabilityID, L.PlanRevisionId ClientRevisionIDNo, 'Property' LiabilityType, L.LiabilityTypeName LiabilityType2, L.AssetId ClientAssetIDNo, 
		L.Description LiabilityDescription, L.OwnerTypeName Owner, L. CreditorName, L.FixedYears YrsFixed, L.InterestOnlyYears YrsIntOnly, L.InterestOnlyCeaseDate IntOnlyCeaseDte, 
		L.InterestRate, L.CurrentBalance, L.ImprovedBalance CurrentBalanceImp, L.CurrentPayment MthlyPayment, L.ImprovedPayment MthlyPaymentImp, '' Comment, 0 SortOrder
	FROM 
		[Reporting].[vLiability] L 
	WHERE L.PlanRevisionId = @PlanRevisionId  AND L.LiabilityTypeCode = 'LT-RE'
	--ORDER BY L.SortOrder
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientIncome]')) 
	DROP PROCEDURE [Reporting].[spsfrClientIncome]
GO
CREATE PROCEDURE [Reporting].[spsfrClientIncome]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT 
		I.IncomeId ClientIncomeID, I.PlanRevisionId ClientRevisionIDNo, I.IsPaycheck PayCheck, OwnerTypeName Owner, I.Source Description, 
		I.GrossMonthlyAmount Amount, 0 YrGrowthRate, 0 StartMonth, 0 EndMonth, '' Comment, 0 SortOrder
	FROM [Reporting].[vIncome] I
	WHERE I.PlanRevisionId = @PlanRevisionId 
	ORDER BY I.IsPaycheck DESC, I.OwnerTypeCode
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientGoal]')) 
	DROP PROCEDURE [Reporting].[spsfrClientGoal]
GO
CREATE PROCEDURE [Reporting].[spsfrClientGoal]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 

	SELECT G.FinancialGoalId ClientGoalID, G.BaselineId ClientRevisionIDNo, OT.Name Owner, '' Type, G.Goal Description, G.Priority SortOrder
	FROM 
		[Reporting].[vPlanRevision] PR
		LEFT JOIN [Consumer].FinancialGoal G ON PR.PlanRevisionId = G.BaselineId
		LEFT JOIN Code.LookupItem OT ON G.OwnerCode = OT.Code 
	WHERE PR.PlanRevisionId = @PlanRevisionId 
	ORDER BY G.[Priority], OT.Name
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientRefinance]')) 
	DROP PROCEDURE [Reporting].[spsfrClientRefinance]
GO
CREATE PROCEDURE [Reporting].[spsfrClientRefinance]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 

	SELECT 
		L.LiabilityId ClientLiabilityID, L.PlanRevisionId ClientRevisionIDNo, CASE LiabilityTypeCode WHEN 'LT-RE' THEN 'Property' ELSE 'Other' END LiabilityType, 
		L.LiabilityTypeName LiabilityType2, L.AssetId ClientAssetIDNo, 
		L.Description LiabilityDescription, L.OwnerTypeName Owner, L. CreditorName, L.FixedYears YrsFixed, L.InterestOnlyYears YrsIntOnly, L.InterestOnlyCeaseDate IntOnlyCeaseDte, 
		L.InterestRate, L.CurrentBalance, L.ImprovedBalance CurrentBalanceImp, L.CurrentPayment MthlyPayment, L.ImprovedPayment MthlyPaymentImp, '' Comment, 0 SortOrder
	FROM 
		[Reporting].[vLiability] L 
	WHERE L.PlanRevisionId = @PlanRevisionId
	ORDER BY L.CurrentBalance
	
GO


--TODO: This one depends on the view we cut - does it actually need to be completed - is this proc used anywhere???
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientRevision]')) 
	DROP PROCEDURE [Reporting].[spsfrClientRevision]
GO
CREATE PROCEDURE [Reporting].[spsfrClientRevision]
	(
		@txtClientID int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT PR.*,
		Reporting.fnGetCurrentBalanceAmt(PlanRevisionId, 'InsureClTerm') +  
		Reporting.fnGetCurrentBalanceAmt(PlanRevisionId, 'InsureClGroup') + 
		Reporting.fnGetCurrentBalanceAmt(PlanRevisionId, 'InsureClPerm') + 
		Reporting.fnGetCurrentBalanceAmt(PlanRevisionId, 'InsureClVar') AS CInsureCurrent,
		Reporting.fnGetCurrentBalanceAmt(PlanRevisionId, 'InsureSpTerm') +  
		Reporting.fnGetCurrentBalanceAmt(PlanRevisionId, 'InsureSpGroup') +
		Reporting.fnGetCurrentBalanceAmt(PlanRevisionId, 'InsureSpPerm') +
		Reporting.fnGetCurrentBalanceAmt(PlanRevisionId, 'InsureSpVar') AS SInsureCurrent
	FROM [Reporting].[vPlanRevision] PR
	WHERE PR.PlanId = @txtClientID 
	ORDER BY PR.CreateDate Desc, PR.[Name]
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientRecommend]')) 
	DROP PROCEDURE [Reporting].[spsfrClientRecommend]
GO
CREATE PROCEDURE [Reporting].[spsfrClientRecommend]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 

	SELECT RecommendationId ClientRecommendID, BaselineId ClientRevisionIDNo, RecommendationCategoryCode RecommendCatIDNo, Priority SortOrder, RecommendationDescription Recommendation
	FROM [Plan].Recommendation
	WHERE BaselineId = @PlanRevisionId
	ORDER BY [Priority], RecommendationCategoryCode 
	
GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientBudget]')) 
	DROP PROCEDURE [Reporting].[spsfrClientBudget]
GO
CREATE PROCEDURE [Reporting].[spsfrClientBudget]
	(
		@PlanRevisionId int
	)
AS

	SELECT *, [Reporting].[GetOtherIncomeTotal](@PlanRevisionId) AS TotalOtherIncome
	FROM [Reporting].[vBudgetSummary]
	WHERE PlanRevisionId = @PlanRevisionId 
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[spsfrClientBudgetSummary]')) 
	DROP PROCEDURE [Reporting].[spsfrClientBudgetSummary]
GO
CREATE PROCEDURE [Reporting].[spsfrClientBudgetSummary]
	(
		@PlanRevisionId int
	)
AS

	SELECT 
		NetIncomeTotal = ClientNetIncome + SpouseNetIncome + TotalOtherIncome,
		HomeTotal = HomeSubtotal + FirstMortgage + SecondMortgage + OtherLien, 
		HomeTotalImproved = HomeSubtotalImproved + FirstMortgageImproved + SecondMortgageImproved + OtherLienImproved, 
		HealthTotal = HealthSubtotal + LifeInsurance, 
		HealthTotalImproved = HealthSubtotalImproved + LifeInsuranceImproved, 
		AutoTotal = AutoSubtotal + CarPayment + RVPayment, 
		AutoTotalImproved = AutoSubtotalImproved + CarPaymentImproved + RVPaymentImproved, 
		
		FoodTotal = FoodSubtotal, 
		FoodTotalImproved = FoodSubtotalImproved, 
		GivingTotal = GivingSubtotal, 
		GivingTotalImproved = GivingSubtotalImproved, 
		TextilesTotal = TextilesSubtotal, 
		TextilesTotalImproved = TextilesSubtotalImproved, 
		MiscTotal = MiscSubtotal + OtherTotal, 
		MiscTotalImproved = MiscSubtotalImproved + OtherTotalImproved,

		InvTotal = CashSaving + CollegeSaving + XmasSaving + VacationSaving + 
			TaxDeferSaving + NonTaxDeferSaving,
		InvTotalImproved = CashSavingImproved + CollegeSavingImproved + XmasSavingImproved + VacationSavingImproved + 
			TaxDeferSavingImproved + NonTaxDeferSavingImproved,

		DebtTotal = CreditDebt + OtherDebt,
		DebtTotalImproved = CreditDebtImproved + OtherDebtImproved
	FROM [Reporting].[vBudgetSummary]
	WHERE PlanRevisionId = @PlanRevisionId 
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptTitle]')) 
	DROP PROCEDURE [Reporting].[sprptTitle]
GO
CREATE PROCEDURE [Reporting].[sprptTitle]
	(
		@PlanRevisionId int
	)
AS
	SET NOCOUNT ON 
	 
	SELECT FR.FirstName Rep1stName, FR.LastName RepLastName, FR.OfficePhone, FR.LicenseText,
		PR.PlanRevisionId ClientRevisionID, PR.ReportName, PR.Name RevisionName, PR.CreateDate RevisionDate,
		C.Name CompanyName, C.FullName CompanyFullName, 
		FR.Title,
		StreetAddress = CASE WHEN LEN(FR.PhysicalAddressLine) > 0 THEN FR.PhysicalAddressLine ELSE C.AddressLine END, 
		StreetAddress2 = CASE WHEN LEN(FR.PhysicalAddressLine) > 0 THEN FR.PhysicalAddressLine2 ELSE C.AddressLine2 END, 
		City = CASE WHEN LEN(FR.PhysicalAddressLine) > 0 THEN FR.PhysicalCity ELSE C.PhysicalCity END, 
		[State] = CASE WHEN LEN(FR.PhysicalAddressLine) > 0 THEN FR.PhysicalState ELSE C.PhysicalState END, 
		Zip = CASE WHEN LEN(FR.PhysicalAddressLine) > 0 THEN FR.PhysicalZip ELSE C.PhysicalZip END,
		C.Logo, C.LogoReportOffset, C.BrokerageText
	FROM  [Reporting].[vPlanRevisionWithAdvisor] PR
		JOIN Advisor.FinancialAdvisor FR ON PR.FinancialAdvisorId = FR.FinancialAdvisorId
		JOIN Advisor.Company C ON FR.CompanyId = C.CompanyId
	WHERE PR.PlanRevisionId = @PlanRevisionId 

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptAssumptions]')) 
	DROP PROCEDURE [Reporting].[sprptAssumptions]
GO
CREATE PROCEDURE [Reporting].[sprptAssumptions]
	(
		@PlanRevisionId int
	)
AS

SELECT PR.PlanRevisionId,
	FG.PrimaryRetirementAge CRetireAge, FG.PrimaryRetiredMonthlyExpenses CRetireExp, FG.PrimaryDeathFund CDeathFund, 0 CInflationRate, RT.PrimaryPreRetirementReturnRate CPreRetireRate, RT.PrimaryPreRetirementReturnRate CPostRetireRate, 0 CCurrTaxRate, 0 CRetireTaxRate, 0 CRetireIncome, 0 CRetireIncYrs, 0 CSSAge, 0 CSSMthBenefit, 0 CPension, 0 CPensionYrs, FG.PrimaryCurrentPlanProjection CCurPlanAchieveGoal, FG.PrimaryNewPlanProjection CHappen3Yrs, RT.PrimaryMiscellaneousDebtRate CMiscDebtRate, 
	FG.SecondaryRetirementAge SRetireAge, FG.SecondaryRetiredMonthlyExpenses SRetireExp, FG.SecondaryDeathFund SDeathFund, 0 SInflationRate, 0 SPreRetireRate, 0 SPostRetireRate, 0 SCurrTaxRate, 0 SRetireTaxRate, 0 SRetireIncome, 0 SRetireIncYrs, 0 SSSAge, 0 SSSMthBenefit, 0 SPension, 0 SPensionYrs, FG.SecondaryCurrentPlanProjection SCurPlanAchieveGoal, FG.SecondaryNewPlanProjection SHappen3Yrs, 0 SMiscDebtRate
FROM 
	[Reporting].[vPlanRevision] PR
	JOIN Consumer.PrimaryConsumer C
		ON PR.PlanId = C.PrimaryConsumerId
	LEFT JOIN Consumer.SecondaryConsumer S
		ON PR.PlanRevisionId = S.BaselineId
	LEFT JOIN Consumer.FinancialPlan FG
		ON PR.PlanRevisionId = FG.BaselineId
	LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] RT
		ON PR.PlanRevisionId = RT.BaselineId
WHERE PR.PlanRevisionId = @PlanRevisionId 

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[sprptCAFRDistribution]')) 
	DROP PROCEDURE [Reporting].[sprptCAFRDistribution]
GO
CREATE PROCEDURE [Reporting].[sprptCAFRDistribution] 
	(
		@PlanRevisionId int
	)
AS

	SET NOCOUNT ON;

	DECLARE @IntOnlyLoan int

	SELECT @IntOnlyLoan = SUM(InterestOnlyYears)
	FROM [Reporting].[vLiability]
	WHERE PlanRevisionId = @PlanRevisionId

	SELECT 
		EmergencyFundBalance = RecommendedEmergencyFund, 
		CashReserveBalance = RecommendedCashReserve, 
		CafrPhase2DebtRate = Phase2NonFirstMortgageDebtReduction, 
		CafrPhase2ReserveRate = Phase2CashReservesRate, 
		CAFRP2Invest = 1 - (Phase2NonFirstMortgageDebtReduction + Phase2CashReservesRate), 
		CafrPhase2DebtWithCashRate = Phase2AlternateNonFirstMortgageDebtReduction, 
		CAFRP2Invest2 = 1 - Phase2AlternateNonFirstMortgageDebtReduction, 
		CafrPhase3DebtRate = Phase3FirstMortgageDebtReduction, 
		CafrPhase3ReserveRate = Phase3CashReservesRate, 
		CAFRP3Invest = 1 - (Phase3FirstMortgageDebtReduction + Phase3CashReservesRate), 
		CafrPhase4ReserveRate = Phase4CashReservesRate, 
		CAFRP4Invest = 1 - Phase4CashReservesRate,
		InterestOnlyYearsTotal = @IntOnlyLoan
	FROM [Reporting].[vRecommendedRestructureAndTargets]
	WHERE BaselineId = @PlanRevisionId

	 
GO