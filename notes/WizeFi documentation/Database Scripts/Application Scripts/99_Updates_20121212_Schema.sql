
ALTER TABLE Consumer.Baseline
ADD
	NeedsReview [bit] NOT NULL DEFAULT(0)
GO
ALTER TABLE Consumer.Baseline
ALTER COLUMN
	NeedsReview [Boolean] NOT NULL
GO



