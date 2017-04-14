

ALTER TABLE Consumer.OtherLiability
ALTER COLUMN Comments [VARCHAR](1000) NOT NULL
GO

ALTER TABLE Consumer.EstatePlanning
ALTER COLUMN Comments [VARCHAR](1000) NOT NULL
GO

ALTER TABLE Consumer.FinancialGoal
ALTER COLUMN Comments [VARCHAR](1000) NOT NULL
GO


UPDATE Integration.IntegrationAccount
SET IntegrationDirectionDefaultCode = 'DIR-BOTH'
WHERE IntegrationDirectionDefaultCode IS NULL
GO
