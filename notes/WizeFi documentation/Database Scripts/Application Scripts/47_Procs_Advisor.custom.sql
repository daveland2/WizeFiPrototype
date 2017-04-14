SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO


--Using SYNONYMs to at least isolate the external references to a single handle
--NOTE: Dependent on the Membership database and Account.UserMapping table
IF OBJECT_ID(N'MEMBERSHIP_USER_MAPPING') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_USER_MAPPING
	FOR Membership.Account.UserMapping
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_Applications table
IF OBJECT_ID(N'MEMBERSHIP_APPLICATIONS') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_APPLICATIONS
	FOR Membership.dbo.aspnet_Applications
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_Membership table
IF OBJECT_ID(N'MEMBERSHIP_LOGINS') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_LOGINS
	FOR Membership.dbo.aspnet_Membership
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_Users table
IF OBJECT_ID(N'MEMBERSHIP_USERS') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_USERS
	FOR Membership.dbo.aspnet_Users
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_UsersInRoles table
IF OBJECT_ID(N'MEMBERSHIP_USER_ROLES') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_USER_ROLES
	FOR Membership.dbo.aspnet_UsersInRoles
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_Profile table
IF OBJECT_ID(N'MEMBERSHIP_PROFILES') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_PROFILES
	FOR Membership.dbo.aspnet_Profile
END
GO




PRINT 'Add [CopyVersionAndArchive] proc' 
IF OBJECT_ID(N'[Advisor].[CopyVersionAndArchive]') IS NOT NULL 
	DROP PROC [Advisor].[CopyVersionAndArchive] 
GO
CREATE PROC [Advisor].[CopyVersionAndArchive] (
	@SourceBaselineId INT, --Source version to base everything off of
	@MakeIntoPlan BIT = 0 --Indicates if this is being copied and then coverted into a MOPro Plan
) 
AS

--NOTE: This should truly be a domain service in the app. However, the justification for using a proc instead is due to
--	not having any logic really whatsoever contained here so basically just a grunt operation and the sheer volume of objects
--	touched just to copy so would be vey expensive doing in the domain for an operation that will be used frequently

--TODO ensure copying an inactive baseline is allowed
DECLARE 
	@Error INT,
	@PrimaryConsumerId INT,
	@NewBaselineId INT,
	@NewVersion INT,
	@HasPlan BIT

SELECT 
	@PrimaryConsumerId = S.PrimaryConsumerId,
	@NewVersion = MAX(LAST_VER.[Version]) + 1,
	@HasPlan = CASE WHEN MAX(P.BaselineId) IS NOT NULL THEN 1 ELSE 0 END
FROM 
	Consumer.Baseline S
	LEFT JOIN [Plan].PlanRevision P
		ON S.BaselineId = P.BaselineId
	CROSS APPLY(
		SELECT [Version] = MAX([Version])
		FROM Consumer.Baseline B
		WHERE B.PrimaryConsumerId = S.PrimaryConsumerId
	) LAST_VER
WHERE S.BaselineId = @SourceBaselineId
GROUP BY S.PrimaryConsumerId


BEGIN TRAN

--Archive everything that wasnt already, including current/active
UPDATE Consumer.Baseline
SET
	ArchiveDate = GETDATE(),
	IsActive = 0
WHERE 
	PrimaryConsumerId = @PrimaryConsumerId
	AND (IsActive = 1 OR ArchiveDate IS NULL)

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError
	

--Create new baseline, defaulting accordingly (straight-forward, common sense logic)
INSERT INTO Consumer.Baseline (PrimaryConsumerId, CreateDate, UpdateDate, PublishDate, SubmitDate, ArchiveDate, [Version], IsActive, IsLocked, SyncSystemLinkingId)
SELECT PrimaryConsumerId, CreateDate = GETDATE(), UpdateDate = NULL, PublishDate = NULL, SubmitDate = NULL, ArchiveDate = NULL, [Version] = @NewVersion, IsActive = 1, IsLocked = 0, SyncSystemLinkingId
FROM Consumer.Baseline
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError

SELECT @NewBaselineId = @@IDENTITY 	



--Update affiliated client's user mapping to the new active version
UPDATE UM
SET 
	ApplicationMappingId = @NewBaselineId
FROM
	MEMBERSHIP_USER_MAPPING UM
	JOIN MEMBERSHIP_APPLICATIONS M
		ON UM.ApplicationId = M.ApplicationId
			AND M.ApplicationName = 'Client'
	JOIN Consumer.Baseline AB
		ON UM.ApplicationMappingId = AB.BaselineId
			AND UM.ApplicationAccountType IN ('Inclusive', 'Retail')
WHERE 
	AB.PrimaryConsumerId = @PrimaryConsumerId


SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError
			

/*Copy all the Consumer Profile objects (bolier plate stuff) */

INSERT INTO Consumer.AdvisorSurvey (BaselineId, AdvisorTypeCode, AdvisorRankingCode, Comments)
SELECT @NewBaselineId, AdvisorTypeCode, AdvisorRankingCode, Comments
FROM Consumer.AdvisorSurvey
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.AssetProtection (BaselineId, OwnerCode, InsuranceTypeCode, AccountNumber, Insured, InsuranceCompanyName, YearIssued, YearExpiry, AnnualPremium, CoverageAmount, IsEmployerProvided, CurrentValue, PrimaryBeneficiaryCode, SecondaryBeneficiaryCode, Comments, LinkingId, EstimatedYield, IsAutoEntry)
SELECT @NewBaselineId, OwnerCode, InsuranceTypeCode, AccountNumber, Insured, InsuranceCompanyName, YearIssued, YearExpiry, AnnualPremium, CoverageAmount, IsEmployerProvided, CurrentValue, PrimaryBeneficiaryCode, SecondaryBeneficiaryCode, Comments, LinkingId, EstimatedYield, IsAutoEntry
FROM Consumer.AssetProtection
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.BankAsset (BaselineId, OwnerCode, AccountTypeCode, AccountNumber, BankName, AverageMonthlyBalance, MonthlyContribution, IsPrimary, Comments, LinkingId, EstimatedYield)
SELECT @NewBaselineId, OwnerCode, AccountTypeCode, AccountNumber, BankName, AverageMonthlyBalance, MonthlyContribution, IsPrimary, Comments, LinkingId, EstimatedYield
FROM Consumer.BankAsset
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.Budget (BaselineId, Rent, PropertyTaxes, HomeMaintenance, HoaDues, Housekeeping, CityUtility, PowerUtility, Landline, CellPhone, EntertainmentBundle, Food, DiningOut, Clothing, Laundry, MedicalCopays, OtherCopays, Prescriptions, Orthodontist, Tithe, CharitableContributions, Legal, AdditionalChildCare, Education, KidsActivities, HealthClub, Cosmetics, Pets, Vacations, Hobbies, Movies, Magazines, OtherEntertainment, AutoExpenses, RecreationExpenses, Comments, LinkingId)
SELECT @NewBaselineId, Rent, PropertyTaxes, HomeMaintenance, HoaDues, Housekeeping, CityUtility, PowerUtility, Landline, CellPhone, EntertainmentBundle, Food, DiningOut, Clothing, Laundry, MedicalCopays, OtherCopays, Prescriptions, Orthodontist, Tithe, CharitableContributions, Legal, AdditionalChildCare, Education, KidsActivities, HealthClub, Cosmetics, Pets, Vacations, Hobbies, Movies, Magazines, OtherEntertainment, AutoExpenses, RecreationExpenses, Comments, LinkingId
FROM Consumer.Budget
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.CdAsset (BaselineId, OwnerCode, [Description], AccountNumber, InterestRate, MaturityDate, CurrentValue, Comments, LinkingId)
SELECT @NewBaselineId, OwnerCode, [Description], AccountNumber, InterestRate, MaturityDate, CurrentValue, Comments, LinkingId
FROM Consumer.CdAsset
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.EstatePlanning (BaselineId, EstatePlanningTypeCode, Executed, YearDrafted, State, Comments, LinkingId)
SELECT @NewBaselineId, EstatePlanningTypeCode, Executed, YearDrafted, State, Comments, LinkingId
FROM Consumer.EstatePlanning
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.FamilyMember (BaselineId, RelationshipCode, FirstName, MiddleName, LastName, Gender, BirthDate, Phone, Email, Dependent, CollegeExpenses, PhysicalAddressLine, PhysicalCity, PhysicalState, PhysicalZip, Country, Comments, LinkingId)
SELECT @NewBaselineId, RelationshipCode, FirstName, MiddleName, LastName, Gender, BirthDate, Phone, Email, Dependent, CollegeExpenses, PhysicalAddressLine, PhysicalCity, PhysicalState, PhysicalZip, Country, Comments, LinkingId
FROM Consumer.FamilyMember
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.FinancialGoal (BaselineId, OwnerCode, Goal, Amount, IsShortTerm, Priority, CompletedBy, Comments, LinkingId)
SELECT @NewBaselineId, OwnerCode, Goal, Amount, IsShortTerm, Priority, CompletedBy, Comments, LinkingId
FROM Consumer.FinancialGoal
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.FinancialPlan (BaselineId, PrimaryRetirementAge, PrimaryRetiredMonthlyExpenses, PrimaryDeathFund, SecondaryRetirementAge, SecondaryRetiredMonthlyExpenses, SecondaryDeathFund, PrimaryCurrentPlanProjection, PrimaryNewPlanProjection, SecondaryCurrentPlanProjection, SecondaryNewPlanProjection, Comments, LinkingId)
SELECT @NewBaselineId, PrimaryRetirementAge, PrimaryRetiredMonthlyExpenses, PrimaryDeathFund, SecondaryRetirementAge, SecondaryRetiredMonthlyExpenses, SecondaryDeathFund, PrimaryCurrentPlanProjection, PrimaryNewPlanProjection, SecondaryCurrentPlanProjection, SecondaryNewPlanProjection, Comments, LinkingId 
FROM Consumer.FinancialPlan
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.InsuranceProfile (BaselineId, PrimaryLifeInsurancePurpose, PrimaryHeight, PrimaryWeight, PrimaryHaveHealthIssues, PrimaryUseTobacco, PrimaryWhenQuitTobacco, SecondaryLifeInsurancePurpose, SecondaryHeight, SecondaryWeight, SecondaryHaveHealthIssues, SecondaryUseTobacco, SecondaryWhenQuitTobacco, PrimaryHaveBenNotWork, PrimaryYearsBenNotWork, PrimaryHaveCollegePlans, PrimaryIsCollegePrivate, PrimaryFundCollege, SecondaryHaveBenNotWork, SecondaryYearsBenNotWork, SecondaryHaveCollegePlans, SecondaryIsCollegePrivate, SecondaryFundCollege, Comments)
SELECT @NewBaselineId, PrimaryLifeInsurancePurpose, PrimaryHeight, PrimaryWeight, PrimaryHaveHealthIssues, PrimaryUseTobacco, PrimaryWhenQuitTobacco, SecondaryLifeInsurancePurpose, SecondaryHeight, SecondaryWeight, SecondaryHaveHealthIssues, SecondaryUseTobacco, SecondaryWhenQuitTobacco, PrimaryHaveBenNotWork, PrimaryYearsBenNotWork, PrimaryHaveCollegePlans, PrimaryIsCollegePrivate, PrimaryFundCollege, SecondaryHaveBenNotWork, SecondaryYearsBenNotWork, SecondaryHaveCollegePlans, SecondaryIsCollegePrivate, SecondaryFundCollege, Comments
FROM Consumer.InsuranceProfile
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.OtherAsset (BaselineId, OwnerCode, [Description], EstimatedValue, Comments, LinkingId, DepreciationRate)
SELECT @NewBaselineId, OwnerCode, [Description], EstimatedValue, Comments, LinkingId, DepreciationRate
FROM Consumer.OtherAsset
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.OtherLiability (BaselineId, OwnerCode, LiabilityTypeCode, [Description], AccountNumber, InstallmentDate, Term, InterestRate, MonthlyPayment, OriginalBalance, CurrentBalance, Comments, LinkingId, CreditorName, InterestOnlyTerm, InterestOnlyTermDate, InterestOnlyMonthlyPayment)
SELECT @NewBaselineId, OwnerCode, LiabilityTypeCode, [Description], AccountNumber, InstallmentDate, Term, InterestRate, MonthlyPayment, OriginalBalance, CurrentBalance, Comments, LinkingId, CreditorName, InterestOnlyTerm, InterestOnlyTermDate, InterestOnlyMonthlyPayment
FROM Consumer.OtherLiability
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.PersonalAsset (BaselineId, OwnerCode, PersonalPropertyTypeCode, [Description], EstimatedValue, OriginalPurchasePrice, Comments, LinkingId, DepreciationRate)
SELECT @NewBaselineId, OwnerCode, PersonalPropertyTypeCode, [Description], EstimatedValue, OriginalPurchasePrice, Comments, LinkingId, DepreciationRate
FROM Consumer.PersonalAsset
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.PrimaryConsumerIncomeSource (BaselineId, Employer, Title, YearsAtEmployer, EmploymentChanges, WhenRetire, OutstandingStock, GrossSalary, Salary, BonusAndCommission, SelfEmploymentIncome, Pension, SSI, OtherIncome, Comments, LinkingId)
SELECT @NewBaselineId, Employer, Title, YearsAtEmployer, EmploymentChanges, WhenRetire, OutstandingStock, GrossSalary, Salary, BonusAndCommission, SelfEmploymentIncome, Pension, SSI, OtherIncome, Comments, LinkingId
FROM Consumer.PrimaryConsumerIncomeSource
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.PrimaryConsumerIncomeDeductions (BaselineId, RetirementLoanRepaymemt, OtherPayrollDeductionDescription, OtherPayrollDeductionAmount, OtherNonPayrollDeductionDescription, OtherNonPayrollDeductionAmount, FederalTax, Fica, Medicare, StateTax, StateDisabilityInsurance, UnionDue, MedicalHealth, Dental, GroupLifeInsurance, DisabilityInsurance, Comments, RetirementPlanTypeCode, RetirementMonthlyPercentContributions, RetirementMonthlyDollarContributions, RetirementLoanBalance)
SELECT @NewBaselineId, RetirementLoanRepaymemt, OtherPayrollDeductionDescription, OtherPayrollDeductionAmount, OtherNonPayrollDeductionDescription, OtherNonPayrollDeductionAmount, FederalTax, Fica, Medicare, StateTax, StateDisabilityInsurance, UnionDue, MedicalHealth, Dental, GroupLifeInsurance, DisabilityInsurance, Comments, RetirementPlanTypeCode, RetirementMonthlyPercentContributions, RetirementMonthlyDollarContributions, RetirementLoanBalance
FROM Consumer.PrimaryConsumerIncomeDeductions
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.RealEstateAsset (BaselineId, OwnerCode, PropertyTypeCode, [Description], EstimatedValue, OriginalPurchasePrice, Comments, LinkingId, GrossRentalIncome, PropertyExpenses, SummaryOfProperty, EstimatedYield)
SELECT @NewBaselineId, OwnerCode, PropertyTypeCode, [Description], EstimatedValue, OriginalPurchasePrice, Comments, LinkingId, GrossRentalIncome, PropertyExpenses, SummaryOfProperty, EstimatedYield
FROM Consumer.RealEstateAsset
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


