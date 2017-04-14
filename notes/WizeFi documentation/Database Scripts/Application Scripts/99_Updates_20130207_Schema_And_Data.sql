

ALTER TABLE Consumer.RealEstateLiability
ALTER COLUMN [CreditorName] [varchar](80) NOT NULL
ALTER TABLE Consumer.RealEstateLiability
ALTER COLUMN Comments [VARCHAR](1000) NOT NULL
GO

ALTER TABLE Consumer.RealEstateAsset
ALTER COLUMN Comments [VARCHAR](1000) NOT NULL
GO

ALTER TABLE Consumer.EstatePlanning
ALTER COLUMN Comments [VARCHAR](8000) NOT NULL
GO

ALTER TABLE Consumer.FinancialGoal
ALTER COLUMN Comments [VARCHAR](4000) NOT NULL
GO