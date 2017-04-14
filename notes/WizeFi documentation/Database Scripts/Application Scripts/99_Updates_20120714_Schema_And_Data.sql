
ALTER TABLE [Consumer].[Baseline] 
ADD IsLocked [bit] NOT NULL DEFAULT(0)
GO

ALTER TABLE [Consumer].[Baseline] 
ALTER COLUMN IsLocked [Boolean] NOT NULL
GO


INSERT INTO [Code].[Lookup] ([Name], [Description])
SELECT 'Recommendation Category', ''
GO

DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Recommendation Category'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Annual Review', 'RC-REV', '', 5
UNION SELECT @LookupId, 'Asset Protection (Life Insurance)', 'RC-ASST', '', 10
UNION SELECT @LookupId, 'Budget', 'RC-BUD', '', 15
UNION SELECT @LookupId, 'Debt Management', 'RC-DEBT', '', 20
UNION SELECT @LookupId, 'Emergency Fund/Cash Reserve', 'RC-EMG', '', 25
UNION SELECT @LookupId, 'Investments/Retirement Savings', 'RC-INV', '', 30
GO

DECLARE @CatId VARCHAR(8)

SELECT @CatId = 'RC-BUD'
INSERT INTO [Plan].RecommendationTemplate (RecommendationCategoryCode, Recommendation, SortOrder)
SELECT @CatId, 'Implement a household budget plan that will enable your family to stick to the spending parameters detailed in the “Improved” budget and summarized in the “Stress-Free Budget”.  This will result in having the shown CAFR to allocate monthly to each Cornerstone per the Appendix schedules at the back of this plan.', 1

SELECT @CatId = RecommendationCategoryId FROM [Code].[RecommendationCategory] WHERE [Summary] = 'RC-ASST'
INSERT INTO [Plan].RecommendationTemplate (RecommendationCategoryCode, Recommendation, SortOrder)
SELECT		 @CatId, 'Obtain $0 additional life protection for client.  Set premium payments on auto deduct from checking.', 1
UNION SELECT @CatId, 'Obtain $0 additional life protection for spouse.  Set premium payments on auto deduct from checking.', 2
UNION SELECT @CatId, 'Have life insurance needs/coverage reviewed once per year.', 3

SELECT @CatId = 'RC-EMG'
INSERT INTO [Plan].RecommendationTemplate (RecommendationCategoryCode, Recommendation, SortOrder)
SELECT		 @CatId, 'Open two high-yield savings accounts to establish and maintain Emergency Fund and Cash Reserve accounts.', 1
UNION SELECT @CatId, 'Utilize proceeds from Mortgage Loan Refinance to deposit $1000 into the Emergency Fund.', 2
UNION SELECT @CatId, '"Make monthly deposits into Cash Reserve savings account according to the ""CAFR Distribution"" and “Emergency Fund/Cash Reserve” Appendix until Cash Reserve account balance is equal to 3 months of net income."', 3

SELECT @CatId = 'RC-DEBT'
INSERT INTO [Plan].RecommendationTemplate (RecommendationCategoryCode, Recommendation, SortOrder)
SELECT		 @CatId, 'Consider mortgage refinance transaction to save approximately $0.00 per month.  This will increase your monthly CAFR and strengthens the other Cornerstones of your finances in timelier manner.', 1
UNION SELECT @CatId, 'Make monthly payments according to the Debt Management CAFR appendix.', 2
UNION SELECT @CatId, 'Close all credit card accounts except for one card with a large available balance.  If you ever need to use this card, make sure to pay it off the next month.', 3
UNION SELECT @CatId, 'Do not take on any additional debt without first consulting your Personal Financial Consultant.', 4

SELECT @CatId = 'RC-INV'
INSERT INTO [Plan].RecommendationTemplate (RecommendationCategoryCode, Recommendation, SortOrder)
SELECT		 @CatId, 'Increase contributions to your 401k to maximize the employer’s matching program.', 1
UNION SELECT @CatId, 'Make monthly contributions to your retirement accounts per the amounts indicated on the “CAFR distribution” and “Investment/Retirement Savings Contribution” Appendix.  Make these contributions at the beginning of the month and do not wait to “see if you have enough left over at the end of the month” to determine if you will make a contribution or not.', 2
UNION SELECT @CatId, 'Talk to your Personal Financial Consultant about a comprehensive, detailed investment strategy plan.  This strategy planning process will determine what types of accounts to open and details about how much to contribute to which accounts.', 3

SELECT @CatId = 'RC-REV'
INSERT INTO [Plan].RecommendationTemplate (RecommendationCategoryCode, Recommendation, SortOrder)
SELECT @CatId, 'Schedule annual review with Personal Financial Consultant.  Date of review should be 12 months from date of 1st Money Organizer meeting.  Fiscal Fitness will contact you a few weeks prior to obtain an updated Client profile in order to have this information available for the meeting.', 1
GO




INSERT INTO [Code].[Lookup] ([Name], [Description])
SELECT 'Refinance Type', ''
GO

DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Refinance Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'First Mortgage', 'REF-FIR', '', 5
UNION SELECT @LookupId, 'Second Mortgage', 'REF-SEC', '', 10
UNION SELECT @LookupId, 'Other', 'REF-OTH', '', 15
GO
