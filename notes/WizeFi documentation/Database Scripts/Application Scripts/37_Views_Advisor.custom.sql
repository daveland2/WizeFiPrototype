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
--NOTE: Dependent on the Membership database and dbo.aspnet_Users table
IF OBJECT_ID(N'MEMBERSHIP_USERS') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_USERS
	FOR Membership.dbo.aspnet_Users
END
GO



PRINT 'Add [ClientManagement] view' 
IF OBJECT_ID(N'[Advisor].[ClientManagement]') IS NOT NULL 
	DROP VIEW [Advisor].[ClientManagement] 
GO
CREATE VIEW [Advisor].[ClientManagement]  
AS

--HACK: This view grabs stuff from all over, mixing domains and highly coupled and dependent 
--including the membership database
--NOTE: This really should be contained within the domain since there is a lot of logic here that is now removed from the domain
--	However the justification is that the Budget is used frequently and in a few places and needs to be performance friendly - running from
--	domain would be expensive
SELECT
	FinancialAdvisorId = ADV.ApplicationMappingId,

	ClientManagementId = B.BaselineId,
	PrimaryConsumerId = PC.PrimaryConsumerId,
	BaselineId = B.BaselineId,

	FirstName = PC.[FirstName],
	LastName = PC.[LastName],
	
	IsUserCreated = CASE WHEN USR.UserId IS NOT NULL THEN 1 ELSE 0 END,
	PublishDate = B.PublishDate,
	FirstActivityDate = CASE WHEN USR.UserId IS NOT NULL THEN LAST_BASE.FirstActivity ELSE NULL END,
	LastActivityDate = CASE WHEN USR.UserId IS NOT NULL THEN LAST_BASE.LastActivity ELSE NULL END,
	ArchiveDate = B.ArchiveDate,
	IsProfileSent = CASE WHEN B.PublishDate IS NOT NULL THEN 1 ELSE 0 END,
	ProfileProgress = ISNULL(PROGRESS.Completion, 0),
	IsProfileSubmitted = CASE WHEN B.SubmitDate IS NOT NULL OR REV.BaselineId IS NOT NULL THEN 1 ELSE 0 END,
	[Version] = B.[Version],
	IsActive = B.IsActive,
	IsLocked = B.IsLocked,
	NeedsReview = B.NeedsReview,
	IsPlanVersion = CASE WHEN REV.BaselineId IS NOT NULL THEN 1 ELSE 0 END,

	BudgetId = BUD.BudgetId,
	
	PhysicalCity = PC.[PhysicalCity],
	PhysicalState = PC.[PhysicalState],
	MobilePhone = PC.[MobilePhone],
	Email = PC.[Email],
	UserName = ISNULL(USR.UserName, ''),
	UserPin = PC.UserPin

FROM 

	(
			SELECT 
				PrimaryConsumerId = PrimaryConsumerId,
				BaselineVersion = MAX(Version),
				FirstActivity = MIN(CreateDate),
				LastActivity = MAX(UpdateDate)
			FROM Consumer.Baseline
			GROUP BY PrimaryConsumerId
		) LAST_BASE

	JOIN Consumer.PrimaryConsumer PC
		ON LAST_BASE.PrimaryConsumerId = PC.PrimaryConsumerId

	JOIN Consumer.Baseline B
		ON LAST_BASE.PrimaryConsumerId = B.PrimaryConsumerId 
			AND LAST_BASE.BaselineVersion = B.[Version] 
	
	JOIN ( --Only one version links to the user mapping (and version may not even be active tho it is likely the last version)
		MEMBERSHIP_USER_MAPPING UM
		JOIN Consumer.Baseline AB
			ON UM.ApplicationMappingId = AB.BaselineId
				AND (UM.ApplicationAccountType = 'Inclusive'
					OR (UM.ApplicationAccountType = 'Retail' AND UM.ParentId IS NULL))
		) ON PC.PrimaryConsumerId = AB.PrimaryConsumerId
			
	JOIN MEMBERSHIP_USER_MAPPING ADV
		ON ISNULL(UM.ParentId, 'E421A8D0-9D36-4D24-BFC8-A2B76D20A21A') = ADV.UserId --HACK: Added to allow joining to fake advisor account with ID=1 so can manage retail accounts too
	LEFT JOIN MEMBERSHIP_USERS USR
		ON UM.UserId = USR.UserId
		
	LEFT JOIN Consumer.Budget BUD
		ON B.BaselineId = BUD.BaselineId
			
	OUTER APPLY (
			SELECT 
				Completion = CASE 
						WHEN COUNT(SM.SiteMapId) > 0 THEN COUNT(S.SiteMapId) / COUNT(SM.SiteMapId)
						ELSE 0 END
			FROM --TODO: Could alternately grade on how many pages they have visited within the tab group
				Consumer.Baseline B
				LEFT JOIN [Application].SiteMap SM
					ON SM.Module = 'ClientProfile'
				LEFT JOIN Consumer.BaselineStatus S
					ON SM.SiteMapId = S.SiteMapId
						AND S.IsSectionComplete = 1
			WHERE B.BaselineId = B.BaselineId
		) PROGRESS
	
	LEFT JOIN [Plan].[PlanRevision] REV
		ON B.BaselineId = REV.BaselineId