--Need to link the old RE Ids to the new
INSERT INTO Consumer.RealEstateLiability (BaselineId, OwnerCode, RealEstateAssetId, MortgageTypeCode, AccountNumber, IsSecondMortgage, InstallmentDate, Term, InterestRate, MonthlyPayment, OriginalBalance, CurrentBalance, Comments, LinkingId, CreditorName, InterestOnlyTerm, InterestOnlyTermDate, InterestOnlyMonthlyPayment)
SELECT @NewBaselineId, L.OwnerCode, NRE.RealEstateAssetId, L.MortgageTypeCode, L.AccountNumber, L.IsSecondMortgage, L.InstallmentDate, L.Term, L.InterestRate, L.MonthlyPayment, L.OriginalBalance, L.CurrentBalance, L.Comments, L.LinkingId, CreditorName, InterestOnlyTerm, InterestOnlyTermDate, InterestOnlyMonthlyPayment
FROM 
	Consumer.RealEstateLiability L
	JOIN Consumer.RealEstateAsset ORE
		ON L.BaselineId = ORE.BaselineId
			AND L.RealEstateAssetId = ORE.RealEstateAssetId
	JOIN Consumer.RealEstateAsset NRE
		ON NRE.BaselineId = @NewBaselineId
			AND ORE.LinkingId = NRE.LinkingId
WHERE 
	L.BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.SecondaryConsumer (BaselineId, RelationshipCode, FirstName, MiddleName, LastName, Gender, BirthDate, HomePhone, WorkPhone, MobilePhone, Email, AlsoKnownBy, PhysicalAddressLine, PhysicalCity, PhysicalState, PhysicalZip, Country, Citizenship, DriverLicense, Comments)
SELECT @NewBaselineId, RelationshipCode, FirstName, MiddleName, LastName, Gender, BirthDate, HomePhone, WorkPhone, MobilePhone, Email, AlsoKnownBy, PhysicalAddressLine, PhysicalCity, PhysicalState, PhysicalZip, Country, Citizenship, DriverLicense, Comments
FROM Consumer.SecondaryConsumer
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.SecondaryConsumerIncomeSource (BaselineId, Employer, Title, YearsAtEmployer, EmploymentChanges, WhenRetire, OutstandingStock, GrossSalary, Salary, BonusAndCommission, SelfEmploymentIncome, Pension, SSI, OtherIncome, Comments, LinkingId)
SELECT @NewBaselineId, Employer, Title, YearsAtEmployer, EmploymentChanges, WhenRetire, OutstandingStock, GrossSalary, Salary, BonusAndCommission, SelfEmploymentIncome, Pension, SSI, OtherIncome, Comments, LinkingId
FROM Consumer.SecondaryConsumerIncomeSource
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.SecondaryConsumerIncomeDeductions (BaselineId, RetirementLoanRepaymemt, OtherPayrollDeductionDescription, OtherPayrollDeductionAmount, OtherNonPayrollDeductionDescription, OtherNonPayrollDeductionAmount, FederalTax, Fica, Medicare, StateTax, StateDisabilityInsurance, UnionDue, MedicalHealth, Dental, GroupLifeInsurance, DisabilityInsurance, Comments, RetirementPlanTypeCode, RetirementMonthlyPercentContributions, RetirementMonthlyDollarContributions, RetirementLoanBalance)
SELECT @NewBaselineId, RetirementLoanRepaymemt, OtherPayrollDeductionDescription, OtherPayrollDeductionAmount, OtherNonPayrollDeductionDescription, OtherNonPayrollDeductionAmount, FederalTax, Fica, Medicare, StateTax, StateDisabilityInsurance, UnionDue, MedicalHealth, Dental, GroupLifeInsurance, DisabilityInsurance, Comments, RetirementPlanTypeCode, RetirementMonthlyPercentContributions, RetirementMonthlyDollarContributions, RetirementLoanBalance
FROM Consumer.SecondaryConsumerIncomeDeductions
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.TaxableInvestmentAsset (BaselineId, OwnerCode, [Description], AccountNumber, EstimatedYield, TotalCostBasis, TotalCurrentValue, MonthlyContribution, Comments, LinkingId)
SELECT @NewBaselineId, OwnerCode, [Description], AccountNumber, EstimatedYield, TotalCostBasis, TotalCurrentValue, MonthlyContribution, Comments, LinkingId
FROM Consumer.TaxableInvestmentAsset
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Consumer.TaxAdvantagedAsset (BaselineId, OwnerCode, PlanTypeCode, [Description], AccountNumber, EmployerMonthlyDollarContributions, EmployerMonthlyPercentContributions, EmployeeMonthlyDollarContributions, EmployeeMonthlyPercentContributions, CurrentAccountValue, PrimaryBeneficiaryCode, SecondaryBeneficiaryCode, Comments, LinkingId, EstimatedYield, IsAutoEntry, EmployerMonthlyPercentMaximum)
SELECT @NewBaselineId, OwnerCode, PlanTypeCode, [Description], AccountNumber, EmployerMonthlyDollarContributions, EmployerMonthlyPercentContributions, EmployeeMonthlyDollarContributions, EmployeeMonthlyPercentContributions, CurrentAccountValue, PrimaryBeneficiaryCode, SecondaryBeneficiaryCode, Comments, LinkingId, EstimatedYield, IsAutoEntry, EmployerMonthlyPercentMaximum
FROM Consumer.TaxAdvantagedAsset
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


--Get the integration stuff now too
INSERT INTO Integration.BaselinePartnerConfig (BaselineId, PartnerCode, IntegrationDirectionCode, IsPartnerSource, ShowManualMapping, EnableAutoSync)
SELECT @NewBaselineId, PartnerCode, IntegrationDirectionCode, IsPartnerSource, ShowManualMapping, EnableAutoSync
FROM Integration.BaselinePartnerConfig
WHERE BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO Integration.BaselineDataMappings (BaselinePartnerConfigId, PartnerRecordId, LocalRecordId, ItemIdentifier, Name, SecondaryDescription, Amount, MiscData, MiscCode, MiscDate, PartnerMappingTypeCode, LocalMappingAreaCode, LocalMappingTypeCode, OwnerCode)
SELECT NBC.BaselinePartnerConfigId, NBM.PartnerRecordId, NBM.LocalRecordId, NBM.ItemIdentifier, NBM.Name, NBM.SecondaryDescription, NBM.Amount, NBM.MiscData, NBM.MiscCode, NBM.MiscDate, NBM.PartnerMappingTypeCode, NBM.LocalMappingAreaCode, NBM.LocalMappingTypeCode, NBM.OwnerCode
FROM 
	Integration.BaselineDataMappings NBM
	JOIN Integration.BaselinePartnerConfig OBC
		ON NBM.BaselinePartnerConfigId = OBC.BaselinePartnerConfigId
	JOIN Integration.BaselinePartnerConfig NBC
		ON NBC.BaselineId = @NewBaselineId
			AND OBC.PartnerCode = NBC.PartnerCode
WHERE 
	OBC.BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError



/* Add in all the MOPro Plan Revision objects to also copy, if applicable   */
IF @HasPlan = 1 OR @MakeIntoPlan = 1 BEGIN

	--TODO: Cannot not have a plan revision as much as I would love to have the app handle the defaults. Not having this
	--causes all kinds of misfortune, so have to default. But concoct a better way to move this into the app
	IF @HasPlan = 0 BEGIN
		INSERT INTO [Plan].PlanRevision (BaselineId, PlanName, ReportTitle, CafrYears, IsScenario, Comments)
		SELECT @NewBaselineId, PlanName = '<new>', ReportTitle = '<new>', CafrYears = 5, IsScenario = 0, Comments = ''
	END ELSE BEGIN
		--HACK: Duplicating some of the app logic about naming (tho only a default and can be changed by user)
		INSERT INTO [Plan].PlanRevision (BaselineId, PlanName, ReportTitle, CafrYears, IsScenario, Comments)
		SELECT 
			@NewBaselineId, 
			PlanName = CASE
				WHEN CHARINDEX('- v', P.PlanName) > 0 THEN SUBSTRING(P.PlanName, 0, CHARINDEX('- v', P.PlanName)) + '- v' + CONVERT(VARCHAR(10), @NewVersion) + ' (' + CONVERT(VARCHAR(10), B.CreateDate, 101) + ')'
				ELSE P.PlanName END, 
			ReportTitle, CafrYears, IsScenario, P.Comments 
		FROM [Plan].PlanRevision P
			JOIN Consumer.Baseline B
				ON P.BaselineId = B.BaselineId
			JOIN Consumer.PrimaryConsumer PC
				ON B.PrimaryConsumerId = PC.PrimaryConsumerId
		WHERE P.BaselineId = @SourceBaselineId
	END

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError


	INSERT INTO [Plan].Recommendation (BaselineId, RecommendationCategoryCode, RecommendationTemplateId, Priority, RecommendationDescription)
	SELECT @NewBaselineId, RecommendationCategoryCode, RecommendationTemplateId, Priority, RecommendationDescription 
	FROM [Plan].Recommendation P
	WHERE P.BaselineId = @SourceBaselineId

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError


	INSERT INTO [Plan].RecommendedRestructureAndTargets (BaselineId, PrimaryPreRetirementReturnRate, PrimaryMiscellaneousDebtRate, RefinanceTypeCode, RefinanceAmount, RefinanceInterest, RefinanceMonthlyPayment, RefinanceCosts, RefinanceDescription, PrimaryRecommendedCoverage, PrimaryEstimatedPremium, SecondaryRecommendedCoverage, SecondaryEstimatedPremium, RecommendedEmergencyFund, DepositToEmergencyFund, RecommendedCashReserve, Phase2NonFirstMortgageDebtReduction, Phase2CashReservesRate, Phase2AlternateNonFirstMortgageDebtReduction, Phase3FirstMortgageDebtReduction, Phase3CashReservesRate, Phase4CashReservesRate)
	SELECT @NewBaselineId, PrimaryPreRetirementReturnRate, PrimaryMiscellaneousDebtRate, RefinanceTypeCode, RefinanceAmount, RefinanceInterest, RefinanceMonthlyPayment, RefinanceCosts, RefinanceDescription, PrimaryRecommendedCoverage, PrimaryEstimatedPremium, SecondaryRecommendedCoverage, SecondaryEstimatedPremium, RecommendedEmergencyFund, DepositToEmergencyFund, RecommendedCashReserve, Phase2NonFirstMortgageDebtReduction, Phase2CashReservesRate, Phase2AlternateNonFirstMortgageDebtReduction, Phase3FirstMortgageDebtReduction, Phase3CashReservesRate, Phase4CashReservesRate 
	FROM [Plan].RecommendedRestructureAndTargets P
	WHERE P.BaselineId = @SourceBaselineId

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError


	INSERT INTO [Plan].RevisedAssetProtection (AssetProtectionId, RevisedAnnualPremium, RevisedCoverageAmount)
	SELECT NC.AssetProtectionId, ISNULL(RevisedAnnualPremium, NC.AnnualPremium), ISNULL(RevisedCoverageAmount, NC.CoverageAmount)
	FROM 
		Consumer.AssetProtection C
		LEFT JOIN [Plan].RevisedAssetProtection P
			ON C.AssetProtectionId = P.AssetProtectionId
		JOIN Consumer.AssetProtection NC
			ON NC.BaselineId = @NewBaselineId
				AND C.LinkingId = NC.LinkingId
	WHERE C.BaselineId = @SourceBaselineId
		--AND (@MakeIntoPlan = 1 OR (@MakeIntoPlan = 0 AND P.AssetProtectionId IS NOT NULL))

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError


	INSERT INTO [Plan].RevisedBankAsset (BankAssetId, RevisedMonthlyContribution)
	SELECT NC.BankAssetId, ISNULL(RevisedMonthlyContribution, NC.MonthlyContribution)
	FROM 
		Consumer.BankAsset C
		LEFT JOIN [Plan].RevisedBankAsset P
			ON P.BankAssetId = C.BankAssetId
		JOIN Consumer.BankAsset NC
			ON NC.BaselineId = @NewBaselineId
				AND C.LinkingId = NC.LinkingId
	WHERE C.BaselineId = @SourceBaselineId
		--AND (@MakeIntoPlan = 1 OR (@MakeIntoPlan = 0 AND P.BankAssetId IS NOT NULL))

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError


	--TODO: Figure out how to default the guidelines without adding all that business awareness here.
	INSERT INTO [Plan].RevisedBudget (BudgetId, RevisedRent, RevisedPropertyTaxes, RevisedHomeMaintenance, RevisedHoaDues, RevisedHousekeeping, RevisedCityUtility, RevisedPowerUtility, RevisedLandline, RevisedCellPhone, RevisedEntertainmentBundle, RevisedFood, RevisedDiningOut, RevisedClothing, RevisedLaundry, RevisedMedicalCopays, RevisedOtherCopays, RevisedPrescriptions, RevisedOrthodontist, RevisedTithe, RevisedCharitableContributions, RevisedLegal, RevisedAdditionalChildCare, RevisedEducation, RevisedKidsActivities, RevisedHealthClub, RevisedCosmetics, RevisedPets, RevisedVacations, RevisedHobbies, RevisedMovies, RevisedMagazines, RevisedOtherEntertainment, RevisedAutoExpenses, RevisedRecreationExpenses, HousingStandardGuideline, FoodStandardGuideline, HealthStandardGuideline, GivingStandardGuideline, InvestmentsStandardGuideline, ClothingStandardGuideline, AutomobileFoodStandardGuideline, MiscStandardGuideline, OtherStandardGuideline, DebtStandardGuideline)
	SELECT NC.BudgetId, ISNULL(RevisedRent, NC.Rent), ISNULL(RevisedPropertyTaxes, NC.PropertyTaxes), ISNULL(RevisedHomeMaintenance, NC.HomeMaintenance), ISNULL(RevisedHoaDues, NC.HoaDues), ISNULL(RevisedHousekeeping, NC.Housekeeping), ISNULL(RevisedCityUtility, NC.CityUtility), ISNULL(RevisedPowerUtility, NC.PowerUtility), ISNULL(RevisedLandline, NC.Landline), ISNULL(RevisedCellPhone, NC.CellPhone), ISNULL(RevisedEntertainmentBundle, NC.EntertainmentBundle), ISNULL(RevisedFood, NC.Food), ISNULL(RevisedDiningOut, NC.DiningOut), ISNULL(RevisedClothing, NC.Clothing), ISNULL(RevisedLaundry, NC.Laundry), ISNULL(RevisedMedicalCopays, NC.MedicalCopays), ISNULL(RevisedOtherCopays, NC.OtherCopays), ISNULL(RevisedPrescriptions, NC.Prescriptions), ISNULL(RevisedOrthodontist, NC.Orthodontist), ISNULL(RevisedTithe, NC.Tithe), ISNULL(RevisedCharitableContributions, NC.CharitableContributions), ISNULL(RevisedLegal, NC.Legal), ISNULL(RevisedAdditionalChildCare, NC.AdditionalChildCare), ISNULL(RevisedEducation, NC.Education), ISNULL(RevisedKidsActivities, NC.KidsActivities), ISNULL(RevisedHealthClub, NC.HealthClub), ISNULL(RevisedCosmetics, NC.Cosmetics), ISNULL(RevisedPets, NC.Pets), ISNULL(RevisedVacations, NC.Vacations), ISNULL(RevisedHobbies, NC.Hobbies), ISNULL(RevisedMovies, NC.Movies), ISNULL(RevisedMagazines, NC.Magazines), ISNULL(RevisedOtherEntertainment, NC.OtherEntertainment), ISNULL(RevisedAutoExpenses, NC.AutoExpenses), ISNULL(RevisedRecreationExpenses, NC.RecreationExpenses), ISNULL(HousingStandardGuideline, 0), ISNULL(FoodStandardGuideline, 0), ISNULL(HealthStandardGuideline, 0), ISNULL(GivingStandardGuideline, 0), ISNULL(InvestmentsStandardGuideline, 0), ISNULL(ClothingStandardGuideline, 0), ISNULL(AutomobileFoodStandardGuideline, 0), ISNULL(MiscStandardGuideline, 0), ISNULL(OtherStandardGuideline, 0), ISNULL(DebtStandardGuideline, 0)
	FROM 
		Consumer.Budget C
		LEFT JOIN [Plan].RevisedBudget P
			ON C.BudgetId = P.BudgetId
		JOIN Consumer.Budget NC
			ON NC.BaselineId = @NewBaselineId
				AND C.LinkingId = NC.LinkingId
	WHERE C.BaselineId = @SourceBaselineId
		--AND (@MakeIntoPlan = 1 OR (@MakeIntoPlan = 0 AND P.BudgetId IS NOT NULL))

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError


	INSERT INTO [Plan].RevisedRealEstateLiability (RealEstateLiabilityId, RevisedMonthlyPayment, RevisedCurrentBalance)
	SELECT NC.RealEstateLiabilityId, ISNULL(RevisedMonthlyPayment, NC.MonthlyPayment), ISNULL(RevisedCurrentBalance, NC.CurrentBalance)
	FROM 
		Consumer.RealEstateLiability C
		LEFT JOIN [Plan].RevisedRealEstateLiability P
			ON C.RealEstateLiabilityId = P.RealEstateLiabilityId
		JOIN Consumer.RealEstateLiability NC
			ON NC.BaselineId = @NewBaselineId
				AND C.LinkingId = NC.LinkingId
	WHERE C.BaselineId = @SourceBaselineId
		--AND (@MakeIntoPlan = 1 OR (@MakeIntoPlan = 0 AND P.RealEstateLiabilityId IS NOT NULL))

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError


	INSERT INTO [Plan].RevisedOtherLiability (OtherLiabilityId, RevisedMonthlyPayment, RevisedCurrentBalance)
	SELECT NC.OtherLiabilityId, ISNULL(RevisedMonthlyPayment, NC.MonthlyPayment), ISNULL(RevisedCurrentBalance, NC.CurrentBalance)
	FROM 
		Consumer.OtherLiability C
		LEFT JOIN [Plan].RevisedOtherLiability P
			ON C.OtherLiabilityId = P.OtherLiabilityId
		JOIN Consumer.OtherLiability NC
			ON NC.BaselineId = @NewBaselineId
				AND C.LinkingId = NC.LinkingId
	WHERE C.BaselineId = @SourceBaselineId
		--AND (@MakeIntoPlan = 1 OR (@MakeIntoPlan = 0 AND P.OtherLiabilityId IS NOT NULL))

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError


	INSERT INTO [Plan].RevisedTaxableInvestmentAsset (TaxableInvestmentAssetId, RevisedMonthlyContribution)
	SELECT NC.TaxableInvestmentAssetId, ISNULL(RevisedMonthlyContribution, NC.MonthlyContribution)
	FROM 
		Consumer.TaxableInvestmentAsset C
		LEFT JOIN [Plan].RevisedTaxableInvestmentAsset P
			ON C.TaxableInvestmentAssetId = P.TaxableInvestmentAssetId
		JOIN Consumer.TaxableInvestmentAsset NC
			ON NC.BaselineId = @NewBaselineId
				AND C.LinkingId = NC.LinkingId
	WHERE C.BaselineId = @SourceBaselineId
		--AND (@MakeIntoPlan = 1 OR (@MakeIntoPlan = 0 AND P.TaxableInvestmentAssetId IS NOT NULL))

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError


	INSERT INTO [Plan].RevisedTaxAdvantagedAsset (TaxAdvantagedAssetId, RevisedEmployeeMonthlyDollarContributions, RevisedEmployeeMonthlyPercentContributions)
	SELECT NC.TaxAdvantagedAssetId, ISNULL(RevisedEmployeeMonthlyDollarContributions, NC.EmployeeMonthlyDollarContributions), ISNULL(RevisedEmployeeMonthlyPercentContributions, NC.EmployeeMonthlyPercentContributions)
	FROM 
		Consumer.TaxAdvantagedAsset C
		LEFT JOIN [Plan].RevisedTaxAdvantagedAsset P
			ON C.TaxAdvantagedAssetId = P.TaxAdvantagedAssetId
		JOIN Consumer.TaxAdvantagedAsset NC
			ON NC.BaselineId = @NewBaselineId
				AND C.LinkingId = NC.LinkingId
	WHERE C.BaselineId = @SourceBaselineId
		--AND (@MakeIntoPlan = 1 OR (@MakeIntoPlan = 0 AND P.TaxAdvantagedAssetId IS NOT NULL))

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

END



COMMIT TRAN

SELECT @NewBaselineId
RETURN @NewBaselineId

HandleError:
	IF @Error <> 0 BEGIN
	   ROLLBACK TRAN
	   RETURN @Error
	END


GO



PRINT 'Add [DeleteVersion] proc' 
IF OBJECT_ID(N'[Advisor].[DeleteVersion]') IS NOT NULL 
	DROP PROC [Advisor].[DeleteVersion] 
