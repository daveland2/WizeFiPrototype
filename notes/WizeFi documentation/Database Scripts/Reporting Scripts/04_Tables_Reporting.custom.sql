
IF SCHEMA_ID('Reporting') IS NULL
	EXEC('CREATE SCHEMA [Reporting]') 
GO


/*HACK: This is just a port over from v1 which was largely a port over from the MS Access DB.
		This report and underlying artifacts need to be deleted and the whole thing started from scratch
*/


PRINT 'Add reporting calc tables'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.CafrCalculation')) 
	DROP TABLE Reporting.CafrCalculation
GO
CREATE TABLE Reporting.CafrCalculation (
	[PlanRevisionId] [ReferenceID] NOT NULL,
	[CAFRMth] [int] NOT NULL ,
	[CAFR] [Currency] NULL ,
	[DebtExtraCAFRPrev] [Currency] NULL ,
	[EmergOpenBal] [Currency] NULL ,
	[EmergBudgetCont] [Currency] NULL ,
	[EmergCAFRCont] [Currency] NULL ,
	[EmergCloseBal] [Currency] NULL ,
	[EmergCloseBalCurrent] [Currency] NULL ,
	[CashResOpenBal] [Currency] NULL ,
	[CashResBudgetCont] [Currency] NULL ,
	[CashResCAFRCont] [Currency] NULL ,
	[CashResCloseBal] [Currency] NULL ,
	[CashResCloseBalCurrent] [Currency] NULL ,
	[DebtOpenBal] [Currency] NULL ,
	[DebtMinPayment] [Currency] NULL ,
	[DebtCAFRCont] [Currency] NULL ,
	[DebtCAFRContMort] [Currency] NULL ,
	[DebtCAFRContConsumer] [Currency] NULL ,
	[DebtPrincipal] [Currency] NULL ,
	[DebtInterest] [Currency] NULL ,
	[DebtInterestMort] [Currency] NULL ,
	[DebtInterestConsumer] [Currency] NULL ,
	[DebtCloseBal] [Currency] NULL ,
	[DebtCloseBalMort] [Currency] NULL ,
	[DebtCloseBalConsumer] [Currency] NULL ,
	[DebtInterestCurrent] [Currency] NULL ,
	[DebtInterestMortCurrent] [Currency] NULL ,
	[DebtInterestConsumerCurrent] [Currency] NULL ,
	[DebtCloseBalCurrent] [Currency] NULL ,
	[DebtCloseBalMortCurrent] [Currency] NULL ,
	[DebtCloseBalConsumerCurrent] [Currency] NULL ,
	[InvestOpenBal] [Currency] NULL ,
	[InvestInterest] [Currency] NULL ,
	[InvestCont] [Currency] NULL ,
	[InvestCAFRCont] [Currency] NULL ,
	[InvestCloseBal] [Currency] NULL ,
	[InvestCloseBalCurrent] [Currency] NULL ,
	[RealEstateValue] [Currency] NULL,
	[AutoValue] [Currency] NULL,
	[PersonalPropValue] [Currency] NULL,
	[ExtraCAFR] [Currency] NULL,
	[DebtExtraCAFR] [Currency] NULL ,
	[CAFRAmtLeft] [Currency] NULL,
	CONSTRAINT [PK_CafrCalculation] PRIMARY KEY CLUSTERED
	(
		[PlanRevisionId],
		[CAFRMth]
	)
) -- Last 1 field only for testing - should be 0 at end of each year
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.ClientDebt')) 
	DROP TABLE Reporting.ClientDebt
GO

CREATE TABLE Reporting.ClientDebt (
	[PlanRevisionId] [ReferenceID] NOT NULL,
	[Counter] [int] NOT NULL,
	[LiabilityType] [varchar] (150) COLLATE Latin1_General_CI_AS NULL ,
	[LiabilityType2] [varchar] (150) COLLATE Latin1_General_CI_AS NULL ,
	[ClientAssetIDNo] [ReferenceID] NULL ,
	[LiabilityDescription] [varchar] (150) COLLATE Latin1_General_CI_AS NULL ,
	[Owner] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[CreditorName] [varchar] (150) COLLATE Latin1_General_CI_AS NULL ,
	[YrsFixed] [smallint] NULL ,
	[YrsIntOnly] [smallint] NULL ,
	[IntOnlyCeaseDte] [datetime] NULL ,
	[IntOnlyCAFRAdjust] [smallint] NULL ,
	[InterestRate] [Rate] NULL ,
	[CurrentBalance] [Currency] NULL ,
	[CurrentBalanceCurrent] [Currency] NULL ,
	[MthlyPaymentIntOnly] [Currency] NULL ,
	[MthlyPayment] [Currency] NULL ,
	[MthlyPaymentImp] [Currency] NULL ,
	[SortOrder] [smallint] NULL,
	CONSTRAINT [PK_ClientDebt] PRIMARY KEY CLUSTERED
	(
		[PlanRevisionId],
		[Counter]
	)
) 
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.ClientDebtCafr')) 
	DROP TABLE Reporting.ClientDebtCafr