GO	


PRINT 'Add [BaselineSummary] view' 
IF OBJECT_ID(N'[Advisor].[BaselineSummary]') IS NOT NULL 
	DROP VIEW [Advisor].[BaselineSummary] 
GO
CREATE VIEW [Advisor].[BaselineSummary]  
AS

--HACK: This view grabs stuff from all over, mixing domains and highly coupled and dependent 
--including the membership database
--NOTE: This really should be contained within the domain since there is a lot of logic here that is now removed from the domain
--	However the justification is that the Budget is used frequently and in a few places and needs to be performance friendly - running from
--	domain would be expensive
SELECT
	FinancialAdvisorId = ADV.ApplicationMappingId,

	BaselineSummaryId = B.BaselineId,
	PrimaryConsumerId = PC.PrimaryConsumerId,
	BaselineId = B.BaselineId,

	FirstName = PC.[FirstName],
	LastName = PC.[LastName],
	
	IsUserCreated = CASE WHEN USR.UserId IS NOT NULL THEN 1 ELSE 0 END,
	FirstActivityDate = CASE WHEN USR.UserId IS NOT NULL THEN B.CreateDate ELSE NULL END,
	LastActivityDate = CASE WHEN USR.UserId IS NOT NULL THEN B.UpdateDate ELSE NULL END,
	ArchiveDate = B.ArchiveDate,
	ProfileProgress = ISNULL(PROGRESS.Completion, 0),
	IsProfileSubmitted = CASE WHEN B.SubmitDate IS NOT NULL OR REV.BaselineId IS NOT NULL THEN 1 ELSE 0 END,
	[Version] = B.[Version],
	IsActive = B.IsActive,
	IsLocked = B.IsLocked,
	IsPlanVersion = CASE WHEN REV.BaselineId IS NOT NULL THEN 1 ELSE 0 END,

	BudgetId = BUD.BudgetId,
	TotalNetIncome = ISNULL(INCOME.TotalNetIncome, 0),
	NetCash = 0, --Using Budget object for this since a lot to reproduce to get to TotalExpenses. Can even use for NetIncome but if no Budget created yet, would lose income data if available
	
	TotalAssetWorth = ISNULL(REAL_ASSET.Worth, 0) + ISNULL(NON_REAL_ASSET.Worth, 0),
	TotalNonRealPropertyAssetWorth = ISNULL(NON_REAL_ASSET.Worth, 0),
	TotalLiabilityDebt = ISNULL(REAL_LIABILITY.Debt, 0) + ISNULL(NON_REAL_LIABILITY.Debt, 0),
	TotalNonRealPropertyLiabilityDebt = ISNULL(NON_REAL_LIABILITY.Debt, 0),
	TotalNetWorth = (ISNULL(REAL_ASSET.Worth, 0) + ISNULL(NON_REAL_ASSET.Worth, 0)) - (ISNULL(REAL_LIABILITY.Debt, 0) + ISNULL(NON_REAL_LIABILITY.Debt, 0)), 
	
	PhysicalCity = PC.[PhysicalCity],
	PhysicalState = PC.[PhysicalState],
	MobilePhone = PC.[MobilePhone],
	Email = PC.[Email],
	UserName = ISNULL(USR.UserName, ''),
	UserPin = PC.UserPin

