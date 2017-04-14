
--Insert lookups
INSERT INTO [Code].[Lookup] ([Name], [Description])
SELECT		 'Client Owner', ''
UNION SELECT 'Estate Planning Type', ''
UNION SELECT 'Family Relationship', ''
UNION SELECT 'Partner Relationship', ''
UNION SELECT 'Beneficiary', ''
UNION SELECT 'Personal Property Type', ''
UNION SELECT 'Real Estate Property Type', ''
UNION SELECT 'Tax Savings Plan', ''
UNION SELECT 'Financial Account Type', ''
UNION SELECT 'Insurance Type', ''
UNION SELECT 'Mortgage Type', ''
UNION SELECT 'Other Liability Type', ''
UNION SELECT 'Advisor Type', ''
UNION SELECT 'Advisor Ranking', ''
UNION SELECT 'Recommendation Category', ''
UNION SELECT 'Refinance Type', ''
UNION SELECT 'Integration Partner', ''
UNION SELECT 'Integration Direction', ''
UNION SELECT 'Integration Partner Mapping', ''
UNION SELECT 'Integration Local Area', ''

GO


--Insert Client Owner
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Client Owner'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Primary', 'CO-PRI', '', 5
UNION SELECT @LookupId, 'Secondary', 'CO-SEC', '', 10
UNION SELECT @LookupId, 'Joint', 'CO-JNT', '', 15
UNION SELECT @LookupId, 'Other', 'CO-OTH', '', 20
GO


--Insert Estate Planning Type
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Estate Planning Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Wills', 'EPT-WILL', '', 5
UNION SELECT @LookupId, 'Living Wills', 'EPT-LVWL', '', 10
UNION SELECT @LookupId, 'Power of Attorney', 'EPT-ATT', '', 15
UNION SELECT @LookupId, 'Living Trusts', 'EPT-LT', '', 20
UNION SELECT @LookupId, 'Other', 'EPT-OTH', '', 99
GO


--Insert Family Relationship
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Family Relationship'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Son', 'FAM-SON', '', 5
UNION SELECT @LookupId, 'Daughter', 'FAM-DTR', '', 10
UNION SELECT @LookupId, 'Other', 'FAM-OTH', '', 99
GO


--Insert Partner Relationship
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Partner Relationship'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Spouse', 'PRT-SPO', '', 5
UNION SELECT @LookupId, 'Cohabitation', 'PRT-COHA', '', 10
UNION SELECT @LookupId, 'Other', 'PRT-OTH', '', 99
GO


--Insert Beneficiary
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Beneficiary'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Self', 'BEN-SELF', '', 5
UNION SELECT @LookupId, 'Spouse', 'BEN-SPO', '', 10
UNION SELECT @LookupId, 'All Children', 'BEN-CHDN', '', 15
UNION SELECT @LookupId, 'Estate', 'BEN-EST', '', 20
UNION SELECT @LookupId, 'Other', 'BEN-OTH', '', 99
GO


--Insert Personal Property Type
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Personal Property Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Automobile', 'PPT-AUTO', '', 5
UNION SELECT @LookupId, 'Recreational Vehicle', 'PPT-RV', '', 10
UNION SELECT @LookupId, 'Collectibles', 'PPT-COLL', '', 15
UNION SELECT @LookupId, 'Other', 'PPT-OTH', '', 99
GO


--Insert Real Estate Property Type
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Real Estate Property Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Primary Residence', 'REAL-PRI', '', 5
UNION SELECT @LookupId, 'Second Home', 'REAL-SEC', '', 10
UNION SELECT @LookupId, 'Rental', 'REAL-REN', '', 15
UNION SELECT @LookupId, 'Land', 'REAL-LND', '', 20
UNION SELECT @LookupId, 'Commercial', 'REAL-COM', '', 25
UNION SELECT @LookupId, 'Other', 'REAL-OTH', '', 99
GO


--Insert Tax Savings Plan
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Tax Savings Plan'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder, NumericData)
SELECT		 @LookupId, 'IRA', 'TAX-IRA', '', 5, 1
UNION SELECT @LookupId, 'Roth IRA', 'TAX-ROTH', '', 10, 0
UNION SELECT @LookupId, 'SEP IRA', 'TAX-SEP', '', 15, 0
UNION SELECT @LookupId, 'Simple IRA', 'TAX-SIRA', '', 20, 0
UNION SELECT @LookupId, '401(k)', 'TAX-401K', '', 25, 1
UNION SELECT @LookupId, 'Roth 401(k)', 'TAX-R401', '', 30, 0
UNION SELECT @LookupId, '403(b)', 'TAX-403B', '', 35, 1
UNION SELECT @LookupId, '457(b)', 'TAX-457B', '', 40, 1
UNION SELECT @LookupId, 'Pension', 'TAX-PENS', '', 45, 1
UNION SELECT @LookupId, 'Annuity', 'TAX-ANN', '', 47, 0
UNION SELECT @LookupId, 'HSA', 'TAX-HSA', '', 50, 0
UNION SELECT @LookupId, 'College Fund', 'TAX-CLGE', '', 55, 0
UNION SELECT @LookupId, 'Other', 'TAX-OTH', '', 99, 1
GO