GO

CREATE TABLE Reporting.ClientDebtCafr (
	[PlanRevisionId] [ReferenceID] NOT NULL,
	[ClientDebtIDNo] [ReferenceID] NOT NULL ,
	[CAFRMth] [int] NOT NULL ,
	[LiabilityType] [varchar] (150) NULL ,
	[DebtOpenBal] [Currency] NULL ,
	[DebtMinPayment] [Currency] NULL ,
	[DebtCAFRPayment] [Currency] NULL ,
	[DebtCAFRPaymtMort] [Currency] NULL ,
	[DebtCAFRPaymtConsumer] [Currency] NULL ,
	[DebtPrincipal] [Currency] NULL ,
	[DebtInterest] [Currency] NULL ,
	[DebtInterestCurrent] [Currency] NULL ,
	[DebtCloseBal] [Currency] NULL ,
	[DebtCloseBalCurrent] [Currency] NULL,
	CONSTRAINT [PK_ClientDebtCafr] PRIMARY KEY CLUSTERED
	(
		[PlanRevisionId],
		[ClientDebtIDNo],
		[CAFRMth]
	)
) 
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.ClientInvest')) 
	DROP TABLE Reporting.ClientInvest
GO

CREATE TABLE Reporting.ClientInvest (
	[PlanRevisionId] [ReferenceID] NOT NULL,
	[Counter] [int] NOT NULL,
	[Owner] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Description] [varchar] (150) COLLATE Latin1_General_CI_AS NULL ,
	[Description2] [varchar] (150) COLLATE Latin1_General_CI_AS NULL ,
	[AccountNo] [varchar] (20) COLLATE Latin1_General_CI_AS NULL ,
	[MarketValue] [Currency] NULL ,
	[MarketValueCurrent] [Currency] NULL ,
	[Contributions] [Currency] NULL ,
	[ContributionsImp] [Currency] NULL ,
	[InterestRate] [Rate] NULL ,
	[InvestmentType] [varchar] (150) COLLATE Latin1_General_CI_AS NULL ,
	[SortOrder] [smallint] NULL,
	CONSTRAINT [PK_ClientInvest] PRIMARY KEY CLUSTERED
	(
		[PlanRevisionId],
		[Counter]
	)
) 
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.ClientInvestCafr')) 
	DROP TABLE Reporting.ClientInvestCafr
GO

CREATE TABLE Reporting.ClientInvestCafr (
	[PlanRevisionId] [ReferenceID] NOT NULL,
	[ClientInvestIDNo] [ReferenceID] NOT NULL ,
	[CAFRMth] [int] NOT NULL ,
	[InvestOpenBal] [Currency] NULL ,
	[InvestInterest] [Currency] NULL ,
	[InvestCont] [Currency] NULL ,
	[InvestCAFRCont] [Currency] NULL ,
	[InvestCloseBal] [Currency] NULL ,
	[InvestCloseBalCurrent] [Currency] NULL
	CONSTRAINT [PK_ClientInvestCafr] PRIMARY KEY CLUSTERED
	(
		[PlanRevisionId],
		[ClientInvestIDNo],
		[CAFRMth]
	)
) 
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'Reporting.ClientAsset')) 
	DROP TABLE Reporting.ClientAsset
GO

CREATE TABLE Reporting.ClientAsset (
	[PlanRevisionId] [ReferenceID] NOT NULL,
	[Counter] [int] NOT NULL,
	[AssetType] [varchar] (50) NULL,
	[MarketValue] [Currency] NULL ,
	[InterestRate] [Rate] NULL,
	CONSTRAINT [PK_ClientAsset] PRIMARY KEY CLUSTERED
	(
		[PlanRevisionId],
		[Counter]
	)
) 
GO