GO
CREATE PROC [Advisor].[DeleteVersion] (
	@TargetBaselineId INT 
) 
AS
--NOTE: This should truly be a domain service in the app. However, the justification for using a proc instead is due to
--	not having any logic really whatsoever contained here so basically just a grunt operation and the sheer volume of objects
--	touched just to delete so would be vey expensive doing in the domain 

DECLARE 
	@Error INT,
	@BaselineCount INT,
	@PrimaryConsumerId INT,
	@UserMappingId INT,
	@HasPlan BIT

SELECT 
	@PrimaryConsumerId = S.PrimaryConsumerId,
	@BaselineCount = (SELECT COUNT(*) FROM Consumer.Baseline WHERE PrimaryConsumerId = S.PrimaryConsumerId),
	@UserMappingId = MAX(UM.UserMappingId),
	@HasPlan = CASE WHEN MAX(P.BaselineId) IS NOT NULL THEN 1 ELSE 0 END
FROM 
	Consumer.Baseline S
	JOIN (
		MEMBERSHIP_USER_MAPPING UM
		JOIN MEMBERSHIP_APPLICATIONS M
			ON UM.ApplicationId = M.ApplicationId
				AND UM.ApplicationAccountType IN ('Inclusive', 'Retail')
				AND M.ApplicationName = 'Client'
		JOIN Consumer.Baseline AB
			ON UM.ApplicationMappingId = AB.BaselineId
		) ON S.PrimaryConsumerId = AB.PrimaryConsumerId
	LEFT JOIN [Plan].PlanRevision P
		ON S.BaselineId = P.BaselineId
WHERE 
	S.BaselineId = @TargetBaselineId
GROUP BY 
	S.PrimaryConsumerId


BEGIN TRAN
		
IF NOT EXISTS (SELECT * FROM Consumer.Baseline WHERE BaselineId = @TargetBaselineId) BEGIN
	PRINT 'Cannot delete due to not being found'
	RAISERROR (50005, 11, 1, 'Version', 'it cannot be found.')
	SET @Error = @@ERROR
	GOTO HandleError
END ELSE IF EXISTS (SELECT * FROM Consumer.Baseline WHERE BaselineId = @TargetBaselineId AND IsActive = 1) BEGIN
	PRINT 'Cannot delete due to still being active'
	RAISERROR (50005, 11, 1, 'Version', 'it is still active. Either copy this one to make it inactive first or deactivate the client, before you can delete this one.')
	SET @Error = @@ERROR
	GOTO HandleError
END


/*Delete all the MOPro Plan Revision objects (has to be before baseline objects due to dependency), if applicable   */
IF @HasPlan = 1 BEGIN

	DELETE FROM [Plan].Recommendation WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

	DELETE FROM [Plan].RecommendedRestructureAndTargets WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

	DELETE P 
	FROM [Plan].RevisedAssetProtection P JOIN Consumer.AssetProtection C ON P.AssetProtectionId = C.AssetProtectionId 
	WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

	DELETE P 
	FROM [Plan].RevisedBankAsset P JOIN Consumer.BankAsset C ON P.BankAssetId = C.BankAssetId 
	WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

	DELETE P 
	FROM [Plan].RevisedBudget P JOIN Consumer.Budget C ON P.BudgetId = C.BudgetId 
	WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

	DELETE P 
	FROM [Plan].RevisedOtherLiability P JOIN Consumer.OtherLiability C ON P.OtherLiabilityId = C.OtherLiabilityId 
	WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

	DELETE P 
	FROM [Plan].RevisedRealEstateLiability P JOIN Consumer.RealEstateLiability C ON P.RealEstateLiabilityId = C.RealEstateLiabilityId 
	WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

	DELETE P 
	FROM [Plan].RevisedTaxableInvestmentAsset P JOIN Consumer.TaxableInvestmentAsset C ON P.TaxableInvestmentAssetId = C.TaxableInvestmentAssetId 
	WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

	DELETE P 
	FROM [Plan].RevisedTaxAdvantagedAsset P JOIN Consumer.TaxAdvantagedAsset C ON P.TaxAdvantagedAssetId = C.TaxAdvantagedAssetId 
	WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

	DELETE FROM [Plan].PlanRevision WHERE BaselineId = @TargetBaselineId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError

END

/*Delete all the Consumer Profile objects (boiler plate stuff) */

--This one has a dependency so delete them before trying to delete the dependency
DELETE FROM Consumer.RealEstateLiability WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.AdvisorSurvey WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.AssetProtection WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.BankAsset WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.BaselineStatus WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.Budget WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.CdAsset WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.EstatePlanning WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.FamilyMember WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.FinancialGoal WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.FinancialPlan WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.InsuranceProfile WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.OtherAsset WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.OtherLiability WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.PersonalAsset WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.PrimaryConsumerIncomeSource WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.PrimaryConsumerIncomeDeductions WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.RealEstateAsset WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.SecondaryConsumerIncomeSource WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.SecondaryConsumerIncomeDeductions WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.TaxableInvestmentAsset WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.TaxAdvantagedAsset WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Consumer.SecondaryConsumer WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


--Get the integration stuff too
DELETE BM 
FROM 
	Integration.BaselineDataMappings BM
	JOIN Integration.BaselinePartnerConfig BC
		ON BM.BaselinePartnerConfigId = BC.BaselinePartnerConfigId
WHERE 
	BC.BaselineId = @TargetBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


DELETE FROM Integration.BaselinePartnerConfig WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError



DELETE FROM Consumer.Baseline WHERE BaselineId = @TargetBaselineId
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError

--Delete the actual client and user (and supporting values) if last baseline (and we know is already inactive)
IF @BaselineCount = 1 BEGIN
	DELETE FROM Consumer.PrimaryConsumer WHERE PrimaryConsumerId = @PrimaryConsumerId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError
	
	DECLARE 
		@UserId UNIQUEIDENTIFIER,
		@RootUserId UNIQUEIDENTIFIER,
		@ApplicationId UNIQUEIDENTIFIER,
		@RootApplicationId UNIQUEIDENTIFIER
		
	SELECT @RootApplicationId = ApplicationId FROM MEMBERSHIP_APPLICATIONS WHERE ApplicationName = 'Root'
		
	SELECT @RootUserId = UserId, @ApplicationId = ApplicationId FROM MEMBERSHIP_USER_MAPPING WHERE UserMappingId = @UserMappingId
	DELETE FROM MEMBERSHIP_USER_MAPPING WHERE UserMappingId = @UserMappingId
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError
	
	SELECT @UserId = AU.UserId 
	FROM 
		MEMBERSHIP_USERS AU
		JOIN MEMBERSHIP_USERS RU
			ON AU.UserName = RU.UserName
				AND AU.ApplicationId = @ApplicationId
	WHERE 
		RU.UserId = @RootUserId
		
	DELETE FROM MEMBERSHIP_USER_ROLES WHERE UserId IN (@UserId, @RootUserId)
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError
		
	DELETE FROM MEMBERSHIP_PROFILES WHERE UserId IN (@UserId, @RootUserId)
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError
		
	DELETE FROM MEMBERSHIP_LOGINS WHERE UserId IN (@UserId, @RootUserId)
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError
		
	DELETE FROM MEMBERSHIP_USERS WHERE UserId IN (@UserId, @RootUserId)
	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError
	
END
	
	
COMMIT TRAN

HandleError:
	IF @Error <> 0 BEGIN
	   ROLLBACK TRAN
	   RETURN @Error
	END

GO






PRINT 'Add [ConvertVersionToPlan] proc' 
IF OBJECT_ID(N'[Advisor].[ConvertVersionToPlan]') IS NOT NULL 
	DROP PROC [Advisor].[ConvertVersionToPlan] 
GO
CREATE PROC [Advisor].[ConvertVersionToPlan] (
	@SourceBaselineId INT --Source version to convert
) 
AS

--NOTE: This should truly be a domain service in the app. However, the justification for using a proc instead is due to
--	not having any logic really whatsoever contained here so basically just a grunt operation and the sheer volume of objects
--	touched just to copy so would be vey expensive doing in the domain for an operation that will be used frequently

DECLARE 
	@Error INT,
	@NeedsReview BIT,
	@HasPlan BIT

SELECT 
	@NeedsReview = S.NeedsReview,
	@HasPlan = CASE WHEN P.BaselineId IS NOT NULL THEN 1 ELSE 0 END
FROM 
	Consumer.Baseline S
	LEFT JOIN [Plan].PlanRevision P
		ON S.BaselineId = P.BaselineId
WHERE S.BaselineId = @SourceBaselineId


--TODO: Confirm this logic is airtight
IF @NeedsReview = 0 AND @HasPlan = 1 BEGIN
	SELECT @SourceBaselineId
	RETURN @SourceBaselineId
END


BEGIN TRAN
	

--Must have this Plan Revision placeholder from the get-go
IF @HasPlan = 0 BEGIN
	INSERT INTO [Plan].PlanRevision (BaselineId, PlanName, ReportTitle, CafrYears, IsScenario, Comments)
	SELECT @SourceBaselineId, PlanName = '<new>', ReportTitle = '<new>', CafrYears = 5, IsScenario = 0, Comments = ''
END 


/* Add in all the MOPro Plan Revision objects to also copy, if applicable   */

INSERT INTO [Plan].RevisedAssetProtection (AssetProtectionId, RevisedAnnualPremium, RevisedCoverageAmount)
SELECT C.AssetProtectionId, C.AnnualPremium, C.CoverageAmount
FROM 
	Consumer.AssetProtection C
	LEFT JOIN [Plan].RevisedAssetProtection P
		ON C.AssetProtectionId = P.AssetProtectionId
WHERE C.BaselineId = @SourceBaselineId
	AND P.AssetProtectionId IS NULL

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO [Plan].RevisedBankAsset (BankAssetId, RevisedMonthlyContribution)
SELECT C.BankAssetId, C.MonthlyContribution
FROM 
	Consumer.BankAsset C
	LEFT JOIN [Plan].RevisedBankAsset P
		ON P.BankAssetId = C.BankAssetId
WHERE C.BaselineId = @SourceBaselineId
	AND P.BankAssetId IS NULL

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


--TODO: Revist if we should be creating a budget here too, if not available. We have a dependency check 
--	handling that now but that happens after this...should just remove the dependency check then for now since this will always run first
IF NOT EXISTS(SELECT * FROM Consumer.Budget WHERE BaselineId = @SourceBaselineId) BEGIN
	INSERT INTO Consumer.Budget (BaselineId, Comments, LinkingId)
	SELECT @SourceBaselineId, '', NEWID()

	SET @Error = @@ERROR
	IF @Error <> 0 GOTO HandleError
END

--TODO: Figure out how to default the guidelines without adding all that business awareness here.
INSERT INTO [Plan].RevisedBudget (BudgetId, RevisedRent, RevisedPropertyTaxes, RevisedHomeMaintenance, RevisedHoaDues, RevisedHousekeeping, RevisedCityUtility, RevisedPowerUtility, RevisedLandline, RevisedCellPhone, RevisedEntertainmentBundle, RevisedFood, RevisedDiningOut, RevisedClothing, RevisedLaundry, RevisedMedicalCopays, RevisedOtherCopays, RevisedPrescriptions, RevisedOrthodontist, RevisedTithe, RevisedCharitableContributions, RevisedLegal, RevisedAdditionalChildCare, RevisedEducation, RevisedKidsActivities, RevisedHealthClub, RevisedCosmetics, RevisedPets, RevisedVacations, RevisedHobbies, RevisedMovies, RevisedMagazines, RevisedOtherEntertainment, RevisedAutoExpenses, RevisedRecreationExpenses, HousingStandardGuideline, FoodStandardGuideline, HealthStandardGuideline, GivingStandardGuideline, InvestmentsStandardGuideline, ClothingStandardGuideline, AutomobileFoodStandardGuideline, MiscStandardGuideline, OtherStandardGuideline, DebtStandardGuideline)
SELECT C.BudgetId, C.Rent, C.PropertyTaxes, C.HomeMaintenance, C.HoaDues, C.Housekeeping, C.CityUtility, C.PowerUtility, C.Landline, C.CellPhone, C.EntertainmentBundle, C.Food, C.DiningOut, C.Clothing, C.Laundry, C.MedicalCopays, C.OtherCopays, C.Prescriptions, C.Orthodontist, C.Tithe, C.CharitableContributions, C.Legal, C.AdditionalChildCare, C.Education, C.KidsActivities, C.HealthClub, C.Cosmetics, C.Pets, C.Vacations, C.Hobbies, C.Movies, C.Magazines, C.OtherEntertainment, C.AutoExpenses, C.RecreationExpenses, HousingStandardGuideline = 0, FoodStandardGuideline = 0, HealthStandardGuideline = 0, GivingStandardGuideline = 0, InvestmentsStandardGuideline = 0, ClothingStandardGuideline = 0, AutomobileFoodStandardGuideline = 0, MiscStandardGuideline = 0, OtherStandardGuideline = 0, DebtStandardGuideline = 0
FROM 
	Consumer.Budget C
	LEFT JOIN [Plan].RevisedBudget P
		ON C.BudgetId = P.BudgetId