--Insert Financial Account Type
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Financial Account Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Emergency Fund', 'ACCT-EMG', '', 5
UNION SELECT @LookupId, 'Money Market', 'ACCT-MMA', '', 10
UNION SELECT @LookupId, 'General Savings', 'ACCT-GEN', '', 15
UNION SELECT @LookupId, 'Christmas Fund', 'ACCT-XMS', '', 20
UNION SELECT @LookupId, 'Vacation Fund', 'ACCT-VAC', '', 25
GO


--Insert Insurance Type
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Insurance Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Life: Term', 'INS-TERM', '', 5
UNION SELECT @LookupId, 'Life: Whole', 'INS-WHOL', '', 10
UNION SELECT @LookupId, 'Life: Universal', 'INS-UNIV', '', 15
UNION SELECT @LookupId, 'Life: Variable Universal', 'INS-VARU', '', 20
UNION SELECT @LookupId, 'Life: Group', 'INS-GRP', '', 22
UNION SELECT @LookupId, 'Health: Medical', 'INS-MED', '', 25
UNION SELECT @LookupId, 'Health: Dental', 'INS-DENT', '', 30
UNION SELECT @LookupId, 'Health: Vision', 'INS-VIS', '', 35
UNION SELECT @LookupId, 'Disability', 'INS-DIS', '', 40
UNION SELECT @LookupId, 'Long Term Care', 'INS-LTC', '', 45
UNION SELECT @LookupId, 'Homeowners', 'INS-HO', '', 50
UNION SELECT @LookupId, 'Auto', 'INS-AUTO', '', 55
UNION SELECT @LookupId, 'Recreational Vehicle', 'INS-RV', '', 60
UNION SELECT @LookupId, 'Umbrella', 'INS-UMB', '', 65
UNION SELECT @LookupId, 'E&O', 'INS-EO', '', 70
UNION SELECT @LookupId, 'Other', 'INS-OTH', '', 99
GO


--Insert Mortgage Type
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Mortgage Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Mortgage (Fixed)', 'MORT-FIX', '', 5
UNION SELECT @LookupId, 'Mortgage (ARM)', 'MORT-ARM', '', 10
UNION SELECT @LookupId, 'Mortgage (Interest Only)', 'MORT-INT', '', 15
UNION SELECT @LookupId, 'Line of Credit', 'MORT-LOC', '', 20
UNION SELECT @LookupId, 'Other', 'MORT-OTH', '', 99
GO


--Insert Other Liability Type
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Other Liability Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Credit Card', 'LIA-CC', '', 5
UNION SELECT @LookupId, 'Line of Credit', 'LIA-LOC', '', 10
UNION SELECT @LookupId, 'Auto', 'LIA-AUTO', '', 15
UNION SELECT @LookupId, 'RV Payment', 'LIA-RV', '', 20
UNION SELECT @LookupId, 'Personal Loan', 'LIA-PERS', '', 25
UNION SELECT @LookupId, 'Business Loan', 'LIA-BIZ', '', 30
UNION SELECT @LookupId, 'Student Loan', 'LIA-STUD', '', 35
UNION SELECT @LookupId, 'Other', 'LIA-OTH', '', 99
GO


--Insert Advisor Type
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Advisor Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Estate Attorney', 'ADV-ATT', '', 5
UNION SELECT @LookupId, 'Tax Attorney', 'ADV-TAX', '', 10
UNION SELECT @LookupId, 'CPA / Tax Preparer', 'ADV-CPA', '', 15
UNION SELECT @LookupId, 'Insurance Agent', 'ADV-INS', '', 20
UNION SELECT @LookupId, 'Mortgage Broker / Loan Officer', 'ADV-MORT', '', 25
GO


