
IF SCHEMA_ID('Reporting') IS NULL
	EXEC('CREATE SCHEMA [Reporting]') 
GO



/*HACK: This is just a port over from v1 which was largely a port over from the MS Access DB.
		This report and underlying artifacts need to be deleted and the whole thing started from scratch
*/


PRINT 'Add reporting views (and functions based on some of the views and used in later views in script)'
GO


/************************************************************************/
/*These top views were previously in the Financial schema/namespace */
/************************************************************************/

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[vIncome]')) 
	DROP VIEW [Reporting].[vIncome]
GO
CREATE VIEW [Reporting].[vIncome]
AS

SELECT 
	PlanRevisionId = PR.BaselineId, 
	IncomeId = PrimaryConsumerIncomeSourceId, 
	[Source] = Employer, 
	IsPaycheck = 1,  
	OwnerTypeCode = 'CO-CLI',
	OwnerTypeName = 'Client',
	GrossMonthlyAmount = ISNULL(I.GrossSalary, 0), 
	NetMonthlyAmount = ISNULL(I.Salary, 0) +
		ISNULL(PCD.RetirementMonthlyDollarContributions + PCD.MedicalHealth + PCD.Dental + PCD.GroupLifeInsurance + PCD.DisabilityInsurance, 0)
FROM 
	Consumer.Baseline PR 
	LEFT JOIN Consumer.PrimaryConsumerIncomeSource I 
		ON PR.BaselineId = I.BaselineId
	LEFT JOIN Consumer.PrimaryConsumerIncomeDeductions PCD 
		ON PR.BaselineId = PCD.BaselineId
UNION
SELECT 
	PlanRevisionId = PR.BaselineId, 
	IncomeId = PrimaryConsumerIncomeSourceId, 
	[Source] = 'Other Income', 
	IsPaycheck = 0,  
	OwnerTypeCode = 'CO-CLI',
	OwnerTypeName = 'Client',
	GrossMonthlyAmount = ISNULL((I.BonusAndCommission + I.SelfEmploymentIncome + I.Pension + I.SSI + I.OtherIncome), 0),
	NetMonthlyAmount = ISNULL((I.BonusAndCommission + I.SelfEmploymentIncome + I.Pension + I.SSI + I.OtherIncome), 0)
FROM 
	Consumer.Baseline PR 
	LEFT JOIN Consumer.PrimaryConsumerIncomeSource I 
		ON PR.BaselineId = I.BaselineId
UNION
SELECT 
	PlanRevisionId = PR.BaselineId, 
	IncomeId = SecondaryConsumerIncomeSourceId, 
	[Source] = Employer, 
	IsPaycheck = 1,  
	OwnerTypeCode = 'CO-SPO',
	OwnerTypeName = 'Spouse',
	GrossMonthlyAmount = ISNULL(I.GrossSalary, 0), 
	NetMonthlyAmount = ISNULL(I.Salary, 0) + 
		ISNULL(SCD.RetirementMonthlyDollarContributions + SCD.MedicalHealth + SCD.Dental + SCD.GroupLifeInsurance + SCD.DisabilityInsurance, 0) 
FROM 
	Consumer.Baseline PR 
	LEFT JOIN Consumer.SecondaryConsumerIncomeSource I 
		ON PR.BaselineId = I.BaselineId
	LEFT JOIN Consumer.SecondaryConsumerIncomeDeductions SCD 
		ON PR.BaselineId = SCD.BaselineId
UNION
SELECT 
	PlanRevisionId = PR.BaselineId, 
	IncomeId = SecondaryConsumerIncomeSourceId, 
	[Source] = 'Other Income', 
	IsPaycheck = 0,  
	OwnerTypeCode = 'CO-SPO',
	OwnerTypeName = 'Spouse',
	GrossMonthlyAmount = ISNULL((I.BonusAndCommission + I.SelfEmploymentIncome + I.Pension + I.SSI + I.OtherIncome), 0),
	NetMonthlyAmount = ISNULL((I.BonusAndCommission + I.SelfEmploymentIncome + I.Pension + I.SSI + I.OtherIncome), 0)
FROM 
	Consumer.Baseline PR 
	LEFT JOIN Consumer.SecondaryConsumerIncomeSource I 
		ON PR.BaselineId = I.BaselineId

GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[vNetPaycheckIncome]')) 
	DROP VIEW [Reporting].[vNetPaycheckIncome]
GO
CREATE VIEW [Reporting].[vNetPaycheckIncome]
AS

SELECT PR.PlanRevisionId, I.OwnerTypeCode,
	ISNULL(SUM(I.NetMonthlyAmount), 0) NetIncome
FROM [Reporting].[vPlanRevision] PR
	LEFT JOIN [Reporting].[vIncome] I ON PR.PlanRevisionId = I.PlanRevisionId AND I.IsPaycheck = 1
