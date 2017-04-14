
ALTER TABLE Consumer.TaxAdvantagedAsset
ADD 
	EmployerMonthlyPercentMaximum [decimal] NOT NULL DEFAULT(0)
ALTER TABLE Consumer.TaxAdvantagedAsset
ALTER COLUMN EmployerMonthlyPercentMaximum [Factor] NOT NULL

GO

ALTER TABLE Consumer.RealEstateLiability
ALTER COLUMN
	InstallmentDate [smalldatetime] NULL
GO

--TODO: Delete the SecondaryPreRetirement fields


ALTER TABLE Consumer.PrimaryConsumerIncomeDeductions
ADD
	[RetirementPlanTypeCode] [AltKey] NULL
		CONSTRAINT [FK_PrimaryConsumerIncomeDeductions_RetirementPlanType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[RetirementMonthlyPercentContributions] [decimal] NOT NULL DEFAULT(0),
	[RetirementMonthlyDollarContributions] [money] NOT NULL DEFAULT(0),
	[RetirementLoanBalance] [money] NOT NULL DEFAULT(0)
GO
ALTER TABLE Consumer.PrimaryConsumerIncomeDeductions
ALTER COLUMN [RetirementMonthlyPercentContributions] [Factor] NOT NULL
ALTER TABLE Consumer.PrimaryConsumerIncomeDeductions
ALTER COLUMN [RetirementMonthlyDollarContributions] [Currency] NOT NULL
ALTER TABLE Consumer.PrimaryConsumerIncomeDeductions
ALTER COLUMN [RetirementLoanBalance] [Currency] NOT NULL
GO

ALTER TABLE Consumer.SecondaryConsumerIncomeDeductions
ADD
	[RetirementPlanTypeCode] [AltKey] NULL
		CONSTRAINT [FK_SecondaryConsumerIncomeDeductions_RetirementPlanType] FOREIGN KEY 
			REFERENCES [Code].[LookupItem] ([Code]), 
	[RetirementMonthlyPercentContributions] [decimal] NOT NULL DEFAULT(0),
	[RetirementMonthlyDollarContributions] [money] NOT NULL DEFAULT(0),
	[RetirementLoanBalance] [money] NOT NULL DEFAULT(0)
GO
ALTER TABLE Consumer.SecondaryConsumerIncomeDeductions
ALTER COLUMN [RetirementMonthlyPercentContributions] [Factor] NOT NULL
ALTER TABLE Consumer.SecondaryConsumerIncomeDeductions
ALTER COLUMN [RetirementMonthlyDollarContributions] [Currency] NOT NULL
ALTER TABLE Consumer.SecondaryConsumerIncomeDeductions
ALTER COLUMN [RetirementLoanBalance] [Currency] NOT NULL
GO



--Update tax lookup items to be flagged for user in deductions
UPDATE Code.LookupItem
SET NumericData = 1
WHERE Code IN ('TAX-401K', 'TAX-403B', 'TAX-457B', 'TAX-IRA', 'TAX-PENS', 'TAX-OTH')
GO


ALTER TABLE Consumer.TaxAdvantagedAsset
ADD 
	EmployerMonthlyDollarContributions [money] NOT NULL DEFAULT(0)
ALTER TABLE Consumer.TaxAdvantagedAsset
ALTER COLUMN EmployerMonthlyDollarContributions [Currency] NOT NULL
GO


--This was in release 25

ALTER TABLE Consumer.Baseline
ADD
	PublishDate [smalldatetime] NULL
GO