--Insert Advisor Ranking
DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Advisor Ranking'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Please Select', 'RNK-UNSE', '', 0
UNION SELECT @LookupId, 'Satisfied', 'RNK-SAT', '', 5
UNION SELECT @LookupId, 'Dissatisfied', 'RNK-DIS', '', 10
UNION SELECT @LookupId, 'Need Referral For', 'RNK-REF', '', 15
UNION SELECT @LookupId, 'Unsure', 'RNK-IDK', '', 20
UNION SELECT @LookupId, 'Not Applicable', 'RNK-NA', '', 25
GO


--Insert Recommendation Category
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


--Insert Recommendation Template
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


DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Refinance Type'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'First Mortgage', 'REF-FIR', '', 5
UNION SELECT @LookupId, 'Second Mortgage', 'REF-SEC', '', 10
UNION SELECT @LookupId, 'Other', 'REF-OTH', '', 15
GO


DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Integration Partner'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder, NumericData)
SELECT		 @LookupId, 'Redtail CRM', 'INT-RED', 'RT', 5, 1
GO


DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Integration Direction'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder, NumericData)
SELECT		 @LookupId, 'Import into MOPRO Only', 'DIR-IMP', '', 5
UNION SELECT @LookupId, 'Export out of MOPRO Only', 'DIR-EXP', '', 10
UNION SELECT @LookupId, 'Both Directions', 'DIR-BOTH', '', 15
GO


SELECT		 @LookupId, 'Do Not Import', 'RT-SKIP', '', 0, 1

UNION SELECT @LookupId, 'Profile Information', 'RT-PROF', '', 0, 1
UNION SELECT @LookupId, 'Family Member', 'RT-FAM', '', 1, 1

UNION SELECT @LookupId, 'Account: 401(k)', 'RT-ACT07', '', 2, 1
UNION SELECT @LookupId, 'Account: 529 Plan', 'RT-ACT12', '', 3, 1
UNION SELECT @LookupId, 'Account: Brokerage Account', 'RT-ACT03', '', 4, 1
UNION SELECT @LookupId, 'Account: Cash Management Account', 'RT-ACT23', '', 5, 1
UNION SELECT @LookupId, 'Account: Cash or Equivalents', 'RT-ACT38', '', 6, 1
UNION SELECT @LookupId, 'Account: Disability Insurance', 'RT-ACT17', '', 7, 1
UNION SELECT @LookupId, 'Account: Donor Advised Fund', 'RT-ACT24', '', 8, 1
UNION SELECT @LookupId, 'Account: Educational Savings Account', 'RT-ACT34', '', 9, 1
UNION SELECT @LookupId, 'Account: Fee-Based Account', 'RT-ACT08', '', 10, 1
UNION SELECT @LookupId, 'Account: Financial Plan', 'RT-ACT14', '', 11, 1
UNION SELECT @LookupId, 'Account: Fixed Annuity', 'RT-ACT06', '', 12, 1
UNION SELECT @LookupId, 'Account: Group Dental', 'RT-ACT29', '', 13, 1
UNION SELECT @LookupId, 'Account: Group Disability', 'RT-ACT32', '', 14, 1
UNION SELECT @LookupId, 'Account: Group Life', 'RT-ACT35', '', 15, 1
UNION SELECT @LookupId, 'Account: Group Long Term Care', 'RT-ACT31', '', 16, 1
UNION SELECT @LookupId, 'Account: Group Medical', 'RT-ACT28', '', 17, 1
UNION SELECT @LookupId, 'Account: Group Voluntary Life', 'RT-ACT36', '', 18, 1
UNION SELECT @LookupId, 'Account: Indexed Annuity', 'RT-ACT21', '', 19, 1
UNION SELECT @LookupId, 'Account: Individual Dental', 'RT-ACT30', '', 20, 1
UNION SELECT @LookupId, 'Account: Individual Life', 'RT-ACT22', '', 21, 1
UNION SELECT @LookupId, 'Account: Individual Medical', 'RT-ACT27', '', 22, 1
UNION SELECT @LookupId, 'Account: ISI Capital Account', 'RT-ACT09', '', 23, 1
UNION SELECT @LookupId, 'Account: Long Term Care', 'RT-ACT18', '', 24, 1
UNION SELECT @LookupId, 'Account: Long Term Disability', 'RT-ACT16', '', 25, 1
UNION SELECT @LookupId, 'Account: Medicare Advantage Plan', 'RT-ACT40', '', 26, 1
UNION SELECT @LookupId, 'Account: Medicare Prescription Drug Plan (Part D)', 'RT-ACT41', '', 27, 1
UNION SELECT @LookupId, 'Account: Medicare Supplement Plan', 'RT-ACT42', '', 28, 1
UNION SELECT @LookupId, 'Account: Mutual Fund', 'RT-ACT04', '', 29, 1
UNION SELECT @LookupId, 'Account: Other', 'RT-ACT13', '', 30, 1
UNION SELECT @LookupId, 'Account: Pooled Income Fund', 'RT-ACT26', '', 31, 1
UNION SELECT @LookupId, 'Account: Profit Sharing', 'RT-ACT11', '', 32, 1
UNION SELECT @LookupId, 'Account: REIT', 'RT-ACT33', '', 33, 1
UNION SELECT @LookupId, 'Account: Return of Premium Term Life Insurance', 'RT-ACT43', '', 34, 1
UNION SELECT @LookupId, 'Account: Select Roth IRA', 'RT-ACT44', '', 35, 1
UNION SELECT @LookupId, 'Account: Separately Managed Account', 'RT-ACT25', '', 36, 1
UNION SELECT @LookupId, 'Account: Sole 401(k)', 'RT-ACT15', '', 37, 1
UNION SELECT @LookupId, 'Account: Term Life', 'RT-ACT05', '', 38, 1
UNION SELECT @LookupId, 'Account: Universal Life', 'RT-ACT19', '', 39, 1
UNION SELECT @LookupId, 'Account: Variable Annuity', 'RT-ACT01', '', 40, 1
UNION SELECT @LookupId, 'Account: Variable Life', 'RT-ACT39', '', 41, 1
UNION SELECT @LookupId, 'Account: Variable Universal Life', 'RT-ACT02', '', 42, 1
UNION SELECT @LookupId, 'Account: Whole Life', 'RT-ACT20', '', 43, 1
UNION SELECT @LookupId, 'Account: Worker''s Comp', 'RT-ACT37', '', 44, 1

