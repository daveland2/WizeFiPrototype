SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO



/*
	These are going to be linking fields to help thread an inventory item through revisions 
	This is not going to be generated because it will impede the need to have these default to NewID() when new
	but allow be inserted into during copy which is not likely to be done inside the application. If it were to be,
	then this could go away and the model updated to includes these fields. 
	
	The primary use of these immediately is to
	facilitate the ability to copy the Plan's base values from the respective Consumer table. Otherwise, impossible to 
	link all the items together when copying.
*/

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

GO