WHERE C.BaselineId = @SourceBaselineId
	AND P.BudgetId IS NULL

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO [Plan].RevisedRealEstateLiability (RealEstateLiabilityId, RevisedMonthlyPayment, RevisedCurrentBalance)
SELECT C.RealEstateLiabilityId, C.MonthlyPayment, C.CurrentBalance
FROM 
	Consumer.RealEstateLiability C
	LEFT JOIN [Plan].RevisedRealEstateLiability P
		ON C.RealEstateLiabilityId = P.RealEstateLiabilityId
WHERE C.BaselineId = @SourceBaselineId
	AND P.RealEstateLiabilityId IS NULL

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO [Plan].RevisedOtherLiability (OtherLiabilityId, RevisedMonthlyPayment, RevisedCurrentBalance)
SELECT C.OtherLiabilityId, C.MonthlyPayment, C.CurrentBalance
FROM 
	Consumer.OtherLiability C
	LEFT JOIN [Plan].RevisedOtherLiability P
		ON C.OtherLiabilityId = P.OtherLiabilityId
WHERE C.BaselineId = @SourceBaselineId
	AND P.OtherLiabilityId IS NULL

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO [Plan].RevisedTaxableInvestmentAsset (TaxableInvestmentAssetId, RevisedMonthlyContribution)
SELECT C.TaxableInvestmentAssetId, C.MonthlyContribution
FROM 
	Consumer.TaxableInvestmentAsset C
	LEFT JOIN [Plan].RevisedTaxableInvestmentAsset P
		ON C.TaxableInvestmentAssetId = P.TaxableInvestmentAssetId
WHERE C.BaselineId = @SourceBaselineId
	AND P.TaxableInvestmentAssetId IS NULL

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


INSERT INTO [Plan].RevisedTaxAdvantagedAsset (TaxAdvantagedAssetId, RevisedEmployeeMonthlyDollarContributions, RevisedEmployeeMonthlyPercentContributions)
SELECT C.TaxAdvantagedAssetId, C.EmployeeMonthlyDollarContributions, C.EmployeeMonthlyPercentContributions
FROM 
	Consumer.TaxAdvantagedAsset C
	LEFT JOIN [Plan].RevisedTaxAdvantagedAsset P
		ON C.TaxAdvantagedAssetId = P.TaxAdvantagedAssetId
WHERE C.BaselineId = @SourceBaselineId
	AND P.TaxAdvantagedAssetId IS NULL

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


--Reset the flag now that reviewing (since opening a plan is what initiated this process)
UPDATE Consumer.Baseline
SET
	NeedsReview = 0
WHERE 
	BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


COMMIT TRAN


SELECT @SourceBaselineId
RETURN @SourceBaselineId


HandleError:
	IF @Error <> 0 BEGIN
	   ROLLBACK TRAN
	   RETURN @Error
	END

GO



PRINT 'Add [CopyCurrentAmountsToRevised] proc' 
IF OBJECT_ID(N'[Advisor].[CopyCurrentAmountsToRevised]') IS NOT NULL 
	DROP PROC [Advisor].[CopyCurrentAmountsToRevised] 
GO
CREATE PROC [Advisor].[CopyCurrentAmountsToRevised] (
	@SourceBaselineId INT, --Source version to copy
	@FullReset BIT = 0 --Indicates if wiping out any and all revised values or only when revised is 0
) 
AS

DECLARE 
	@Error INT


BEGIN TRAN

UPDATE P
SET
	RevisedAnnualPremium = CASE WHEN @FullReset = 1 OR P.RevisedAnnualPremium = 0 THEN C.AnnualPremium ELSE P.RevisedAnnualPremium END, 
	RevisedCoverageAmount = CASE WHEN @FullReset = 1 OR P.RevisedCoverageAmount = 0 THEN C.CoverageAmount ELSE P.RevisedCoverageAmount END
FROM 
	Consumer.AssetProtection C
	JOIN [Plan].RevisedAssetProtection P
		ON C.AssetProtectionId = P.AssetProtectionId
WHERE C.BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE P
SET
	RevisedMonthlyContribution = CASE WHEN @FullReset = 1 OR P.RevisedMonthlyContribution = 0 THEN C.MonthlyContribution ELSE P.RevisedMonthlyContribution END
FROM 
	Consumer.BankAsset C
	JOIN [Plan].RevisedBankAsset P
		ON P.BankAssetId = C.BankAssetId
WHERE C.BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE P
SET
	RevisedRent = CASE WHEN @FullReset = 1 OR P.RevisedRent = 0 THEN C.Rent ELSE P.RevisedRent END,
	RevisedPropertyTaxes = CASE WHEN @FullReset = 1 OR P.RevisedPropertyTaxes = 0 THEN C.PropertyTaxes ELSE P.RevisedPropertyTaxes END,
	RevisedHomeMaintenance = CASE WHEN @FullReset = 1 OR P.RevisedHomeMaintenance = 0 THEN C.HomeMaintenance ELSE P.RevisedHomeMaintenance END,
	RevisedHoaDues = CASE WHEN @FullReset = 1 OR P.RevisedHoaDues = 0 THEN C.HoaDues ELSE P.RevisedHoaDues END,
	RevisedHousekeeping = CASE WHEN @FullReset = 1 OR P.RevisedHousekeeping = 0 THEN C.Housekeeping ELSE P.RevisedHousekeeping END,
	RevisedCityUtility = CASE WHEN @FullReset = 1 OR P.RevisedCityUtility = 0 THEN C.CityUtility ELSE P.RevisedCityUtility END,
	RevisedPowerUtility = CASE WHEN @FullReset = 1 OR P.RevisedPowerUtility = 0 THEN C.PowerUtility ELSE P.RevisedPowerUtility END,
	RevisedLandline = CASE WHEN @FullReset = 1 OR P.RevisedLandline = 0 THEN C.Landline ELSE P.RevisedLandline END,
	RevisedCellPhone = CASE WHEN @FullReset = 1 OR P.RevisedCellPhone = 0 THEN C.CellPhone ELSE P.RevisedCellPhone END,
	RevisedEntertainmentBundle = CASE WHEN @FullReset = 1 OR P.RevisedEntertainmentBundle = 0 THEN C.EntertainmentBundle ELSE P.RevisedEntertainmentBundle END,
	RevisedFood = CASE WHEN @FullReset = 1 OR P.RevisedFood = 0 THEN C.Food ELSE P.RevisedFood END,
	RevisedDiningOut = CASE WHEN @FullReset = 1 OR P.RevisedDiningOut = 0 THEN C.DiningOut ELSE P.RevisedDiningOut END,
	RevisedClothing = CASE WHEN @FullReset = 1 OR P.RevisedClothing = 0 THEN C.Clothing ELSE P.RevisedClothing END,
	RevisedLaundry = CASE WHEN @FullReset = 1 OR P.RevisedLaundry = 0 THEN C.Laundry ELSE P.RevisedLaundry END,
	RevisedMedicalCopays = CASE WHEN @FullReset = 1 OR P.RevisedMedicalCopays = 0 THEN C.MedicalCopays ELSE P.RevisedMedicalCopays END,
	RevisedOtherCopays = CASE WHEN @FullReset = 1 OR P.RevisedOtherCopays = 0 THEN C.OtherCopays ELSE P.RevisedOtherCopays END,
	RevisedPrescriptions = CASE WHEN @FullReset = 1 OR P.RevisedPrescriptions = 0 THEN C.Prescriptions ELSE P.RevisedPrescriptions END,
	RevisedOrthodontist = CASE WHEN @FullReset = 1 OR P.RevisedOrthodontist = 0 THEN C.Orthodontist ELSE P.RevisedOrthodontist END,
	RevisedTithe = CASE WHEN @FullReset = 1 OR P.RevisedTithe = 0 THEN C.Tithe ELSE P.RevisedTithe END,
	RevisedCharitableContributions = CASE WHEN @FullReset = 1 OR P.RevisedCharitableContributions = 0 THEN C.CharitableContributions ELSE P.RevisedCharitableContributions END,
	RevisedLegal = CASE WHEN @FullReset = 1 OR P.RevisedLegal = 0 THEN C.Legal ELSE P.RevisedLegal END,
	RevisedAdditionalChildCare = CASE WHEN @FullReset = 1 OR P.RevisedAdditionalChildCare = 0 THEN C.AdditionalChildCare ELSE P.RevisedAdditionalChildCare END,
	RevisedEducation = CASE WHEN @FullReset = 1 OR P.RevisedEducation = 0 THEN C.Education ELSE P.RevisedEducation END,
	RevisedKidsActivities = CASE WHEN @FullReset = 1 OR P.RevisedKidsActivities = 0 THEN C.KidsActivities ELSE P.RevisedKidsActivities END,
	RevisedHealthClub = CASE WHEN @FullReset = 1 OR P.RevisedHealthClub = 0 THEN C.HealthClub ELSE P.RevisedHealthClub END,
	RevisedCosmetics = CASE WHEN @FullReset = 1 OR P.RevisedCosmetics = 0 THEN C.Cosmetics ELSE P.RevisedCosmetics END,
	RevisedPets = CASE WHEN @FullReset = 1 OR P.RevisedPets = 0 THEN C.Pets ELSE P.RevisedPets END,
	RevisedVacations = CASE WHEN @FullReset = 1 OR P.RevisedVacations = 0 THEN C.Vacations ELSE P.RevisedVacations END,
	RevisedHobbies = CASE WHEN @FullReset = 1 OR P.RevisedHobbies = 0 THEN C.Hobbies ELSE P.RevisedHobbies END,
	RevisedMovies = CASE WHEN @FullReset = 1 OR P.RevisedMovies = 0 THEN C.Movies ELSE P.RevisedMovies END,
	RevisedMagazines = CASE WHEN @FullReset = 1 OR P.RevisedMagazines = 0 THEN C.Magazines ELSE P.RevisedMagazines END,
	RevisedOtherEntertainment = CASE WHEN @FullReset = 1 OR P.RevisedOtherEntertainment = 0 THEN C.OtherEntertainment ELSE P.RevisedOtherEntertainment END,
	RevisedAutoExpenses = CASE WHEN @FullReset = 1 OR P.RevisedAutoExpenses = 0 THEN C.AutoExpenses ELSE P.RevisedAutoExpenses END,
	RevisedRecreationExpenses = CASE WHEN @FullReset = 1 OR P.RevisedRecreationExpenses = 0 THEN C.RecreationExpenses ELSE P.RevisedRecreationExpenses END
FROM 
	Consumer.Budget C
	JOIN [Plan].RevisedBudget P
		ON C.BudgetId = P.BudgetId
WHERE C.BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE P
SET
	RevisedMonthlyPayment = CASE WHEN @FullReset = 1 OR P.RevisedMonthlyPayment = 0 THEN C.MonthlyPayment ELSE P.RevisedMonthlyPayment END, 
	RevisedCurrentBalance = CASE WHEN @FullReset = 1 OR P.RevisedCurrentBalance = 0 THEN C.CurrentBalance ELSE P.RevisedCurrentBalance END 
FROM 
	Consumer.RealEstateLiability C
	JOIN [Plan].RevisedRealEstateLiability P
		ON C.RealEstateLiabilityId = P.RealEstateLiabilityId