UNION SELECT @LookupId, 'Account: Tax Type - None', 'RT-TXT00', '', 47, 1
UNION SELECT @LookupId, 'Account: Tax Type - 401(a)', 'RT-TXT21', '', 48, 1
UNION SELECT @LookupId, 'Account: Tax Type - 401(k)', 'RT-TXT07', '', 49, 1
UNION SELECT @LookupId, 'Account: Tax Type - 403(a)', 'RT-TXT22', '', 50, 1
UNION SELECT @LookupId, 'Account: Tax Type - 403(b)', 'RT-TXT03', '', 51, 1
UNION SELECT @LookupId, 'Account: Tax Type - 457 Plan', 'RT-TXT04', '', 52, 1
UNION SELECT @LookupId, 'Account: Tax Type - 529 Plan', 'RT-TXT15', '', 53, 1
UNION SELECT @LookupId, 'Account: Tax Type - Beneficiary IRA', 'RT-TXT20', '', 54, 1
UNION SELECT @LookupId, 'Account: Tax Type - Educational IRA', 'RT-TXT05', '', 55, 1
UNION SELECT @LookupId, 'Account: Tax Type - Health Savings Account', 'RT-TXT17', '', 56, 1
UNION SELECT @LookupId, 'Account: Tax Type - HR10', 'RT-TXT06', '', 57, 1
UNION SELECT @LookupId, 'Account: Tax Type - Medical Savings Account', 'RT-TXT18', '', 58, 1
UNION SELECT @LookupId, 'Account: Tax Type - Non Deductible IRA', 'RT-TXT19', '', 59, 1
UNION SELECT @LookupId, 'Account: Tax Type - Other', 'RT-TXT09', '', 60, 1
UNION SELECT @LookupId, 'Account: Tax Type - Pension Plan', 'RT-TXT08', '', 61, 1
UNION SELECT @LookupId, 'Account: Tax Type - Profit Sharing Plan', 'RT-TXT12', '', 62, 1
UNION SELECT @LookupId, 'Account: Tax Type - Rollover IRA', 'RT-TXT16', '', 63, 1
UNION SELECT @LookupId, 'Account: Tax Type - Roth IRA', 'RT-TXT01', '', 64, 1
UNION SELECT @LookupId, 'Account: Tax Type - SEP IRA', 'RT-TXT10', '', 65, 1
UNION SELECT @LookupId, 'Account: Tax Type - Simple IRA', 'RT-TXT11', '', 66, 1
UNION SELECT @LookupId, 'Account: Tax Type - Traditional IRA', 'RT-TXT02', '', 67, 1
UNION SELECT @LookupId, 'Account: Tax Type - UGMA', 'RT-TXT14', '', 68, 1
UNION SELECT @LookupId, 'Account: Tax Type - UTMA', 'RT-TXT13', '', 69, 1

