
IF SCHEMA_ID('Reporting') IS NULL
	EXEC('CREATE SCHEMA [Reporting]') 
GO


/*HACK: This is just a port over from v1 which was largely a port over from the MS Access DB.
		This report and underlying artifacts need to be deleted and the whole thing started from scratch
*/

PRINT 'Add reporting functions'
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.GetLookupItemName')) 
	DROP FUNCTION [Reporting].[GetLookupItemName]
GO
CREATE FUNCTION [Reporting].[GetLookupItemName]
	( 
		@Code varchar(8)
	) 
	RETURNS varchar(50)
AS 
	BEGIN 

		RETURN(SELECT Name FROM Code.LookupItem WHERE Code = @Code)
	END
GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[fnGetCurrentBalanceAmt]')) 
	DROP FUNCTION [Reporting].[fnGetCurrentBalanceAmt]
GO
CREATE FUNCTION [Reporting].[fnGetCurrentBalanceAmt]
	( 
		@PlanRevisionId int,
		@Type varchar(20) 
	) 
	RETURNS money
AS 
	BEGIN 
		DECLARE @Balance money 

		SET @Balance = 0
		IF @PlanRevisionId IS NOT NULL
			SELECT @Balance = 
				CASE @Type
					WHEN 'PrimRes' THEN		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-P-PH'),0)
					WHEN 'SecRes' THEN		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-P-SH'),0)
					WHEN 'InvestProp' THEN		ISNULL((SELECT SUM(ROUND(A.MarketValue* 0.9,0)) -- 90% of investment value used
									FROM [Reporting].[vAsset] A
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode IN ('AT-P-R', 'AT-P-C')),0)
					WHEN 'OthProp' THEN		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-P-OP'),0)
					WHEN 'AllProp' THEN		ISNULL((SELECT SUM(CASE 	
													WHEN A.AssetSubTypeCode IN ('AT-P-R', 'AT-P-C') THEN ROUND(A.MarketValue* 0.9,0)
													ELSE A.MarketValue END)
									FROM [Reporting].[vAsset] A 
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetTypeCode = 'AT-P'),0)
					
					WHEN 'TxInv' THEN 		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-V-TA'),0)
					WHEN 'NTxInv' THEN 		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-V-NTA'),0)
					WHEN 'CashInv' THEN 		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-V-CR'),0)
					WHEN 'EmergInv' THEN 		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-V-EF'),0)
					WHEN 'OtherInv' THEN 		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode IN ('AT-V-XMS', 'AT-V-VS', 'AT-V-CS')),0)
					
					WHEN 'Insure' THEN 		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetTypeCode = 'AT-I'),0)
					WHEN 'InsureCl' THEN 		ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-CLI' AND A.AssetTypeCode = 'AT-I'),0)
					WHEN 'InsureClTerm' THEN	ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-CLI' AND A.AssetSubTypeCode = 'AT-I-TL'),0)
					WHEN 'InsureClGroup' THEN	ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-CLI' AND A.AssetSubTypeCode = 'AT-I-GL'),0)
					WHEN 'InsureClPerm' THEN	ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-CLI' AND A.AssetSubTypeCode = 'AT-I-PL'),0)
					WHEN 'InsureClVar' THEN	ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-CLI' AND A.AssetSubTypeCode = 'AT-I-VL'),0)
					WHEN 'InsureSp' THEN 		ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-SPO' AND A.AssetTypeCode = 'AT-I'),0)
					WHEN 'InsureSpTerm' THEN	ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-SPO' AND A.AssetSubTypeCode = 'AT-I-TL'),0)
					WHEN 'InsureSpGroup' THEN	ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-SPO' AND A.AssetSubTypeCode = 'AT-I-GL'),0)
					WHEN 'InsureSpPerm' THEN	ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-SPO' AND A.AssetSubTypeCode = 'AT-I-PL'),0)
					WHEN 'InsureSpVar' THEN	ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-SPO' AND A.AssetSubTypeCode = 'AT-I-VL'),0)
					WHEN 'InsureJt' THEN 		ISNULL((SELECT SUM(IA.CoverageAmount)
									FROM [Reporting].[vAsset] A JOIN Consumer.AssetProtection IA ON A.AssetId = IA.AssetProtectionId
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.OwnerTypeCode = 'CO-JNT' AND A.AssetTypeCode = 'AT-I'),0)
					
					WHEN 'Auto' THEN 		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A 
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetTypeCode = 'AT-A'),0)
					WHEN 'OtherAsset' THEN		ISNULL((SELECT SUM(A.MarketValue)
									FROM [Reporting].[vAsset] A 
									WHERE A.PlanRevisionId = @PlanRevisionId AND A.AssetTypeCode = 'AT-O'),0)




					WHEN 'PrimResMort' THEN	ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L JOIN [Reporting].[vAsset] A ON L.AssetId = A.AssetId AND A.AssetTypeCode = 'AT-P'
									WHERE L.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-P-PH'),0)
					WHEN 'SecResMort' THEN	ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L JOIN [Reporting].[vAsset] A ON L.AssetId = A.AssetId AND A.AssetTypeCode = 'AT-P'
									WHERE L.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-P-SH'),0)
					WHEN 'InvestPropMort' THEN	ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L JOIN [Reporting].[vAsset] A ON L.AssetId = A.AssetId AND A.AssetTypeCode = 'AT-P'
									WHERE L.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode IN ('AT-P-C', 'AT-P-R')),0)
					WHEN 'OthPropMort' THEN	ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L JOIN [Reporting].[vAsset] A ON L.AssetId = A.AssetId AND A.AssetTypeCode = 'AT-P'
									WHERE L.PlanRevisionId = @PlanRevisionId AND A.AssetSubTypeCode = 'AT-P-OP'),0)
					
					WHEN 'AutoLoan' THEN		ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode IN ('LT-AL', 'LT-RV')),0)
					WHEN 'CreditCard' THEN		ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-CC'),0)
					WHEN 'OtherLoan' THEN		ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-OT'),0)
					WHEN 'AllLoan' THEN		ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId),0)
					WHEN 'AllProperty' THEN		ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-RE'),0)
					
					WHEN 'AllOtherLoan' THEN	ISNULL((SELECT SUM(L.CurrentBalance)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode <> 'LT-RE'),0)
					WHEN 'AllPropertyImp' THEN	ISNULL((SELECT SUM(L.ImprovedBalance)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-RE'),0)
					WHEN 'AllOtherLoanImp' THEN	ISNULL((SELECT SUM(L.ImprovedBalance)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode <> 'LT-RE'),0)
					ELSE 0
				END					
		RETURN(@Balance)
	END
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[fnGetRealEstateBalance]')) 
	DROP FUNCTION [Reporting].[fnGetRealEstateBalance]
GO
CREATE FUNCTION [Reporting].[fnGetRealEstateBalance]
	( 
		@ClientAssetID int,
		@Type varchar(10) 
	) 
	RETURNS money
AS 
	BEGIN 
		DECLARE @Balance money 

		SET @Balance = 0
		IF @ClientAssetID IS NOT NULL
			IF @Type = 'Balance' 
				SET @Balance = ISNULL((SELECT SUM(CurrentBalance)
				FROM [Reporting].[vLiability]
				WHERE AssetId = @ClientAssetID),0)
			ELSE --'Payment'
				SET @Balance = ISNULL((
						SELECT 
							SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [CurrentPayment] ELSE ROUND(CurrentBalance * InterestRate / 12, 2) END)
						FROM [Reporting].[vLiability]
						WHERE AssetId = @ClientAssetID),0)

		RETURN(@Balance)
	END
GO



/************************************************************************/
/*These functions were previously in the Financial schema/namespace used 
	in the NH queries to simplify logic which means these can be removed after v2 fully completed*/
/************************************************************************/


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[GetCashReserveDeposit]')) 
	DROP FUNCTION [Reporting].[GetCashReserveDeposit]
GO
CREATE FUNCTION [Reporting].[GetCashReserveDeposit]
	( 
		@PlanRevisionId int
	) 
	RETURNS money
AS 
	BEGIN 
		DECLARE @CashReserveDeposit money 

		SELECT @CashReserveDeposit = (RefinanceAmount - RefinanceCosts - RepaymentOfExistingLoans - DepositToEmergencyFund)
		FROM (
				SELECT (ISNULL(SUM(L.CurrentBalance), 0) - ISNULL(SUM(L.ImprovedBalance), 0)) RepaymentOfExistingLoans
				FROM [Reporting].[vLiability] L
				WHERE PlanRevisionId = @PlanRevisionId
			) RFL,
			[Reporting].[vRecommendedRestructureAndTargets] RT
		WHERE RT.BaselineId = @PlanRevisionId

		RETURN(@CashReserveDeposit)
	END
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[GetYearsUntilRetirement]')) 
	DROP FUNCTION [Reporting].[GetYearsUntilRetirement]
GO
CREATE FUNCTION [Reporting].[GetYearsUntilRetirement]
	( 
		@PlanRevisionId int
	) 
	RETURNS int
AS 
	BEGIN 
		DECLARE @YearsUntilRetirement int 
		
		SELECT @YearsUntilRetirement = ISNULL(FP.PrimaryRetirementAge - ISNULL(FLOOR(DATEDIFF(day, PC.BirthDate, GETDATE()) / 365.25), 0), 0) 
		FROM 
			Consumer.PrimaryConsumer PC 
			JOIN Consumer.Baseline B 
				ON PC.PrimaryConsumerId = B.PrimaryConsumerId 
			LEFT JOIN Consumer.FinancialPlan FP 
				ON B.BaselineId = FP.BaselineId 
		WHERE B.BaselineId = @PlanRevisionId

		IF @YearsUntilRetirement < 0
			SET @YearsUntilRetirement = 0

		RETURN(@YearsUntilRetirement)
	END
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[GetBudgetAssetAmt]')) 
	DROP FUNCTION [Reporting].[GetBudgetAssetAmt]
GO
CREATE FUNCTION [Reporting].[GetBudgetAssetAmt]
	( 
		@PlanRevisionId int,
		@Type varchar(15) 
	) 
	RETURNS money
AS 
	BEGIN 
		DECLARE @Balance money 

		SET @Balance = 0
		IF @PlanRevisionId IS NOT NULL
			SELECT @Balance = 
				CASE @Type
					WHEN 'Life' THEN 		ROUND(ISNULL((SELECT SUM(CurrentContributions)
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetTypeCode = 'AT-I')),0)/12,2)
					WHEN 'LifeFull' THEN 		ROUND(ISNULL((SELECT SUM(CurrentContributions)
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId)),0)/12,2)
					WHEN 'LifeImp' THEN		ROUND(ISNULL((SELECT SUM(MonthlyPremium)
												FROM ( --TODO: make sense of what was going on here
													--SELECT CASE A.IsAutoEntry WHEN 0 THEN ImprovedContributions ELSE ImprovedContributions - CurrentContributions END MonthlyPremium
													SELECT ImprovedContributions MonthlyPremium
													FROM [Reporting].[vAsset] A 
													WHERE PlanRevisionId = @PlanRevisionId and AssetTypeCode = 'AT-I'
												) Z
											),0)/12,2)
					WHEN 'LifeImpFull' THEN 	ROUND(ISNULL((SELECT SUM(ImprovedContributions)
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId)),0)/12,2)
					
					WHEN 'CashSav' THEN 		ISNULL((SELECT SUM([CurrentContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-CR')),0)
					WHEN 'CashSavImp' THEN	ISNULL((SELECT SUM([ImprovedContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-CR')),0)
					WHEN 'EmergSav' THEN 		ISNULL((SELECT SUM([CurrentContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-EF')),0)
					WHEN 'EmergSavImp' THEN	ISNULL((SELECT SUM([ImprovedContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-EF')),0)
					WHEN 'CollSav' THEN 		ISNULL((SELECT SUM([CurrentContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-CS')),0)
					WHEN 'CollSavImp' THEN	ISNULL((SELECT SUM([ImprovedContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-CS')),0)
					WHEN 'XmasSav' THEN 		ISNULL((SELECT SUM([CurrentContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-XMS')),0)
					WHEN 'XmasSavImp' THEN	ISNULL((SELECT SUM([ImprovedContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-XMS')),0)
					WHEN 'VacSav' THEN 		ISNULL((SELECT SUM([CurrentContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-VS')),0)
					WHEN 'VacSavImp' THEN	ISNULL((SELECT SUM([ImprovedContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-VS')),0)
					WHEN 'TxSav' THEN 		ISNULL((SELECT SUM([CurrentContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-TA')),0)
					WHEN 'TxSavFull' THEN 	ISNULL((SELECT SUM([CurrentContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-TA')),0)
					WHEN 'TxSavEmp' THEN 	ISNULL((SELECT SUM([EmployerMonthlyDollarContributions])
									FROM [Reporting].[vAsset] A JOIN Consumer.TaxAdvantagedAsset TA ON A.AssetId = TA.TaxAdvantagedAssetId
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-TA')),0)
					WHEN 'TxSavImp' THEN	ISNULL((SELECT SUM(Contribution)
												FROM ( --What is this business below??
													--SELECT CASE A.IsAutoEntry WHEN 0 THEN [ImprovedContributions] ELSE [ImprovedContributions] - [CurrentContributions] END Contribution
													SELECT [ImprovedContributions] Contribution
													FROM [Reporting].[vAsset] A 
													WHERE PlanRevisionId = @PlanRevisionId AND AssetSubTypeCode = 'AT-V-TA'
												) Z
											),0)
					WHEN 'TxSavImpFull' THEN 	ISNULL((SELECT SUM([ImprovedContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-TA')),0)
					WHEN 'NTxSav' THEN 		ISNULL((SELECT SUM([CurrentContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-NTA')),0)
					WHEN 'NTxSavImp' THEN	ISNULL((SELECT SUM([ImprovedContributions])
									FROM [Reporting].[vAsset] A 
									WHERE (PlanRevisionId = @PlanRevisionId and AssetSubTypeCode = 'AT-V-NTA')),0)
					ELSE 0
				END					
		RETURN(@Balance)
	END
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[GetBudgetLiabilityAmt]')) 
	DROP FUNCTION [Reporting].[GetBudgetLiabilityAmt]
GO
CREATE FUNCTION [Reporting].[GetBudgetLiabilityAmt]
	( 
		@PlanRevisionId int,
		@Type varchar(10) 
	) 
	RETURNS money
AS 
	BEGIN 
		DECLARE @Balance money 

		SET @Balance = 0
		IF @PlanRevisionId IS NOT NULL
			SELECT @Balance = 
				CASE @Type
					WHEN 'Mort1' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [CurrentPayment] ELSE ROUND([CurrentBalance] * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilitySubTypeCode = 'LT-RE-FI'),0)
					WHEN 'Mort1Imp' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [ImprovedPayment] ELSE ROUND(CurrentBalance * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilitySubTypeCode = 'LT-RE-FI'),0)
					WHEN 'Mort2' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [CurrentPayment] ELSE ROUND([CurrentBalance] * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilitySubTypeCode = 'LT-RE-SE'),0)
					WHEN 'Mort2Imp' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [ImprovedPayment] ELSE ROUND(CurrentBalance * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilitySubTypeCode = 'LT-RE-SE'),0)
					WHEN 'MortOth' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [CurrentPayment] ELSE ROUND([CurrentBalance] * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilitySubTypeCode = 'LT-RE-OT'),0)
					WHEN 'MortOthImp' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [ImprovedPayment] ELSE ROUND(CurrentBalance * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilitySubTypeCode = 'LT-RE-OT'),0)
					WHEN 'Auto' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [CurrentPayment] ELSE ROUND([CurrentBalance] * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-AL'),0)
					WHEN 'AutoImp' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [ImprovedPayment] ELSE ROUND(CurrentBalance * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-AL'),0)
					WHEN 'RVPay' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [CurrentPayment] ELSE ROUND([CurrentBalance] * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-RV'),0)
					WHEN 'RVPayImp' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [ImprovedPayment] ELSE ROUND(CurrentBalance * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-RV'),0)
					WHEN 'Credit' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [CurrentPayment] ELSE ROUND([CurrentBalance] * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-CC'),0)
					WHEN 'CreditImp' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [ImprovedPayment] ELSE ROUND(CurrentBalance * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-CC'),0)
					WHEN 'Other' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [CurrentPayment] ELSE ROUND([CurrentBalance] * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-OT'),0)
					WHEN 'OtherImp' THEN 		ISNULL((SELECT SUM(CASE WHEN [InterestOnlyYears] = 0 THEN [ImprovedPayment] ELSE ROUND(CurrentBalance * InterestRate / 12, 2) END)
									FROM [Reporting].[vLiability] L 
									WHERE L.PlanRevisionId = @PlanRevisionId AND L.LiabilityTypeCode = 'LT-OT'),0)
					ELSE 0
				END					
		RETURN(@Balance)
	END
GO



/************************************************************************/
/*END functions that were previously in the Financial schema/namespace */
/************************************************************************/