GROUP BY PR.PlanRevisionId, I.OwnerTypeCode
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[vNetOtherIncome]')) 
	DROP VIEW [Reporting].[vNetOtherIncome]
GO
CREATE VIEW [Reporting].[vNetOtherIncome]
AS

SELECT PR.PlanRevisionId,
	ISNULL(SUM(I.NetMonthlyAmount), 0) NetIncome
FROM [Reporting].[vPlanRevision] PR
	LEFT JOIN [Reporting].[vIncome] I ON PR.PlanRevisionId = I.PlanRevisionId AND I.IsPaycheck = 0
GROUP BY PR.PlanRevisionId
GO


/************************************************************************/
/*Inserting these two functions here even tho scsript for views because it 
	uses the views above but is referenced below - could just refactor 
	but getting out of this mess */
/************************************************************************/

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[GetOtherIncomeTotal]')) 
	DROP FUNCTION [Reporting].[GetOtherIncomeTotal]
GO
CREATE FUNCTION [Reporting].[GetOtherIncomeTotal]
	( 
		@PlanRevisionId int
	) 
	RETURNS money
AS 
	BEGIN 
		DECLARE @Balance money 

		SELECT @Balance = ISNULL(SUM(Amount), 0)
		FROM (
				--NOTE: Decision to only show rental income for other, to help tie to the system's method of display/aggregation
				--SELECT Amount = NetIncome 
				--FROM [Reporting].[vNetOtherIncome]
				--WHERE PlanRevisionId = @PlanRevisionId

				--UNION
				SELECT Amount = SUM(RE.GrossRentalIncome - RE.PropertyExpenses)
				FROM Consumer.RealEstateAsset RE
				WHERE RE.BaselineId = @PlanRevisionId AND RE.GrossRentalIncome <> 0
			) INC

		RETURN(@Balance)
	END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[GetTotalNetIncome]')) 
	DROP FUNCTION [Reporting].[GetTotalNetIncome]
GO
CREATE FUNCTION [Reporting].[GetTotalNetIncome]
	( 
		@PlanRevisionId int,
		@IncludeAllIncome bit
	) 
	RETURNS money
AS 
	BEGIN 
		DECLARE @NetIncome money 

		SELECT @NetIncome = ISNULL(SUM(NetMonthlyAmount), 0)
		FROM [Reporting].[vIncome]
		WHERE PlanRevisionId = @PlanRevisionId
		
		IF @IncludeAllIncome = 1
			SELECT @NetIncome = ISNULL(@NetIncome, 0) + ISNULL([Reporting].GetOtherIncomeTotal(@PlanRevisionId), 0)

		RETURN(@NetIncome)
	END
GO




IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[Reporting].[vBudgetSummary]')) 
	DROP VIEW [Reporting].[vBudgetSummary]