WHERE C.BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE P
SET
	RevisedMonthlyPayment = CASE WHEN @FullReset = 1 OR P.RevisedMonthlyPayment = 0 THEN C.MonthlyPayment ELSE P.RevisedMonthlyPayment END, 
	RevisedCurrentBalance = CASE WHEN @FullReset = 1 OR P.RevisedCurrentBalance = 0 THEN C.CurrentBalance ELSE P.RevisedCurrentBalance END 
FROM 
	Consumer.OtherLiability C
	JOIN [Plan].RevisedOtherLiability P
		ON C.OtherLiabilityId = P.OtherLiabilityId
WHERE C.BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE P
SET
	RevisedMonthlyContribution = CASE WHEN @FullReset = 1 OR P.RevisedMonthlyContribution = 0 THEN C.MonthlyContribution ELSE P.RevisedMonthlyContribution END 
FROM 
	Consumer.TaxableInvestmentAsset C
	JOIN [Plan].RevisedTaxableInvestmentAsset P
		ON C.TaxableInvestmentAssetId = P.TaxableInvestmentAssetId
WHERE C.BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE P
SET
	RevisedEmployeeMonthlyDollarContributions = CASE WHEN @FullReset = 1 OR P.RevisedEmployeeMonthlyDollarContributions = 0 THEN C.EmployeeMonthlyDollarContributions ELSE P.RevisedEmployeeMonthlyDollarContributions END, 
	RevisedEmployeeMonthlyPercentContributions = CASE WHEN @FullReset = 1 OR P.RevisedEmployeeMonthlyPercentContributions = 0 THEN C.EmployeeMonthlyPercentContributions ELSE P.RevisedEmployeeMonthlyPercentContributions END 
FROM 
	Consumer.TaxAdvantagedAsset C
	JOIN [Plan].RevisedTaxAdvantagedAsset P
		ON C.TaxAdvantagedAssetId = P.TaxAdvantagedAssetId
WHERE C.BaselineId = @SourceBaselineId

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


COMMIT TRAN


SELECT @SourceBaselineId
RETURN @SourceBaselineId


HandleError:
	IF @Error <> 0 BEGIN
	   ROLLBACK TRAN
	   RETURN @Error
	END

GO




PRINT 'Add [UpdateMappingDataFromLocal] proc' 
IF OBJECT_ID(N'[Integration].[UpdateMappingDataFromLocal]') IS NOT NULL 
	DROP PROC [Integration].[UpdateMappingDataFromLocal] 
GO
CREATE PROC [Integration].[UpdateMappingDataFromLocal] (
	@SourceId INT, 
	@PartnerCode VARCHAR(8)
) 
AS

DECLARE 
	@Error INT,
	@BaselinePartnerConfigId INT,
	@PartnerClientId INT
	

SELECT 
	@BaselinePartnerConfigId = BaselinePartnerConfigId,
	@PartnerClientId = PartnerClientId
FROM Integration.BaselinePartnerConfig 
WHERE 
	BaselineId = @SourceId
	AND PartnerCode = @PartnerCode


--Many operations will be made from this memory dataset, so makes sense to create a variable for it
DECLARE @MoproMappingValues TABLE (
	[LocalRecordId] [int] NOT NULL,
	[ItemIdentifier] [varchar](60) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[SecondaryDescription] [varchar](200) NOT NULL,
	[Amount] [money] NOT NULL,
	[MiscData] [varchar](50) NOT NULL,
	[MiscCode] [varchar](15) NOT NULL,
	[MiscDate] [smalldatetime] NULL,
	[LocalMappingAreaCode] [varchar](8) NOT NULL,
	[LocalMappingTypeCode] [varchar](8) NULL,
	[OwnerCode] [varchar](8) NULL
)

INSERT INTO @MoproMappingValues (LocalRecordId, ItemIdentifier, Name, SecondaryDescription, Amount, MiscData, MiscCode, MiscDate, LocalMappingAreaCode, LocalMappingTypeCode, OwnerCode)
SELECT		 @SourceId, 'Basic Profile Info', 'Basic Profile Info', 'Basic Profile Info', 0, '', 'PROFILE', NULL, 'MOP-PROF', NULL, 'CO-PRI'

UNION SELECT FamilyMemberId, LastName, FirstName, MiddleName, 0, Gender, REL.Name, BirthDate, 'MOP-FAM', NULL, 'CO-PRI'
FROM Consumer.FamilyMember FM JOIN Code.LookupItem REL ON FM.RelationshipCode = REL.Code
WHERE BaselineId = @SourceId

UNION SELECT AssetProtectionId, AccountNumber, InsuranceCompanyName, Insured, CurrentValue, YearIssued, '', NULL, 'MOP-ASST', InsuranceTypeCode, OwnerCode
FROM Consumer.AssetProtection
WHERE BaselineId = @SourceId

UNION SELECT BankAssetId, AccountNumber, BankName, '', AverageMonthlyBalance, '', '', NULL, 'MOP-BANK', AccountTypeCode, OwnerCode
FROM Consumer.BankAsset
WHERE BaselineId = @SourceId

UNION SELECT CdAssetId, AccountNumber, '', Description, CurrentValue, '', '', MaturityDate, 'MOP-CD', NULL, OwnerCode
FROM Consumer.CdAsset
WHERE BaselineId = @SourceId

UNION SELECT OtherAssetId, '', '', Description, EstimatedValue, '', '', NULL, 'MOP-OTH', NULL, OwnerCode
FROM Consumer.OtherAsset
WHERE BaselineId = @SourceId

UNION SELECT OtherLiabilityId, AccountNumber, CreditorName, Description, CurrentBalance, '', '', InstallmentDate, 'MOP-LI-O', LiabilityTypeCode, OwnerCode
FROM Consumer.OtherLiability
WHERE BaselineId = @SourceId

UNION SELECT PersonalAssetId, '', '', Description, EstimatedValue, '', '', NULL, 'MOP-PERS', PersonalPropertyTypeCode, OwnerCode
FROM Consumer.PersonalAsset
WHERE BaselineId = @SourceId

UNION SELECT RealEstateAssetId, '', '', Description, EstimatedValue, CONVERT(varchar(50), SummaryOfProperty), '', NULL, 'MOP-REAL', PropertyTypeCode, OwnerCode
FROM Consumer.RealEstateAsset
WHERE BaselineId = @SourceId

UNION SELECT RealEstateLiabilityId, AccountNumber, CreditorName, CONVERT(varchar(50), RA.Description), CurrentBalance, '', '', InstallmentDate, 'MOP-LI-P', MortgageTypeCode, RL.OwnerCode
FROM Consumer.RealEstateLiability RL JOIN Consumer.RealEstateAsset RA ON RL.RealEstateAssetId = RA.RealEstateAssetId
WHERE RL.BaselineId = @SourceId

UNION SELECT TaxableInvestmentAssetId, AccountNumber, '', Description, TotalCurrentValue, '', '', NULL, 'MOP-TAX', NULL, OwnerCode
FROM Consumer.TaxableInvestmentAsset
WHERE BaselineId = @SourceId

UNION SELECT TaxAdvantagedAssetId, AccountNumber, '', Description, CurrentAccountValue, '', '', NULL, 'MOP-NOTX', PlanTypeCode, OwnerCode
FROM Consumer.TaxAdvantagedAsset
WHERE BaselineId = @SourceId


BEGIN TRAN

--First ensure the partner config exists to use as an anchor
IF @BaselinePartnerConfigId IS NULL BEGIN
	--TODO: Come back to this, need to get from advisor but also need to be prepared that config is missing too. 
	--Honestly, neither this case nor the one just mentioned should happen and this block should never be triggered
	INSERT INTO Integration.BaselinePartnerConfig (BaselineId, PartnerCode, IntegrationDirectionCode, IsPartnerSource, ShowManualMapping, EnableAutoSync)
	SELECT @SourceId, @PartnerCode, 'DIR-BOTH', 1, 1, 0

	SET @BaselinePartnerConfigId = @@IDENTITY	
END
	
--Next delete anything in previous mapping no longer present (aka was deleted in the UI)
DELETE T
FROM 
	Integration.BaselineDataMappings T
	LEFT JOIN @MoproMappingValues CURR
		ON T.LocalRecordId = CURR.LocalRecordId
			AND T.LocalMappingAreaCode = CURR.LocalMappingAreaCode
WHERE 
	T.BaselinePartnerConfigId = @BaselinePartnerConfigId
	AND CURR.LocalRecordId IS NULL

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


--Then update all existing entries with current values
UPDATE T
SET
	ItemIdentifier = S.ItemIdentifier, 
	Name = S.Name, 
	SecondaryDescription = S.SecondaryDescription, 
	Amount = S.Amount, 
	MiscData = S.MiscData, 
	MiscCode = CASE WHEN LEN(S.MiscCode) > 0 THEN S.MiscCode ELSE T.MiscCode END, 
	MiscDate = S.MiscDate, 
	LocalMappingTypeCode = S.LocalMappingTypeCode, 
	OwnerCode = S.OwnerCode
FROM
	Integration.BaselineDataMappings T
	JOIN @MoproMappingValues S
		ON T.LocalRecordId = S.LocalRecordId
			AND T.LocalMappingAreaCode = S.LocalMappingAreaCode

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


--Lastly, insert any new items not yet in the data mapping
INSERT INTO Integration.BaselineDataMappings (BaselinePartnerConfigId, PartnerRecordId, LocalRecordId, ItemIdentifier, Name, SecondaryDescription, Amount, MiscData, MiscCode, MiscDate, PartnerMappingTypeCode, LocalMappingAreaCode, LocalMappingTypeCode, OwnerCode)
SELECT
	BaselinePartnerConfigId = @BaselinePartnerConfigId,
	PartnerRecordId = CASE WHEN @PartnerClientId > 0 AND S.LocalMappingAreaCode = 'MOP-PROF' THEN @PartnerClientId ELSE NULL END, --Generally if the config exists, the basic profile has already been inserted so capture it here for completeness even tho not required
	LocalRecordId = S.LocalRecordId,
	ItemIdentifier = S.ItemIdentifier, 
	Name = S.Name, 
	SecondaryDescription = S.SecondaryDescription, 
	Amount = S.Amount, 
	MiscData = S.MiscData, 
	MiscCode = S.MiscCode, 
	MiscDate = S.MiscDate, 
	PartnerMappingTypeCode = DM.PartnerMappingTypeCode,
	LocalMappingAreaCode = S.LocalMappingAreaCode, 
	LocalMappingTypeCode = S.LocalMappingTypeCode, 
	OwnerCode = S.OwnerCode

FROM
	@MoproMappingValues S
	JOIN Integration.PartnerMappingDefault DM
		ON PartnerCode = @PartnerCode
			AND S.LocalMappingAreaCode = DM.LocalMappingAreaCode
			AND ISNULL(S.LocalMappingTypeCode, '') = ISNULL(DM.LocalMappingTypeCode, '')
			AND DM.ForPartnerOnly = 0 --The mapping table is conflated with instructions for both sides, with some causing outer joins 
	JOIN Code.LookupItem AREA
		ON DM.LocalMappingAreaCode = AREA.Code
	LEFT JOIN Integration.BaselineDataMappings T
		ON S.LocalRecordId = T.LocalRecordId  
			AND (S.LocalMappingAreaCode = T.LocalMappingAreaCode
				OR (S.MiscCode = 'PROFILE' AND S.MiscCode = T.MiscCode))
WHERE 
	T.LocalRecordId IS NULL
ORDER BY 
	AREA.SortOrder
	
SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


COMMIT TRAN


SELECT @SourceId
RETURN @SourceId


HandleError:
	IF @Error <> 0 BEGIN
	   ROLLBACK TRAN
	   RETURN @Error
	END


GO




PRINT 'Add [UpdateLocalFromMappingData] proc' 
IF OBJECT_ID(N'[Integration].[UpdateLocalFromMappingData]') IS NOT NULL 
	DROP PROC [Integration].[UpdateLocalFromMappingData] 
GO
CREATE PROC [Integration].[UpdateLocalFromMappingData] (
	@SourceId INT, 
	@PartnerCode VARCHAR(8)
) 
AS

DECLARE 
	@Error INT,
	@BaselinePartnerConfigId INT,
	@PartnerName VARCHAR(30),
	@HasPlan BIT