FROM 
	Consumer.Baseline B
	JOIN Consumer.PrimaryConsumer PC
		ON B.PrimaryConsumerId = PC.PrimaryConsumerId
	
	JOIN ( --Only one version links to the user mapping (and version may not even be active tho it is likely the last version)
		MEMBERSHIP_USER_MAPPING UM
		JOIN Consumer.Baseline AB
			ON UM.ApplicationMappingId = AB.BaselineId
				AND (UM.ApplicationAccountType = 'Inclusive'
					OR (UM.ApplicationAccountType = 'Retail' AND UM.ParentId IS NULL))
		) ON PC.PrimaryConsumerId = AB.PrimaryConsumerId
			
	JOIN MEMBERSHIP_USER_MAPPING ADV
		ON ISNULL(UM.ParentId, 'E421A8D0-9D36-4D24-BFC8-A2B76D20A21A') = ADV.UserId --HACK: Added to allow joining to fake advisor account with ID=1 so can manage retail accounts too
	LEFT JOIN MEMBERSHIP_USERS USR
		ON UM.UserId = USR.UserId
		
	LEFT JOIN Consumer.Budget BUD
		ON B.BaselineId = BUD.BaselineId
			
	OUTER APPLY (
			SELECT 
				Completion = CASE 
						WHEN COUNT(SM.SiteMapId) > 0 THEN COUNT(S.SiteMapId) / COUNT(SM.SiteMapId)
						ELSE 0 END
			FROM --TODO: Could alternately grade on how many pages they have visited within the tab group
				Consumer.Baseline B
				LEFT JOIN [Application].SiteMap SM
					ON SM.Module = 'ClientProfile'
				LEFT JOIN Consumer.BaselineStatus S
					ON SM.SiteMapId = S.SiteMapId
						AND S.IsSectionComplete = 1
			WHERE B.BaselineId = B.BaselineId
		) PROGRESS
		
	OUTER APPLY (
			SELECT
				TotalNetIncome = SUM(NetIncome)
			FROM (
					SELECT NetIncome = SUM(PC.Salary + PC.BonusAndCommission + PC.SelfEmploymentIncome + PC.Pension + PC.SSI + PC.OtherIncome)
					FROM Consumer.PrimaryConsumerIncomeSource PC
					WHERE PC.BaselineId = B.BaselineId
					UNION
					SELECT NetIncome = SUM(SC.Salary + SC.BonusAndCommission + SC.SelfEmploymentIncome + SC.Pension + SC.SSI + SC.OtherIncome)
					FROM Consumer.SecondaryConsumerIncomeSource SC
					WHERE SC.BaselineId = B.BaselineId
					UNION
					SELECT NetIncome = SUM(RE.GrossRentalIncome - RE.PropertyExpenses)
					FROM Consumer.RealEstateAsset RE
					WHERE RE.BaselineId = B.BaselineId AND RE.GrossRentalIncome <> 0
				) TMP
		) INCOME
		
	OUTER APPLY (
			SELECT Worth = SUM(REA.EstimatedValue)
			FROM Consumer.RealEstateAsset REA
			WHERE REA.BaselineId = B.BaselineId
		) REAL_ASSET
		
	OUTER APPLY (
			SELECT
				Worth = SUM(CurrentValue)
			FROM (
					SELECT CurrentValue = SUM(A.AverageMonthlyBalance)
					FROM Consumer.BankAsset A
					WHERE A.BaselineId = B.BaselineId
					UNION
					SELECT CurrentValue = SUM(A.CurrentValue)
					FROM Consumer.CdAsset A
					WHERE A.BaselineId = B.BaselineId
					UNION
					SELECT CurrentValue = SUM(A.EstimatedValue)
					FROM Consumer.PersonalAsset A
					WHERE A.BaselineId = B.BaselineId
					UNION
					SELECT CurrentValue = SUM(A.TotalCurrentValue)
					FROM Consumer.TaxableInvestmentAsset A
					WHERE A.BaselineId = B.BaselineId
					UNION
					SELECT CurrentValue = SUM(A.CurrentAccountValue)
					FROM Consumer.TaxAdvantagedAsset A
					WHERE A.BaselineId = B.BaselineId
					UNION
					SELECT CurrentValue = SUM(A.EstimatedValue)
					FROM Consumer.OtherAsset A
					WHERE A.BaselineId = B.BaselineId
					UNION
					SELECT CurrentValue = SUM(A.CurrentValue)
					FROM Consumer.AssetProtection A
					WHERE A.BaselineId = B.BaselineId
				) TMP
		) NON_REAL_ASSET
		
	OUTER APPLY (
			SELECT Debt = SUM(REL.CurrentBalance)
			FROM Consumer.RealEstateLiability REL
			WHERE REL.BaselineId = B.BaselineId
		) REAL_LIABILITY
		
	OUTER APPLY (
			SELECT Debt = SUM(OL.CurrentBalance)
			FROM Consumer.OtherLiability OL
			WHERE OL.BaselineId = B.BaselineId
		) NON_REAL_LIABILITY
	
	LEFT JOIN [Plan].[PlanRevision] REV
		ON B.BaselineId = REV.BaselineId