GO
CREATE VIEW [Reporting].[vBudgetSummary]
AS
	SELECT 
		BUD.*,
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'Mort1') AS 'FirstMortgage',
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'Mort1Imp') + CASE WHEN RT.RefinanceTypeCode = 'REF-FIR' THEN RT.RefinanceMonthlyPayment ELSE 0 END AS 'FirstMortgageImproved', 
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'Mort2') AS 'SecondMortgage',
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'Mort2Imp') + CASE WHEN RT.RefinanceTypeCode = 'REF-SEC' THEN RT.RefinanceMonthlyPayment ELSE 0 END AS 'SecondMortgageImproved',
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'MortOth') AS 'OtherLien',
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'MortOthImp') + CASE WHEN RT.RefinanceTypeCode = 'REF-OTH' THEN RT.RefinanceMonthlyPayment ELSE 0 END AS 'OtherLienImproved',
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'Auto') AS 'CarPayment', 
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'AutoImp') AS 'CarPaymentImproved',
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'RVPay') AS 'RVPayment', 
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'RVPayImp') AS 'RVPaymentImproved',
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'Credit') AS 'CreditDebt', 
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'CreditImp') AS 'CreditDebtImproved',
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'Other') AS 'OtherDebt', 
		[Reporting].[GetBudgetLiabilityAmt](BUD.PlanRevisionId, 'OtherImp') AS 'OtherDebtImproved',
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'Life') AS 'LifeInsurance', 
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'LifeImp') AS 'LifeInsuranceImproved',
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'CashSav') + [Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'EmergSav') AS 'CashSaving', 
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'CashSavImp') + [Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'EmergSavImp') AS 'CashSavingImproved',
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'CollSav') AS 'CollegeSaving', 
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'CollSavImp') AS 'CollegeSavingImproved',
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'XmasSav') AS 'XmasSaving', 
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'XmasSavImp') AS 'XmasSavingImproved',
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'VacSav') AS 'VacationSaving', 
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'VacSavImp') AS 'VacationSavingImproved',
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'TxSav') AS 'TaxDeferSaving', 
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'TxSavImp') AS 'TaxDeferSavingImproved',
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'NTxSav') AS 'NonTaxDeferSaving', 
		[Reporting].[GetBudgetAssetAmt](BUD.PlanRevisionId, 'NTxSavImp') AS 'NonTaxDeferSavingImproved',
		ISNULL(PAY.ClientNetIncome, 0) ClientNetIncome, 
		ISNULL(PAY.SpouseNetIncome, 0) SpouseNetIncome, 
		[Reporting].[GetOtherIncomeTotal](BUD.PlanRevisionId) AS TotalOtherIncome,
		TotalExpenses = (HomeSubtotal + FoodSubtotal + HealthSubtotal + GivingSubtotal + TextilesSubtotal + AutoSubtotal + MiscSubtotal + OtherTotal),
		TotalExpensesImproved = (HomeSubtotalImproved + FoodSubtotalImproved + HealthSubtotalImproved + GivingSubtotalImproved + TextilesSubtotalImproved + AutoSubtotalImproved + MiscSubtotalImproved + OtherTotalImproved)
	FROM (
			SELECT 
				PlanRevisionId = PR.BaselineId,
				Rent = ISNULL(Rent, 0),
				HomeOwnerInsurance = ISNULL(HOME_OWNERS.Amount, 0),
				PropertyTax = ISNULL(PropertyTaxes, 0),
				GasElectricity = ISNULL(PowerUtility, 0),
				Telephone = ISNULL(Landline, 0),
				CellPhone = ISNULL(CellPhone, 0),
				WaterTrashSewer = ISNULL(CityUtility, 0),
				HomeMaint = ISNULL(HomeMaintenance, 0),
				Housekeeping = ISNULL(Housekeeping, 0),
				CableSatellite = ISNULL(EntertainmentBundle, 0),
				HoaDues = ISNULL(HoaDues, 0),
				Groceries = ISNULL(Food, 0),
				DiningOut = ISNULL(DiningOut, 0),
				InsuranceDisability = ISNULL(DISABILITY.Amount, 0),
				InsuranceLegal = ISNULL(Legal, 0) + ISNULL(OTHER_INSURANCE.Amount, 0),
				InsuranceMedical = ISNULL(MEDICAL.Amount, 0),
				InsuranceDental = ISNULL(OTHER_HEALTH.Amount, 0),
				Medical = ISNULL(MedicalCopays, 0),
				Dental = ISNULL(OtherCopays, 0),
				Prescription = ISNULL(Prescriptions, 0),
				Orthodontist = ISNULL(Orthodontist, 0),
				Tithe = ISNULL(Tithe, 0),
				CharitableContribution = ISNULL(CharitableContributions, 0),
				Clothing = ISNULL(Clothing, 0),
				Laundry = ISNULL(Laundry, 0),
				CarInsurance = ISNULL(AUTO_INSURANCE.Amount, 0),
				CarMaint = ISNULL(AutoExpenses, 0),
				RVInsurance = ISNULL(RV_INSURANCE.Amount, 0),
				RVMaint = ISNULL(RecreationExpenses, 0),
				ChildCare = ISNULL(AdditionalChildCare, 0),
				Education = ISNULL(Education, 0),
				KidActivity = ISNULL(KidsActivities, 0),
				HealthClub = ISNULL(HealthClub, 0),
				Cosmetic = ISNULL(Cosmetics, 0),
				Pet = ISNULL(Pets, 0),
				Vacation = ISNULL(Vacations, 0),
				Hobby = ISNULL(Hobbies, 0),
				Movies = ISNULL(Movies, 0),
				Magazine = ISNULL(Magazines, 0),
				OtherEntertainment = ISNULL(OtherEntertainment, 0),

				HomeSubtotal = ISNULL((Rent + PropertyTaxes + HomeMaintenance + HoaDues + Housekeeping + CityUtility + PowerUtility + Landline + CellPhone + EntertainmentBundle), 0) + ISNULL(HOME_OWNERS.Amount, 0),
				FoodSubtotal = ISNULL((Food + DiningOut), 0),
				HealthSubtotal = ISNULL((MedicalCopays + OtherCopays + Prescriptions + Orthodontist + Legal), 0) + ISNULL(MEDICAL.Amount, 0) + ISNULL(OTHER_HEALTH.Amount, 0) + ISNULL(DISABILITY.Amount, 0) + ISNULL(OTHER_INSURANCE.Amount, 0),
				GivingSubtotal = ISNULL((Tithe + CharitableContributions), 0),
				TextilesSubtotal = ISNULL((Clothing + Laundry), 0),
				AutoSubtotal = ISNULL((AutoExpenses + RecreationExpenses), 0) + ISNULL(AUTO_INSURANCE.Amount, 0) + ISNULL(RV_INSURANCE.Amount, 0),
				MiscSubtotal = ISNULL((AdditionalChildCare + Education + KidsActivities + HealthClub + Cosmetics + Pets + Vacations + Hobbies + Movies + Magazines + OtherEntertainment), 0),
				OtherTotal = 0,


				RentImproved = ISNULL(RevisedRent, 0),
				HomeOwnerInsuranceImproved = ISNULL(HOME_OWNERS.RevisedAmount, 0),
				PropertyTaxImproved = ISNULL(RevisedPropertyTaxes, 0),
				GasElectricityImproved = ISNULL(RevisedPowerUtility, 0),
				TelephoneImproved = ISNULL(RevisedLandline, 0),
				CellPhoneImproved = ISNULL(RevisedCellPhone, 0),
				WaterTrashSewerImproved = ISNULL(RevisedCityUtility, 0),
				HomeMaintImproved = ISNULL(RevisedHomeMaintenance, 0),
				HousekeepingImproved = ISNULL(RevisedHousekeeping, 0),
				CableSatelliteImproved = ISNULL(RevisedEntertainmentBundle, 0),
				HoaDuesImproved = ISNULL(RevisedHoaDues, 0),
				GroceriesImproved = ISNULL(RevisedFood, 0),
				DiningOutImproved = ISNULL(RevisedDiningOut, 0),
				InsuranceDisabilityImproved = ISNULL(DISABILITY.RevisedAmount, 0),
				InsuranceLegalImproved = ISNULL(RevisedLegal, 0) + ISNULL(OTHER_INSURANCE.RevisedAmount, 0),
				InsuranceMedicalImproved = ISNULL(MEDICAL.RevisedAmount, 0),
				InsuranceDentalImproved = ISNULL(OTHER_HEALTH.RevisedAmount, 0),
				MedicalImproved = ISNULL(RevisedMedicalCopays, 0),
				DentalImproved = ISNULL(RevisedOtherCopays, 0),
				PrescriptionImproved = ISNULL(RevisedPrescriptions, 0),
				OrthodontistImproved = ISNULL(RevisedOrthodontist, 0),
				TitheImproved = ISNULL(RevisedTithe, 0),
				CharitableContributionImproved = ISNULL(RevisedCharitableContributions, 0),
				ClothingImproved = ISNULL(RevisedClothing, 0),
				LaundryImproved = ISNULL(RevisedLaundry, 0),
				CarInsuranceImproved = ISNULL(AUTO_INSURANCE.RevisedAmount, 0),
				CarMaintImproved = ISNULL(RevisedAutoExpenses, 0),
				RVInsuranceImproved = ISNULL(RV_INSURANCE.RevisedAmount, 0),
				RVMaintImproved = ISNULL(RevisedRecreationExpenses, 0),
				ChildCareImproved = ISNULL(RevisedAdditionalChildCare, 0),
				EducationImproved = ISNULL(RevisedEducation, 0),
				KidActivityImproved = ISNULL(RevisedKidsActivities, 0),
				HealthClubImproved = ISNULL(RevisedHealthClub, 0),
				CosmeticImproved = ISNULL(RevisedCosmetics, 0),
				PetImproved = ISNULL(RevisedPets, 0),
				VacationImproved = ISNULL(RevisedVacations, 0),
				HobbyImproved = ISNULL(RevisedHobbies, 0),
				MoviesImproved = ISNULL(RevisedMovies, 0),
				MagazineImproved = ISNULL(RevisedMagazines, 0),
				OtherEntertainmentImproved = ISNULL(RevisedOtherEntertainment, 0),

				HomeSubtotalImproved = ISNULL((RevisedRent + RevisedPropertyTaxes + RevisedHomeMaintenance + RevisedHoaDues + RevisedHousekeeping + RevisedCityUtility + RevisedPowerUtility + RevisedLandline + RevisedCellPhone + RevisedEntertainmentBundle), 0) + ISNULL(HOME_OWNERS.RevisedAmount, 0),
				FoodSubtotalImproved = ISNULL((RevisedFood + RevisedDiningOut), 0),
				HealthSubtotalImproved = ISNULL((RevisedMedicalCopays + RevisedOtherCopays + RevisedPrescriptions + RevisedOrthodontist + RevisedLegal), 0) + ISNULL(MEDICAL.RevisedAmount, 0) + ISNULL(OTHER_HEALTH.RevisedAmount, 0) + ISNULL(DISABILITY.RevisedAmount, 0) + ISNULL(OTHER_INSURANCE.RevisedAmount, 0),
				GivingSubtotalImproved = ISNULL((RevisedTithe + RevisedCharitableContributions), 0),
				TextilesSubtotalImproved = ISNULL((RevisedClothing + RevisedLaundry), 0),
				AutoSubtotalImproved = ISNULL((RevisedAutoExpenses + RevisedRecreationExpenses), 0) + ISNULL(AUTO_INSURANCE.RevisedAmount, 0) + ISNULL(RV_INSURANCE.RevisedAmount, 0),
				MiscSubtotalImproved = ISNULL((RevisedAdditionalChildCare + RevisedEducation + RevisedKidsActivities + RevisedHealthClub + RevisedCosmetics + RevisedPets + RevisedVacations + RevisedHobbies + RevisedMovies + RevisedMagazines + RevisedOtherEntertainment), 0),
				OtherTotalImproved = 0
		
			FROM 
				Consumer.Baseline PR 
				LEFT JOIN (
					Consumer.Budget B 
					LEFT JOIN [Plan].RevisedBudget RB
						ON B.BudgetId = RB.BudgetId
					) ON PR.BaselineId = B.BaselineId
				OUTER APPLY (
					SELECT Amount = SUM(AP.AnnualPremium / 12), RevisedAmount = SUM(RAP.RevisedAnnualPremium / 12) FROM Consumer.AssetProtection AP LEFT JOIN [Plan].RevisedAssetProtection RAP ON AP.AssetProtectionId = RAP.AssetProtectionId WHERE AP.BaselineId = PR.BaselineId AND AP.InsuranceTypeCode = 'INS-HO'
				) HOME_OWNERS
				OUTER APPLY (
					SELECT Amount = SUM(AP.AnnualPremium / 12), RevisedAmount = SUM(RAP.RevisedAnnualPremium / 12) FROM Consumer.AssetProtection AP LEFT JOIN [Plan].RevisedAssetProtection RAP ON AP.AssetProtectionId = RAP.AssetProtectionId WHERE AP.BaselineId = PR.BaselineId AND AP.InsuranceTypeCode IN ('INS-DIS')
				) DISABILITY
				OUTER APPLY (
					SELECT Amount = SUM(AP.AnnualPremium / 12), RevisedAmount = SUM(RAP.RevisedAnnualPremium / 12) FROM Consumer.AssetProtection AP LEFT JOIN [Plan].RevisedAssetProtection RAP ON AP.AssetProtectionId = RAP.AssetProtectionId WHERE AP.BaselineId = PR.BaselineId AND AP.InsuranceTypeCode = 'INS-MED'
				) MEDICAL
				OUTER APPLY (
					SELECT Amount = SUM(AP.AnnualPremium / 12), RevisedAmount = SUM(RAP.RevisedAnnualPremium / 12) FROM Consumer.AssetProtection AP LEFT JOIN [Plan].RevisedAssetProtection RAP ON AP.AssetProtectionId = RAP.AssetProtectionId WHERE AP.BaselineId = PR.BaselineId AND AP.InsuranceTypeCode IN ('INS-DENT', 'INS-VIS')
				) OTHER_HEALTH
				OUTER APPLY (
					SELECT Amount = SUM(AP.AnnualPremium / 12), RevisedAmount = SUM(RAP.RevisedAnnualPremium / 12) FROM Consumer.AssetProtection AP LEFT JOIN [Plan].RevisedAssetProtection RAP ON AP.AssetProtectionId = RAP.AssetProtectionId WHERE AP.BaselineId = PR.BaselineId AND AP.InsuranceTypeCode = 'INS-AUTO'
				) AUTO_INSURANCE
				OUTER APPLY (
					SELECT Amount = SUM(AP.AnnualPremium / 12), RevisedAmount = SUM(RAP.RevisedAnnualPremium / 12) FROM Consumer.AssetProtection AP LEFT JOIN [Plan].RevisedAssetProtection RAP ON AP.AssetProtectionId = RAP.AssetProtectionId WHERE AP.BaselineId = PR.BaselineId AND AP.InsuranceTypeCode = 'INS-RV'
				) RV_INSURANCE
				OUTER APPLY (
					SELECT Amount = SUM(AP.AnnualPremium / 12), RevisedAmount = SUM(RAP.RevisedAnnualPremium / 12) FROM Consumer.AssetProtection AP LEFT JOIN [Plan].RevisedAssetProtection RAP ON AP.AssetProtectionId = RAP.AssetProtectionId WHERE AP.BaselineId = PR.BaselineId AND AP.InsuranceTypeCode IN ('INS-EO', 'INS-UMB', 'INS-OTH', 'INS-LTC')
				) OTHER_INSURANCE
					
		) BUD
		
		LEFT JOIN (
				SELECT PlanRevisionId, ClientNetIncome = SUM(ClientNetIncome), SpouseNetIncome = SUM(SpouseNetIncome)
				FROM (
						--NOTE: Decision to just show all income aggregated by the client, except rental income ... for now
						--SELECT PlanRevisionId,
						--	ClientNetIncome = CASE WHEN OwnerTypeCode <> 'CO-SPO' THEN NetIncome ELSE 0 END, 
						--	SpouseNetIncome = CASE WHEN OwnerTypeCode = 'CO-SPO' THEN NetIncome ELSE 0 END
						--FROM [Reporting].[vNetPaycheckIncome]
						SELECT PlanRevisionId,
							ClientNetIncome = CASE WHEN OwnerTypeCode <> 'CO-SPO' THEN NetMonthlyAmount ELSE 0 END, 
							SpouseNetIncome = CASE WHEN OwnerTypeCode = 'CO-SPO' THEN NetMonthlyAmount ELSE 0 END
						FROM [Reporting].[vIncome]
					) INC
				GROUP BY PlanRevisionId
		) PAY 
			ON BUD.PlanRevisionId = PAY.PlanRevisionId
		
		LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] RT 
			ON BUD.PlanRevisionId = RT.BaselineId
