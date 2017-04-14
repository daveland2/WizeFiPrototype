
ALTER TABLE [Consumer].PrimaryConsumer 
ADD UserPin VARCHAR(30) NOT NULL DEFAULT('')
GO

ALTER TABLE [Consumer].PrimaryConsumer 
ALTER COLUMN UserPin VARCHAR(30) NOT NULL 
GO



DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Tax Savings Plan'
INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT @LookupId, 'Annuity', 'TAX-ANN', '', 47
GO


ALTER TABLE Membership.Account.UserMapping
DROP CONSTRAINT [AK_UserMapping_Unique]
GO

ALTER TABLE Membership.Account.UserMapping
ADD CONSTRAINT [AK_UserMapping_Unique] UNIQUE CLUSTERED 
(
	[ApplicationId] ASC,
	[ApplicationAccountType] ASC,
	[ApplicationMappingId] ASC
)
GO



--Increases for longer, encrypted columns since needs more room
ALTER TABLE [Consumer].PrimaryConsumer
ALTER COLUMN FirstName VARCHAR(60) NOT NULL 
GO
ALTER TABLE [Consumer].PrimaryConsumer
ALTER COLUMN LastName VARCHAR(60) NOT NULL 
GO
ALTER TABLE [Consumer].PrimaryConsumer
ALTER COLUMN Email VARCHAR(200) NOT NULL 
GO
ALTER TABLE [Consumer].PrimaryConsumer 
ALTER COLUMN PhysicalAddressLine VARCHAR(200) NOT NULL 
GO
ALTER TABLE [Consumer].PrimaryConsumer 
ALTER COLUMN PhysicalCity VARCHAR(70) NOT NULL 
GO

ALTER TABLE [Consumer].SecondaryConsumer
ALTER COLUMN FirstName VARCHAR(60) NOT NULL 
GO
ALTER TABLE [Consumer].SecondaryConsumer
ALTER COLUMN LastName VARCHAR(60) NOT NULL 
GO
ALTER TABLE [Consumer].SecondaryConsumer
ALTER COLUMN Email VARCHAR(200) NOT NULL 
GO
ALTER TABLE [Consumer].SecondaryConsumer 
ALTER COLUMN PhysicalAddressLine VARCHAR(200) NOT NULL 
GO
ALTER TABLE [Consumer].SecondaryConsumer 
ALTER COLUMN PhysicalCity VARCHAR(70) NOT NULL 
GO

ALTER TABLE [Consumer].FamilyMember 
ALTER COLUMN FirstName VARCHAR(60) NOT NULL 
GO
ALTER TABLE [Consumer].FamilyMember
ALTER COLUMN LastName VARCHAR(60) NOT NULL 
GO
ALTER TABLE [Consumer].FamilyMember
ALTER COLUMN Email VARCHAR(200) NOT NULL 
GO
ALTER TABLE [Consumer].FamilyMember 
ALTER COLUMN PhysicalAddressLine VARCHAR(200) NOT NULL 
GO
ALTER TABLE [Consumer].FamilyMember 
ALTER COLUMN PhysicalCity VARCHAR(70) NOT NULL 
GO

ALTER TABLE [Consumer].PrimaryConsumerIncomeSource 
ALTER COLUMN Employer VARCHAR(100) NOT NULL 
GO
ALTER TABLE [Consumer].PrimaryConsumerIncomeSource 
ALTER COLUMN Title VARCHAR(100) NOT NULL 
GO

ALTER TABLE [Consumer].SecondaryConsumerIncomeSource 
ALTER COLUMN Employer VARCHAR(100) NOT NULL 
GO
ALTER TABLE [Consumer].SecondaryConsumerIncomeSource 
ALTER COLUMN Title VARCHAR(100) NOT NULL 
GO

ALTER TABLE [Consumer].BankAsset 
ALTER COLUMN BankName VARCHAR(60) NOT NULL 
GO

ALTER TABLE [Consumer].AssetProtection 
ALTER COLUMN InsuranceCompanyName VARCHAR(100) NOT NULL 
GO

ALTER TABLE [Consumer].CdAsset 
ALTER COLUMN [Description] VARCHAR(100) NOT NULL 
GO

ALTER TABLE [Consumer].TaxableInvestmentAsset 
ALTER COLUMN [Description] VARCHAR(100) NOT NULL 
GO

ALTER TABLE [Consumer].TaxAdvantagedAsset 
ALTER COLUMN [Description] VARCHAR(100) NOT NULL 
GO

ALTER TABLE [Consumer].RealEstateAsset 
ALTER COLUMN [Description] VARCHAR(140) NOT NULL 
GO

ALTER TABLE [Consumer].PersonalAsset 
ALTER COLUMN [Description] VARCHAR(100) NOT NULL 
GO

ALTER TABLE [Consumer].OtherLiability 
ALTER COLUMN [Description] VARCHAR(100) NOT NULL 
GO