GO			


PRINT 'Add [PlanRevisionSummary] view' 
IF OBJECT_ID(N'[Advisor].[PlanRevisionSummary]') IS NOT NULL 
	DROP VIEW [Advisor].[PlanRevisionSummary] 
GO
CREATE VIEW [Advisor].[PlanRevisionSummary]  
AS

--HACK: This view grabs stuff from all over, mixing domains and highly coupled and dependent 
--including the membership database
--NOTE: This really should be contained within the domain since there is a lot of logic here that is now removed from the domain
--	However the justification is that the Budget is used frequently and in a few places and needs to be performance friendly - running from
--	domain would be expensive
SELECT
	FinancialAdvisorId = BASE.FinancialAdvisorId,

	PlanRevisionSummaryId = BASE.BaselineId,
	BaselineId = BASE.BaselineId,
	
	IsActive = BASE.IsActive,
	FirstActivityDate = BASE.FirstActivityDate,
	LastActivityDate = BASE.LastActivityDate,
	IsLocked = BASE.IsLocked,

	FirstName = BASE.[FirstName],
	LastName = BASE.[LastName],
	
	[Version] = BASE.[Version],
	
	BudgetId = BASE.BudgetId,
	TotalNetIncome = BASE.TotalNetIncome,
	NetCash = BASE.NetCash, 
	
	TotalAssetWorth = BASE.TotalAssetWorth,
	TotalNonRealPropertyAssetWorth = BASE.TotalNonRealPropertyAssetWorth,
	TotalLiabilityDebt = BASE.TotalLiabilityDebt,
	TotalNonRealPropertyLiabilityDebt = BASE.TotalNonRealPropertyLiabilityDebt,
	TotalNetWorth = BASE.TotalNetWorth, 
	
	PhysicalCity = BASE.[PhysicalCity],
	PhysicalState = BASE.[PhysicalState],
	MobilePhone = BASE.[MobilePhone],
	Email = BASE.[Email],
	UserName = BASE.UserName,
	UserPin = BASE.UserPin

FROM [Advisor].[BaselineSummary] BASE
WHERE BASE.IsPlanVersion = 1

GO


PRINT 'Add [ClientSummary] view' 
IF OBJECT_ID(N'[Advisor].[ClientSummary]') IS NOT NULL 
	DROP VIEW [Advisor].[ClientSummary] 
GO
CREATE VIEW [Advisor].[ClientSummary]  
AS

--HACK: This view grabs stuff from all over, mixing domains and highly coupled and dependent 
--including the membership database
--NOTE: This really should be contained within the domain since there is a lot of logic here that is now removed from the domain
--	However the justification is that the Budget is used frequently and in a few places and needs to be performance friendly - running from
--	domain would be expensive
SELECT
	FinancialAdvisorId = BASE.FinancialAdvisorId,

	ClientSummaryId = BASE.PrimaryConsumerId,
	BaselineId = BASE.BaselineId,
	
	IsClientActive = BASE.IsActive,

	FirstName = BASE.[FirstName],
	LastName = BASE.[LastName],
	
	BudgetId = BASE.BudgetId,
	TotalNetIncome = BASE.TotalNetIncome,
	NetCash = BASE.NetCash, 
	
	TotalAssetWorth = BASE.TotalAssetWorth,
	TotalNonRealPropertyAssetWorth = BASE.TotalNonRealPropertyAssetWorth,
	TotalLiabilityDebt = BASE.TotalLiabilityDebt,
	TotalNonRealPropertyLiabilityDebt = BASE.TotalNonRealPropertyLiabilityDebt,
	TotalNetWorth = BASE.TotalNetWorth, 
	
	PhysicalCity = BASE.[PhysicalCity],
	PhysicalState = BASE.[PhysicalState]

FROM

	(
			SELECT 
				PrimaryConsumerId = PrimaryConsumerId,
				BaselineVersion = MAX(Version),
				FirstActivity = MIN(CreateDate),
				LastActivity = MAX(UpdateDate)
			FROM Consumer.Baseline
			GROUP BY PrimaryConsumerId
		) LAST_BASE
	
	JOIN [Advisor].[BaselineSummary] BASE
		ON LAST_BASE.PrimaryConsumerId = BASE.PrimaryConsumerId
			AND LAST_BASE.BaselineVersion = BASE.[Version]
		
GO