--Many operations will be made from this memory dataset, so makes sense to create a variable for it
DECLARE @MoproMappingValues TABLE (
	[BaselineDataMappingsId] [int] NOT NULL,
	[LocalRecordId] [int] NULL,
	[ItemIdentifier] [varchar](60) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[SecondaryDescription] [varchar](200) NOT NULL,
	[Amount] [money] NOT NULL,
	[MiscData] [varchar](50) NOT NULL,
	[MiscCode] [varchar](15) NOT NULL,
	[MiscDate] [smalldatetime] NULL,
	[LocalMappingAreaCode] [varchar](8) NOT NULL,
	[LocalMappingTypeCode] [varchar](8) NULL,
	[OwnerCode] [varchar](8) NULL
)
	
	
SELECT 
	@BaselinePartnerConfigId = BC.BaselinePartnerConfigId,
	@PartnerName = PRT.Name,
	@HasPlan = CASE WHEN P.BaselineId IS NOT NULL THEN 1 ELSE 0 END
FROM 
	Integration.BaselinePartnerConfig BC
	JOIN Code.LookupItem PRT
		ON BC.PartnerCode = PRT.Code
	JOIN Consumer.Baseline S
		ON BC.BaselineId = S.BaselineId
	LEFT JOIN [Plan].PlanRevision P
		ON S.BaselineId = P.BaselineId
WHERE 
	BC.BaselineId = @SourceId
	AND BC.PartnerCode = @PartnerCode


INSERT INTO @MoproMappingValues (BaselineDataMappingsId, LocalRecordId, ItemIdentifier, Name, SecondaryDescription, Amount, MiscData, MiscCode, MiscDate, LocalMappingAreaCode, LocalMappingTypeCode, OwnerCode)
SELECT BaselineDataMappingsId, LocalRecordId, ItemIdentifier, BM.Name, SecondaryDescription, Amount, MiscData, MiscCode, MiscDate, LocalMappingAreaCode, LocalMappingTypeCode, OwnerCode
FROM 
	Integration.BaselineDataMappings BM
	JOIN Code.LookupItem AREA
		ON BM.LocalMappingAreaCode = AREA.Code
	LEFT JOIN Code.LookupItem CODE
		ON BM.LocalMappingTypeCode = CODE.Code
WHERE 
	BM.BaselinePartnerConfigId = @BaselinePartnerConfigId
	AND BM.LocalMappingAreaCode <> 'MOP-PROF' --This mapping/translation is handled in code
	AND BM.LocalMappingAreaCode <> 'MOP-SKIP' --Has been flagged or configured to not be imported so omit
ORDER BY 
	AREA.SortOrder,
	CODE.SortOrder


BEGIN TRAN

--Go thru each of the 10 asset/liability areas plus family members, updating based on the staged mapping data, matched on the local IDs (inserts of new data will be later)
UPDATE T
SET
	LastName = IMP.ItemIdentifier, 
	FirstName = IMP.Name, 
	MiddleName = IMP.SecondaryDescription, 
	--Gender = IMP.MiscData, --not available in partner
	BirthDate = IMP.MiscDate
FROM
	@MoproMappingValues IMP
	JOIN Consumer.FamilyMember T
		ON IMP.LocalRecordId = T.FamilyMemberId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-FAM'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	AccountNumber = IMP.ItemIdentifier, 
	InsuranceCompanyName = IMP.Name, 
	Insured = IMP.SecondaryDescription, --TODO: Account.Product is source so not likely to be Insured. Can we integrate this one?
	CurrentValue = IMP.Amount,
	--YearIssued = IMP.MiscData, --not available in partner
	--PrimaryBeneficiaryCode = IMP.MiscCode, --not available in partner
	--xxx = IMP.MiscDate,
	InsuranceTypeCode = IMP.LocalMappingTypeCode
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.AssetProtection T
		ON IMP.LocalRecordId = T.AssetProtectionId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-ASST'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	AccountNumber = IMP.ItemIdentifier, 
	BankName = IMP.Name, 
	--Insured = IMP.SecondaryDescription, --TODO: Account.Product is source 
	AverageMonthlyBalance = IMP.Amount,
	--xxx = IMP.MiscData, --not available in partner
	--xxx = IMP.MiscCode, --not available in partner
	--xxx = IMP.MiscDate,
	AccountTypeCode = IMP.LocalMappingTypeCode
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.BankAsset T
		ON IMP.LocalRecordId = T.BankAssetId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-BANK'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	AccountNumber = IMP.ItemIdentifier, 
	--xxx = IMP.Name, 
	[Description] = ISNULL(NULLIF(IMP.SecondaryDescription, ''), 'Not Specified'), --TODO: Account.Product is source 
	CurrentValue = IMP.Amount
	--xxx = IMP.MiscData, --not available in partner
	--xxx = IMP.MiscCode, --not available in partner
	--MaturityDate = IMP.MiscDate, --not available in partner
	--xxx = IMP.LocalMappingTypeCode, --not applicable
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.CdAsset T
		ON IMP.LocalRecordId = T.CdAssetId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-CD'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	AccountNumber = IMP.ItemIdentifier, 
	--xxx = IMP.Name, 
	[Description] = ISNULL(NULLIF(IMP.SecondaryDescription, ''), 'Not Specified'), --TODO: Account.Product is source 
	TotalCurrentValue = IMP.Amount
	--xxx = IMP.MiscData, --not available in partner
	--xxx = IMP.MiscCode, --not available in partner
	--xxx = IMP.MiscDate, --not available in partner
	--xxx = IMP.LocalMappingTypeCode, --not applicable
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.TaxableInvestmentAsset T
		ON IMP.LocalRecordId = T.TaxableInvestmentAssetId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-TAX'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	AccountNumber = IMP.ItemIdentifier, 
	--xxx = IMP.Name, 
	[Description] = IMP.SecondaryDescription, --TODO: Account.Product is source 
	CurrentAccountValue = IMP.Amount,
	--xxx = IMP.MiscData, --not available in partner
	--PrimaryBeneficiaryCode = IMP.MiscCode, --not available in partner
	--xxx = IMP.MiscDate, --not available in partner
	PlanTypeCode = IMP.LocalMappingTypeCode 
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.TaxAdvantagedAsset T
		ON IMP.LocalRecordId = T.TaxAdvantagedAssetId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-NOTX'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	--xxx = IMP.ItemIdentifier, --not applicable
	--xxx = IMP.Name, --not applicable
	[Description] = ISNULL(NULLIF(IMP.SecondaryDescription, ''), 'Not Specified'), --TODO: Account.Product is source 
	EstimatedValue = IMP.Amount,
	--SummaryOfProperty = IMP.MiscData, --not available in partner
	--xxx = IMP.MiscCode, --not available in partner
	--xxx = IMP.MiscDate, --not available in partner
	PropertyTypeCode = IMP.LocalMappingTypeCode
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.RealEstateAsset T
		ON IMP.LocalRecordId = T.RealEstateAssetId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-REAL'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	--xxx = IMP.ItemIdentifier, --not applicable
	--xxx = IMP.Name, --not applicable
	[Description] = IMP.SecondaryDescription, --TODO: Account.Product is source 
	EstimatedValue = IMP.Amount,
	--xxx = IMP.MiscData, --not available in partner
	--xxx = IMP.MiscCode, --not available in partner
	--xxx = IMP.MiscDate, --not available in partner
	PersonalPropertyTypeCode = IMP.LocalMappingTypeCode
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.PersonalAsset T
		ON IMP.LocalRecordId = T.PersonalAssetId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-PERS'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	--xxx = IMP.ItemIdentifier, --not applicable
	--xxx = IMP.Name, --not applicable
	[Description] = ISNULL(NULLIF(IMP.SecondaryDescription, ''), 'Not Specified'), --TODO: Account.Product is source 
	EstimatedValue = IMP.Amount
	--xxx = IMP.MiscData, --not available in partner
	--xxx = IMP.MiscCode, --not available in partner
	--xxx = IMP.MiscDate, --not available in partner
	--xxx = IMP.LocalMappingTypeCode, --not applicable
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.OtherAsset T
		ON IMP.LocalRecordId = T.OtherAssetId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-OTH'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	AccountNumber = IMP.ItemIdentifier, 
	CreditorName = IMP.Name, 
	--[Description] = IMP.SecondaryDescription, --TODO: Account.Product is source but how to map to property??
	CurrentBalance = IMP.Amount,
	--xxx = IMP.MiscData, --not applicable
	--xxx = IMP.MiscCode, --not applicable
	--InstallmentDate = IMP.MiscDate, --not available in partner
	MortgageTypeCode = IMP.LocalMappingTypeCode
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.RealEstateLiability T
		ON IMP.LocalRecordId = T.RealEstateLiabilityId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-LI-P'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


UPDATE T
SET
	AccountNumber = IMP.ItemIdentifier, 
	CreditorName = IMP.Name, 
	[Description] = IMP.SecondaryDescription, --TODO: Account.Product is source 
	CurrentBalance = IMP.Amount,
	--xxx = IMP.MiscData, --not applicable
	--xxx = IMP.MiscCode, --not applicable
	--InstallmentDate = IMP.MiscDate, --not available in partner
	LiabilityTypeCode = IMP.LocalMappingTypeCode
	--OwnerCode = IMP.OwnerCode --For update, probably best to let user change inside the system instead of requiring them to keep the mapping data the source on this one
FROM
	@MoproMappingValues IMP
	JOIN Consumer.OtherLiability T
		ON IMP.LocalRecordId = T.OtherLiabilityId
WHERE
	IMP.LocalMappingAreaCode = 'MOP-LI-O'

SET @Error = @@ERROR
IF @Error <> 0 GOTO HandleError


--NOTE: No deletes happen - that is for the user to manage just because these systems are only VERY loosely correlated and cannot assume too much


--HACK: Need to cursor thru unfortuantely because we need to snatch the new ID and update the mapping table and no other organic way to get the ID after the fact
DECLARE csrPartnerImportInserts CURSOR FOR  
	SELECT BaselineDataMappingsId, ItemIdentifier, Name, SecondaryDescription, Amount, MiscData, MiscDate, LocalMappingAreaCode, LocalMappingTypeCode, OwnerCode
	FROM @MoproMappingValues
	WHERE LocalRecordId IS NULL

DECLARE 
	@BaselineDataMappingsId [int], 
	@ItemIdentifier [varchar](60), 
	@Name [varchar](200), 
	@SecondaryDescription [varchar](200), 
	@Amount [money], 
	@MiscData [varchar](50),
	@MiscDate [smalldatetime],
	@LocalMappingAreaCode [varchar](8), 
	@LocalMappingTypeCode [varchar](8), 
	@OwnerCode [varchar](8),
	@LocalRecordId [int]

	
	
	
