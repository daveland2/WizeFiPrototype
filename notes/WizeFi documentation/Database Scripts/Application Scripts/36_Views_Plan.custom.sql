SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO


PRINT 'Add [LiabilityRefinance] view' 
IF OBJECT_ID(N'[Plan].[LiabilityRefinance]') IS NOT NULL 
	DROP VIEW [Plan].[LiabilityRefinance] 
GO
CREATE VIEW [Plan].[LiabilityRefinance]  
AS

--NOTE: I have regrets about the design of this. Unfortunately, moved away from a good design originally, with a common assets table
--	and a common liability table to make summing these concerns up real easy, like in this case for the refinance worksheet. But too late
--  at this point and one downside to having had a core asset table is that with some of the revised tables, there would end up being
--  two levels of inheritance and that could get unruly if not lead to some issues (altho old framework/generator handled this just fine...)
SELECT
	BaselineId = RL.BaselineId,
	LiabilityRefinanceId = RRL.RealEstateLiabilityId,
	LiabilityType = 'Real Estate',
	LiabilitySubTypeCode = RL.MortgageTypeCode,
	LiabilitySubType = ISNULL(MTC.[Name], 'Unknown') + CASE RL.IsSecondMortgage WHEN 0 THEN ' (first)' ELSE ' (second)' END,
	RL.OwnerCode,
	[Description] = RA.[Description], 
	CreditorName,
	InstallmentDate, 
	Term, 
	InterestRate, 
	MonthlyPayment, 
	OriginalBalance, 
	CurrentBalance,
	InterestOnlyTerm,
	InterestOnlyTermDate,
	InterestOnlyMonthlyPayment,
	RefinancedMonthlyPayment = RRL.RevisedMonthlyPayment, 
	RefinancedCurrentBalance = RRL.RevisedCurrentBalance
FROM 
	[Consumer].RealEstateLiability RL 
	JOIN [Plan].RevisedRealEstateLiability RRL 
		ON RL.RealEstateLiabilityId = RRL.RealEstateLiabilityId 
	JOIN Consumer.RealEstateAsset RA
		ON RL.RealEstateAssetId = RA.RealEstateAssetId
	LEFT JOIN Code.LookupItem MTC
		ON RL.MortgageTypeCode = MTC.Code

UNION
SELECT
	BaselineId,
	LiabilityRefinanceId = 1000000 + ROL.OtherLiabilityId, --HACK: Cant have the IDs collide in the ORM, so create offset that will have to be backed out
	LiabilityType = 'Other',
	LiabilitySubTypeCode = OL.LiabilityTypeCode,
	LiabilitySubType = ISNULL(LTC.[Name], 'Unknown'),
	OL.OwnerCode,
	[Description] = ISNULL(NULLIF(OL.[Description], ''), 'Unknown'), 
	CreditorName,
	InstallmentDate, 
	Term, 
	InterestRate, 
	MonthlyPayment, 
	OriginalBalance, 
	CurrentBalance,
	InterestOnlyTerm,
	InterestOnlyTermDate,
	InterestOnlyMonthlyPayment,
	RefinancedMonthlyPayment = ROL.RevisedMonthlyPayment, 
	RefinancedCurrentBalance = ROL.RevisedCurrentBalance
FROM
	[Consumer].OtherLiability OL 
	JOIN [Plan].RevisedOtherLiability ROL 
		ON OL.OtherLiabilityId = ROL.OtherLiabilityId 
	LEFT JOIN Code.LookupItem LTC
		ON OL.LiabilityTypeCode = LTC.Code

GO