GO


/************************************************************************/
/*END views that were previously in the Financial schema/namespace */
/************************************************************************/





IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.aaview')) 
	DROP VIEW [Reporting].[aaview]
GO
CREATE VIEW [Reporting].[aaview]
AS
SELECT     MAX(AssetId) AS Expr1
FROM         [Reporting].[vAsset]
--GROUP BY ClientAssetIDOld
--HAVING      (ClientAssetIDOld = 3)
GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.[vNetIncome]')) 
	DROP VIEW [Reporting].[vNetIncome]
GO
CREATE VIEW [Reporting].[vNetIncome]
AS

SELECT PR.PlanRevisionId, I.OwnerTypeCode,
	ISNULL(SUM(I.NetMonthlyAmount), 0) NetIncome
FROM [Reporting].[vPlanRevision] PR
	LEFT JOIN [Reporting].[vIncome] I ON PR.PlanRevisionId = I.PlanRevisionId
GROUP BY PR.PlanRevisionId, I.OwnerTypeCode
GO


--This is only used in the calc to load all these vars - just moved all this logic inside the proc since not even all this stuff was being used
/*
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.[vPlanRevisionCalcVariables]')) 
	DROP VIEW [Reporting].[vPlanRevisionCalcVariables]
GO
CREATE VIEW [Reporting].[vPlanRevisionCalcVariables]
AS
SELECT PR.PlanRevisionId,
	P.PlanId, P.Name, P.FinancialRepId, P.MaritalStatus, P.Dependents,
	PR.PlanRevisionId ClientRevisionID, PR.Name RevisionName, PR.CreateDate RevisionDate, PR.Comment, PR.ReportName, PR.GoalComment, PR.CafrYears CAFRNoOfYrs, PR.AdjustedHouseBudgetRatio, PR.AdjustedFoodBudgetRatio, PR.AdjustedInsuranceBudgetRatio, PR.AdjustedGivingBudgetRatio, PR.AdjustedSavingBudgetRatio, PR.AdjustedClothingBudgetRatio, PR.AdjustedAutoBudgetRatio, PR.AdjustedMiscBudgetRatio, PR.AdjustedDebtBudgetRatio,
	C.ClientId, S.ClientId SpouseId, C.ClientId ClientIDNo,
	CIW.PayCkCFreq, CIW.PayCkCFedTax, CIW.PayCkCFICA, CIW.PayCkCMedicare, CIW.PayCkCStateTax, CIW.PayCkCStateDI, CIW.PayCkCUnionDue, CIW.PayCkCMedHealth, CIW.PayCkCDental, CIW.PayCkCLifeIns, CIW.PayCkCDI, CIW.PayCkCLegalChild, CIW.PayCkCLegalAlimony, CIW.PayCkCEmplStock, CIW.PayCkCCalPERS, CIW.PayCkCOtherDeduct, CIW.PayCkCOtherChild, CIW.PayCkCOtherChildCare, CIW.PayCkCOtherAlimony, CIW.C401KEmployerCont, CIW.C401KEmployerPer, CIW.C401KEmployeePer, CIW.PayCkC401KLoan, CIW.C401KLoanBal,
	SIW.PayCkSFreq, SIW.PayCkSFedTax, SIW.PayCkSFICA, SIW.PayCkSMedicare, SIW.PayCkSStateTax, SIW.PayCkSStateDI, SIW.PayCkSUnionDue, SIW.PayCkSMedHealth, SIW.PayCkSDental, SIW.PayCkSLifeIns, SIW.PayCkSDI, SIW.PayCkSLegalChild, SIW.PayCkSLegalAlimony, SIW.PayCkSEmplStock, SIW.PayCkSCalPERS, SIW.PayCkSOtherDeduct, SIW.PayCkSOtherChild, SIW.PayCkSOtherChildCare, SIW.PayCkSOtherAlimony, SIW.S401KEmployerCont, SIW.S401KEmployerPer, SIW.S401KEmployeePer, SIW.PayCkS401KLoan, SIW.S401KLoanBal,
	RT.MortgageTypeDescription MortRefinType, MT.Name MortRefinType2, RT.MortgageRefinanceAmount MortRefinAmt, RT.MortgageRefinanceRate MortRefinRate, RT.MortgageRefinancePayment MortRefinPaymt, RT.MortgageRefinanceCost MortRefinCost, RT.EmergencyFundDeposit EmFundDeposit, RT.EmergencyFundBalance EmFundRecomBal, RT.CashReserveBalance CashResRecomBal, RT.CafrPhase2DebtRate CAFRP2Debt, RT.CafrPhase2ReserveRate CAFRP2Reserve, RT.CafrPhase2DebtWithCashRate CAFRP2Debt2, RT.CafrPhase3DebtRate CAFRP3Debt, RT.CafrPhase3ReserveRate CAFRP3Reserve, RT.CafrPhase4ReserveRate CAFRP4Reserve, RT.LifeInsuranceCoverage CInsureRecom, RT.LifeInsuranceEstimatedPremium CInsurePremRecom, RT.SpouseLifeInsuranceCoverage SInsureRecom, RT.SpouseLifeInsuranceEstimatedPremium SInsurePremRecom,
	[Reporting].[GetCashReserveDeposit](PR.PlanRevisionId) CashResDeposit,
	CPROJ.RetirementAge CRetireAge, CPROJ.RetirementExpenses CRetireExp, CPROJ.DeathFund CDeathFund, CPROJ.InflationRate CInflationRate, CPROJ.PreRetirementRate CPreRetireRate, CPROJ.PostRetirementRate CPostRetireRate, CPROJ.CurrentTaxRate CCurrTaxRate, CPROJ.RetirementTaxRate CRetireTaxRate, CPROJ.RetirementIncome CRetireIncome, CPROJ.RetirementYears CRetireIncYrs, CPROJ.SSAge CSSAge, CPROJ.SSBenefit CSSMthBenefit, CPROJ.PensionBenefit CPension, CPROJ.PensionYears CPensionYrs, CPROJ.CurrentPlan CCurPlanAchieveGoal, CPROJ.FutureExpectation CHappen3Yrs, CPROJ.MiscDebtRate CMiscDebtRate, 
	SPROJ.RetirementAge SRetireAge, SPROJ.RetirementExpenses SRetireExp, SPROJ.DeathFund SDeathFund, SPROJ.InflationRate SInflationRate, SPROJ.PreRetirementRate SPreRetireRate, SPROJ.PostRetirementRate SPostRetireRate, SPROJ.CurrentTaxRate SCurrTaxRate, SPROJ.RetirementTaxRate SRetireTaxRate, SPROJ.RetirementIncome SRetireIncome, SPROJ.RetirementYears SRetireIncYrs, SPROJ.SSAge SSSAge, SPROJ.SSBenefit SSSMthBenefit, SPROJ.PensionBenefit SPension, SPROJ.PensionYears SPensionYrs, SPROJ.CurrentPlan SCurPlanAchieveGoal, SPROJ.FutureExpectation SHappen3Yrs, SPROJ.MiscDebtRate SMiscDebtRate, 
	CLIP.Purpose CInsPurpose, CLIP.HaveHealthIssues CHealthProb, CLIP.Height CHeight, CLIP.Weight CWeight, CLIP.UseTabacco CUseTabacco, CLIP.WhenQuitTabacco CQuitTabacco, CLIP.HaveBenNotWork CBenNotWork, CLIP.YearsBenNotWork CBenNotWorkYrs, CLIP.HaveCollegePlans CKidCollege, CLIP.IsCollegePrivate CPrivatePublic, CLIP.FundCollege CInsCollege,
	SLIP.Purpose SInsPurpose, SLIP.HaveHealthIssues SHealthProb, SLIP.Height SHeight, SLIP.Weight SWeight, SLIP.UseTabacco SUseTabacco, SLIP.WhenQuitTabacco SQuitTabacco, SLIP.HaveBenNotWork SBenNotWork, SLIP.YearsBenNotWork SBenNotWorkYrs, SLIP.HaveCollegePlans SKidCollege, SLIP.IsCollegePrivate SPrivatePublic, SLIP.FundCollege SInsCollege
FROM 
	Financial.[Plan] P
	INNER JOIN [Reporting].[vPlanRevision] PR ON P.PlanId = PR.PlanId
	INNER JOIN Financial.Client C ON P.PlanId = C.PlanId AND C.ClientTypeCode = 'CT-CLI'
	LEFT JOIN Financial.Client S ON P.PlanId = S.PlanId AND S.ClientTypeCode = 'CT-SPO'
	LEFT JOIN (
		SELECT I.PlanRevisionId, MAX(PFT.Name) PayCkCFreq, SUM(IW.FederalTax) PayCkCFedTax, SUM(IW.Fica) PayCkCFICA, SUM(IW.Medicare) PayCkCMedicare, SUM(IW.StateTax) PayCkCStateTax, SUM(IW.StateDisabilityInsurance) PayCkCStateDI, SUM(IW.UnionDue) PayCkCUnionDue, SUM(IW.MedicalHealth) PayCkCMedHealth, SUM(IW.Dental) PayCkCDental, SUM(IW.LifeInsurance) PayCkCLifeIns, SUM(IW.DisabilityInsurance) PayCkCDI, SUM(IW.LegalChild) PayCkCLegalChild, SUM(IW.LegalAlimony) PayCkCLegalAlimony, SUM(IW.EmployeeStock) PayCkCEmplStock, SUM(IW.CalPers) PayCkCCalPERS, SUM(IW.OtherDeduction) PayCkCOtherDeduct, SUM(IW.OtherChild) PayCkCOtherChild, SUM(IW.OtherChildCare) PayCkCOtherChildCare, SUM(IW.OtherAlimony) PayCkCOtherAlimony, SUM(IW.RetirementContributionAmt) C401KEmployerCont, SUM(I.RetirementEmployerPer) C401KEmployerPer, SUM(I.RetirementEmployeePer) C401KEmployeePer, SUM(IW.RetirementLoanRepayment) PayCkC401KLoan, SUM(I.RetirementLoanBalance) C401KLoanBal
		FROM 
			Financial.Income I 
			INNER JOIN Code.LookupItem PFT ON I.PayFrequencyTypeCode = PFT.Code
			LEFT JOIN Financial.IncomeWithholding IW ON I.IncomeId = IW.IncomeId 
		WHERE I.IsPaycheck = 1 AND I.OwnerTypeCode = 'CO-CLI'
		GROUP BY PlanRevisionId
	) CIW ON PR.PlanRevisionId = CIW.PlanRevisionId
	LEFT JOIN (
		SELECT I.PlanRevisionId, MAX(PFT.Name) PayCkSFreq, SUM(IW.FederalTax) PayCkSFedTax, SUM(IW.Fica) PayCkSFICA, SUM(IW.Medicare) PayCkSMedicare, SUM(IW.StateTax) PayCkSStateTax, SUM(IW.StateDisabilityInsurance) PayCkSStateDI, SUM(IW.UnionDue) PayCkSUnionDue, SUM(IW.MedicalHealth) PayCkSMedHealth, SUM(IW.Dental) PayCkSDental, SUM(IW.LifeInsurance) PayCkSLifeIns, SUM(IW.DisabilityInsurance) PayCkSDI, SUM(IW.LegalChild) PayCkSLegalChild, SUM(IW.LegalAlimony) PayCkSLegalAlimony, SUM(IW.EmployeeStock) PayCkSEmplStock, SUM(IW.CalPers) PayCkSCalPERS, SUM(IW.OtherDeduction) PayCkSOtherDeduct, SUM(IW.OtherChild) PayCkSOtherChild, SUM(IW.OtherChildCare) PayCkSOtherChildCare, SUM(IW.OtherAlimony) PayCkSOtherAlimony, SUM(IW.RetirementContributionAmt) S401KEmployerCont, SUM(I.RetirementEmployerPer) S401KEmployerPer, SUM(I.RetirementEmployeePer) S401KEmployeePer, SUM(IW.RetirementLoanRepayment) PayCkS401KLoan, SUM(I.RetirementLoanBalance) S401KLoanBal
		FROM 
			Financial.Income I 
			INNER JOIN Code.LookupItem PFT ON I.PayFrequencyTypeCode = PFT.Code
			LEFT JOIN Financial.IncomeWithholding IW ON I.IncomeId = IW.IncomeId 
		WHERE I.IsPaycheck = 1 AND I.OwnerTypeCode = 'CO-SPO'
		GROUP BY PlanRevisionId
	) SIW ON PR.PlanRevisionId = SIW.PlanRevisionId
	LEFT JOIN (
		[Reporting].[vRecommendedRestructureAndTargets] RT LEFT JOIN Code.LookupItem MT ON RT.MortgageTypeCode = MT.Code 
	) ON PR.PlanRevisionId = RT.PlanRevisionId 
	LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] CPROJ ON PR.PlanRevisionId = CPROJ.PlanRevisionId AND CPROJ.ClientId = C.ClientId
	LEFT JOIN [Reporting].[vRecommendedRestructureAndTargets] SPROJ ON PR.PlanRevisionId = SPROJ.PlanRevisionId AND SPROJ.ClientId = S.ClientId
	LEFT JOIN Financial.LifeInsuranceProfile CLIP ON PR.PlanRevisionId = CLIP.PlanRevisionId AND CLIP.ClientId = C.ClientId
	LEFT JOIN Financial.LifeInsuranceProfile SLIP ON PR.PlanRevisionId = SLIP.PlanRevisionId AND SLIP.ClientId = S.ClientId
*/
	
	
GO