--HACK: Hate this. Consider moving this into code regardless of performance since losing ALL of the benefit of the centralized domain logic and defaults, etc
OPEN csrPartnerImportInserts   
FETCH NEXT FROM csrPartnerImportInserts INTO @BaselineDataMappingsId, @ItemIdentifier, @Name, @SecondaryDescription, @Amount, @MiscData, @MiscDate, @LocalMappingAreaCode, @LocalMappingTypeCode, @OwnerCode
WHILE @@FETCH_STATUS = 0 BEGIN   

	DECLARE @DidNotInsert BIT
	SELECT @DidNotInsert = 0

	IF @LocalMappingAreaCode = 'MOP-FAM' BEGIN
		INSERT INTO Consumer.FamilyMember (BaselineId, RelationshipCode, FirstName, MiddleName, LastName, Gender, BirthDate, Phone, Email, Dependent, CollegeExpenses, PhysicalAddressLine, PhysicalCity, PhysicalState, PhysicalZip, Country, Comments, LinkingId)
		SELECT @SourceId, 'FAM-OTH', @Name, @SecondaryDescription, @ItemIdentifier, @MiscData, @MiscDate, '', '', 1, 0, '', '', '', '', '', 'Imported from ' + @PartnerName + '.', NEWID()
	
	END ELSE IF @LocalMappingAreaCode = 'MOP-BANK' BEGIN
		INSERT INTO Consumer.BankAsset (BaselineId, OwnerCode, AccountTypeCode, BankName, AverageMonthlyBalance, MonthlyContribution, IsPrimary, Comments, LinkingId, EstimatedYield, AccountNumber)
		SELECT @SourceId, @OwnerCode, @LocalMappingTypeCode, @Name, @Amount, 0, 0, 'Imported from ' + @PartnerName + '.', NEWID(), 0, @ItemIdentifier
		
	END ELSE IF @LocalMappingAreaCode = 'MOP-ASST' BEGIN
		INSERT INTO Consumer.AssetProtection (BaselineId, OwnerCode, InsuranceTypeCode, Insured, InsuranceCompanyName, YearIssued, YearExpiry, AnnualPremium, CoverageAmount, IsEmployerProvided, CurrentValue, PrimaryBeneficiaryCode, SecondaryBeneficiaryCode, Comments, LinkingId, EstimatedYield, IsAutoEntry, AccountNumber)
		SELECT @SourceId, @OwnerCode, @LocalMappingTypeCode, @SecondaryDescription, @Name, '', '', 0, 0, 0, @Amount, NULL, NULL, 'Imported from ' + @PartnerName + '.', NEWID(), 0, 0, @ItemIdentifier
		
	END ELSE IF @LocalMappingAreaCode = 'MOP-CD' BEGIN
		INSERT INTO Consumer.CdAsset (BaselineId, OwnerCode, Description, InterestRate, MaturityDate, CurrentValue, Comments, LinkingId, AccountNumber)
		SELECT @SourceId, @OwnerCode, ISNULL(NULLIF(@SecondaryDescription, ''), 'Not Specified'), 0, NULL, @Amount, 'Imported from ' + @PartnerName + '.', NEWID(), @ItemIdentifier
		
	END ELSE IF @LocalMappingAreaCode = 'MOP-TAX' BEGIN
		INSERT INTO Consumer.TaxableInvestmentAsset (BaselineId, OwnerCode, Description, EstimatedYield, TotalCostBasis, TotalCurrentValue, MonthlyContribution, Comments, LinkingId, AccountNumber)
		SELECT @SourceId, @OwnerCode, ISNULL(NULLIF(@SecondaryDescription, ''), 'Not Specified'), 0, 0, @Amount, 0, 'Imported from ' + @PartnerName + '.', NEWID(), @ItemIdentifier
		
	END ELSE IF @LocalMappingAreaCode = 'MOP-NOTX' BEGIN
		INSERT INTO Consumer.TaxAdvantagedAsset (BaselineId, OwnerCode, PlanTypeCode, Description, EmployerMonthlyPercentContributions, EmployeeMonthlyDollarContributions, EmployeeMonthlyPercentContributions, CurrentAccountValue, PrimaryBeneficiaryCode, SecondaryBeneficiaryCode, Comments, EmployerMonthlyPercentMaximum, LinkingId, EstimatedYield, IsAutoEntry, EmployerMonthlyDollarContributions, AccountNumber)
		SELECT @SourceId, @OwnerCode, @LocalMappingTypeCode, @SecondaryDescription, 0, 0, 0, @Amount, NULL, NULL, 'Imported from ' + @PartnerName + '.', 0, NEWID(), 0, 0, 0, @ItemIdentifier
		
	END ELSE IF @LocalMappingAreaCode = 'MOP-REAL' BEGIN
		DECLARE @RealEstateAssetId INT 
		SELECT @RealEstateAssetId = RealEstateAssetId FROM Consumer.RealEstateAsset WHERE BaselineId = @SourceId AND OwnerCode = @OwnerCode AND PropertyTypeCode = @LocalMappingTypeCode AND Description = ISNULL(NULLIF(@SecondaryDescription, ''), 'Not Specified')
		
		--Cant insert a dup so check first and if dup, then update the local record since somehow orphaned or just manually inserted in both places
		IF ISNULL(@RealEstateAssetId, 0) = 0 BEGIN
			INSERT INTO Consumer.RealEstateAsset (BaselineId, OwnerCode, PropertyTypeCode, Description, EstimatedValue, OriginalPurchasePrice, Comments, LinkingId, GrossRentalIncome, PropertyExpenses, SummaryOfProperty, EstimatedYield)
			SELECT @SourceId, @OwnerCode, @LocalMappingTypeCode, ISNULL(NULLIF(@SecondaryDescription, ''), 'Not Specified'), @Amount, 0, 'Imported from ' + @PartnerName + '.', NEWID(), 0, 0, '', 0
		END ELSE BEGIN
			UPDATE Integration.BaselineDataMappings SET LocalRecordId = @RealEstateAssetId WHERE BaselineDataMappingsId = @BaselineDataMappingsId
			SELECT @DidNotInsert = 1
		END
		
	END ELSE IF @LocalMappingAreaCode = 'MOP-PERS' BEGIN
		INSERT INTO Consumer.PersonalAsset (BaselineId, OwnerCode, PersonalPropertyTypeCode, Description, EstimatedValue, OriginalPurchasePrice, Comments, LinkingId, DepreciationRate)
		SELECT @SourceId, @OwnerCode, @LocalMappingTypeCode, @SecondaryDescription, @Amount, 0, 'Imported from ' + @PartnerName + '.', NEWID(), 0
	
	--TODO: Need to figure out what to do or allow no asset selected??	
	END ELSE IF @LocalMappingAreaCode = 'MOP-LI-P' BEGIN
		DECLARE @AssetId INT
		
		--Should already be added if exists since sorted master insert list in this order. 
		--BUT have no way to link between an asset and liability in Redtail, so can only fish out one possible entry. Either that, or we cannot support
		--importing this and maybe we shouldnt to reduce confusion
		SELECT TOP 1
			@AssetId = RealEstateAssetId
		FROM Consumer.RealEstateAsset
		WHERE 
			BaselineId = @SourceId
			AND Description IN (SELECT SecondaryDescription FROM @MoproMappingValues WHERE LocalMappingAreaCode = 'MOP-REAL')
		
		IF @AssetId > 0 BEGIN
			INSERT INTO Consumer.RealEstateLiability (BaselineId, OwnerCode, RealEstateAssetId, MortgageTypeCode, IsSecondMortgage, InstallmentDate, Term, InterestRate, MonthlyPayment, OriginalBalance, CurrentBalance, Comments, LinkingId, CreditorName, InterestOnlyTerm, InterestOnlyTermDate, InterestOnlyMonthlyPayment, AccountNumber)
			SELECT @SourceId, @OwnerCode, @AssetId, @LocalMappingTypeCode, 0, NULL, 0, 0, 0, 0, @Amount, 'Imported from ' + @PartnerName + '.', NEWID(), @Name, 0, NULL, 0, @ItemIdentifier
		END ELSE BEGIN
			SELECT @DidNotInsert = 1
		END
		
	END ELSE IF @LocalMappingAreaCode = 'MOP-LI-O' BEGIN
		INSERT INTO Consumer.OtherLiability (BaselineId, OwnerCode, LiabilityTypeCode, Description, InstallmentDate, Term, InterestRate, MonthlyPayment, OriginalBalance, CurrentBalance, Comments, LinkingId, CreditorName, InterestOnlyTerm, InterestOnlyTermDate, InterestOnlyMonthlyPayment, AccountNumber)
		SELECT @SourceId, @OwnerCode, @LocalMappingTypeCode, @SecondaryDescription, NULL, 0, 0, 0, 0, @Amount, 'Imported from ' + @PartnerName + '.', NEWID(), @Name, 0, NULL, 0, @ItemIdentifier
		
	END ELSE BEGIN --IF @LocalMappingAreaCode = 'MOP-OTH' BEGIN
		INSERT INTO Consumer.OtherAsset (BaselineId, OwnerCode, Description, EstimatedValue, Comments, LinkingId, DepreciationRate)
		SELECT @SourceId, @OwnerCode, ISNULL(NULLIF(@SecondaryDescription, ''), 'Not Specified'), @Amount, 'Imported from ' + @PartnerName + '.', NEWID(), 0
		
	END
	
	SET @Error = @@ERROR
	IF @Error <> 0 BEGIN
		CLOSE csrPartnerImportInserts   
		DEALLOCATE csrPartnerImportInserts
		GOTO HandleError
	END

	IF @DidNotInsert = 0 BEGIN
		--Capure new ID and update mapping to prevent this being detected as new each time
		SET @LocalRecordId = @@IDENTITY
		UPDATE Integration.BaselineDataMappings SET LocalRecordId = @LocalRecordId WHERE BaselineDataMappingsId = @BaselineDataMappingsId
		
		
		--Also, if in plan mode, need to convert the new entry to the revised variant (when applicable)
		IF @HasPlan = 1 BEGIN
			IF @LocalMappingAreaCode = 'MOP-BANK' BEGIN
				INSERT INTO [Plan].RevisedBankAsset (BankAssetId, RevisedMonthlyContribution)
				SELECT BankAssetId, MonthlyContribution
				FROM Consumer.BankAsset
				WHERE BaselineId = @SourceId AND BankAssetId = @LocalRecordId		
				
			END ELSE IF @LocalMappingAreaCode = 'MOP-ASST' BEGIN
				INSERT INTO [Plan].RevisedAssetProtection (AssetProtectionId, RevisedAnnualPremium, RevisedCoverageAmount)
				SELECT AssetProtectionId, AnnualPremium, CoverageAmount
				FROM Consumer.AssetProtection
				WHERE BaselineId = @SourceId AND AssetProtectionId = @LocalRecordId		
				
			END ELSE IF @LocalMappingAreaCode = 'MOP-TAX' BEGIN
				INSERT INTO [Plan].RevisedTaxableInvestmentAsset (TaxableInvestmentAssetId, RevisedMonthlyContribution)
				SELECT TaxableInvestmentAssetId, MonthlyContribution
				FROM Consumer.TaxableInvestmentAsset
				WHERE BaselineId = @SourceId AND TaxableInvestmentAssetId = @LocalRecordId		
			
			END ELSE IF @LocalMappingAreaCode = 'MOP-NOTX' BEGIN
				INSERT INTO [Plan].RevisedTaxAdvantagedAsset (TaxAdvantagedAssetId, RevisedEmployeeMonthlyDollarContributions, RevisedEmployeeMonthlyPercentContributions)
				SELECT TaxAdvantagedAssetId, EmployeeMonthlyDollarContributions, EmployeeMonthlyPercentContributions
				FROM Consumer.TaxAdvantagedAsset
				WHERE BaselineId = @SourceId AND TaxAdvantagedAssetId = @LocalRecordId		
			
			END ELSE IF @LocalMappingAreaCode = 'MOP-LI-P' BEGIN
				INSERT INTO [Plan].RevisedRealEstateLiability (RealEstateLiabilityId, RevisedMonthlyPayment, RevisedCurrentBalance)
				SELECT RealEstateLiabilityId, MonthlyPayment, CurrentBalance
				FROM Consumer.RealEstateLiability
				WHERE BaselineId = @SourceId AND RealEstateLiabilityId = @LocalRecordId		
			
			END ELSE IF @LocalMappingAreaCode = 'MOP-LI-O' BEGIN
				INSERT INTO [Plan].RevisedOtherLiability (OtherLiabilityId, RevisedMonthlyPayment, RevisedCurrentBalance)
				SELECT OtherLiabilityId, MonthlyPayment, CurrentBalance
				FROM Consumer.OtherLiability
				WHERE BaselineId = @SourceId AND OtherLiabilityId = @LocalRecordId		

			END
		
		END
	END
	
	SET @Error = @@ERROR
	IF @Error <> 0 BEGIN
		CLOSE csrPartnerImportInserts   
		DEALLOCATE csrPartnerImportInserts
		GOTO HandleError
	END
	

	FETCH NEXT FROM csrPartnerImportInserts INTO @BaselineDataMappingsId, @ItemIdentifier, @Name, @SecondaryDescription, @Amount, @MiscData, @MiscDate, @LocalMappingAreaCode, @LocalMappingTypeCode, @OwnerCode
END   

CLOSE csrPartnerImportInserts
DEALLOCATE csrPartnerImportInserts


COMMIT TRAN

SELECT @SourceId
RETURN @SourceId


HandleError:
	IF @Error <> 0 BEGIN
	   ROLLBACK TRAN
	   RETURN @Error
	END


GO