UNION SELECT @LookupId, 'Asset: None', 'RT-AST00', '', 72, 1
UNION SELECT @LookupId, 'Asset: 401(k)', 'RT-AST17', '', 73, 1
UNION SELECT @LookupId, 'Asset: Annuity', 'RT-AST15', '', 74, 1
UNION SELECT @LookupId, 'Asset: Automobile', 'RT-AST11', '', 75, 1
UNION SELECT @LookupId, 'Asset: Bond', 'RT-AST10', '', 76, 1
UNION SELECT @LookupId, 'Asset: Brokerage Account', 'RT-AST19', '', 77, 1
UNION SELECT @LookupId, 'Asset: CD', 'RT-AST04', '', 78, 1
UNION SELECT @LookupId, 'Asset: Checking Account', 'RT-AST01', '', 79, 1
UNION SELECT @LookupId, 'Asset: Collectables', 'RT-AST16', '', 80, 1
UNION SELECT @LookupId, 'Asset: IRA', 'RT-AST13', '', 81, 1
UNION SELECT @LookupId, 'Asset: Life Insurance', 'RT-AST18', '', 82, 1
UNION SELECT @LookupId, 'Asset: Managed Accounts', 'RT-AST12', '', 83, 1
UNION SELECT @LookupId, 'Asset: Money Market', 'RT-AST03', '', 84, 1
UNION SELECT @LookupId, 'Asset: Mutual Fund', 'RT-AST07', '', 85, 1
UNION SELECT @LookupId, 'Asset: Other', 'RT-AST09', '', 86, 1
UNION SELECT @LookupId, 'Asset: Pension', 'RT-AST14', '', 87, 1
UNION SELECT @LookupId, 'Asset: Real Estate', 'RT-AST08', '', 88, 1
UNION SELECT @LookupId, 'Asset: Savings Account', 'RT-AST02', '', 89, 1
UNION SELECT @LookupId, 'Asset: Stock', 'RT-AST06', '', 90, 1
UNION SELECT @LookupId, 'Asset: T-Bill', 'RT-AST05', '', 91, 1

UNION SELECT @LookupId, 'Liability: None', 'RT-LIA00', '', 92, 1
UNION SELECT @LookupId, 'Liability: Auto Loan', 'RT-LIA01', '', 93, 1
UNION SELECT @LookupId, 'Liability: Credit Card Debt', 'RT-LIA02', '', 94, 1
UNION SELECT @LookupId, 'Liability: Mortgage', 'RT-LIA03', '', 95, 1
UNION SELECT @LookupId, 'Liability: Other', 'RT-LIA04', '', 96, 1
UNION SELECT @LookupId, 'Liability: Personal Loan', 'RT-LIA05', '', 97, 1
GO



DECLARE @LookupId INT
SELECT @LookupId = LookupId FROM [Code].[Lookup] WHERE [Name] = 'Integration Local Area'

INSERT INTO [Code].[LookupItem] ([LookupId], [Name], [Code], [Description], SortOrder)
SELECT		 @LookupId, 'Do Not Import', 'MOP-SKIP', '', 0
UNION SELECT @LookupId, 'Profile Information', 'MOP-PROF', '', 3
UNION SELECT @LookupId, 'Family Member', 'MOP-FAM', '', 7
UNION SELECT @LookupId, 'Asset: Bank Account', 'MOP-BANK', '', 10
UNION SELECT @LookupId, 'Asset: Asset Protection', 'MOP-ASST', '', 15
UNION SELECT @LookupId, 'Asset: CDs', 'MOP-CD', '', 20
UNION SELECT @LookupId, 'Asset: Taxable', 'MOP-TAX', '', 30
UNION SELECT @LookupId, 'Asset: Tax-Advantaged', 'MOP-NOTX', '', 40
UNION SELECT @LookupId, 'Asset: Real-Estate', 'MOP-REAL', '', 50
UNION SELECT @LookupId, 'Asset: Personal', 'MOP-PERS', '', 60
UNION SELECT @LookupId, 'Asset: Other', 'MOP-OTH', '', 70
UNION SELECT @LookupId, 'Liability: Real-Estate', 'MOP-LI-P', '', 80
UNION SELECT @LookupId, 'Liability: Other', 'MOP-LI-O', '', 90
GO


--Default the Description if not provided
UPDATE [Code].[Lookup] 
SET [Description] = [Name]
WHERE [Description] = ''

UPDATE [Code].[LookupItem] 
SET [Description] = [Name]
WHERE [Description] = ''
GO





