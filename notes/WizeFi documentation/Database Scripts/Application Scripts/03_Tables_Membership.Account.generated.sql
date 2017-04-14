SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO


USE Membership
GO 

IF SCHEMA_ID('Account') IS NULL
	EXEC('CREATE SCHEMA [Account]') 
GO




PRINT 'Add [ServiceType] table' 
IF OBJECT_ID(N'[Account].[ServiceType]') IS NOT NULL 
	DROP TABLE [Account].[ServiceType] 
GO
CREATE TABLE [Account].[ServiceType] ( 

	[ServiceTypeId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_ServiceType] PRIMARY KEY CLUSTERED,
	[Name] [varchar](30) NOT NULL,
	[Description] [varchar](256) NOT NULL,

	CONSTRAINT [AK_ServiceType_Unique] UNIQUE NONCLUSTERED 
	( 
		[Name]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Account].[ServiceType].[Name]'
EXEC sp_bindefault '[Default_String]', '[Account].[ServiceType].[Description]'
GO



PRINT 'Add [ServicePlan] table' 
IF OBJECT_ID(N'[Account].[ServicePlan]') IS NOT NULL 
	DROP TABLE [Account].[ServicePlan] 
GO
CREATE TABLE [Account].[ServicePlan] ( 

	[ServicePlanId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_ServicePlan] PRIMARY KEY CLUSTERED,
	[Name] [varchar](30) NOT NULL,
	[ServiceTypeId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_ServicePlan_ServiceType] FOREIGN KEY 
			REFERENCES [Account].[ServiceType] ([ServiceTypeId]), 
	[Description] [varchar](256) NOT NULL,
	[SeatMax] [smallint] NOT NULL,
	[SupportedLevel] [int] NOT NULL,
	[PaymentFrequency] [tinyint] NOT NULL,
	[PaymentLead] [tinyint] NOT NULL,
	[SupportedPaymentMethod] [int] NOT NULL,
	[IsArchived] [Boolean] NOT NULL,

	CONSTRAINT [AK_ServicePlan_Unique] UNIQUE NONCLUSTERED 
	( 
		[Name],
		[ServiceTypeId]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Account].[ServicePlan].[Name]'
EXEC sp_bindefault '[Default_String]', '[Account].[ServicePlan].[Description]'
GO



PRINT 'Add [ServicePolicy] table' 
IF OBJECT_ID(N'[Account].[ServicePolicy]') IS NOT NULL 
	DROP TABLE [Account].[ServicePolicy] 
GO
CREATE TABLE [Account].[ServicePolicy] ( 

	[ServicePolicyId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_ServicePolicy] PRIMARY KEY CLUSTERED,
	[Name] [varchar](30) NOT NULL,
	[Description] [varchar](256) NOT NULL,
	[PolicyRule] [varchar](256) NOT NULL,
	[Severity] [tinyint] NOT NULL,
	[IsArchived] [Boolean] NOT NULL,

	CONSTRAINT [AK_ServicePolicy_Unique] UNIQUE NONCLUSTERED 
	( 
		[Name]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Account].[ServicePolicy].[Name]'
EXEC sp_bindefault '[Default_String]', '[Account].[ServicePolicy].[Description]'
EXEC sp_bindrule '[Rule_Req_String]', '[Account].[ServicePolicy].[PolicyRule]'
GO



PRINT 'Add [ServicePlanPolicyOption] table' 
IF OBJECT_ID(N'[Account].[ServicePlanPolicyOption]') IS NOT NULL 
	DROP TABLE [Account].[ServicePlanPolicyOption] 
GO
CREATE TABLE [Account].[ServicePlanPolicyOption] ( 

	[ServicePlanPolicyOptionId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_ServicePlanPolicyOption] PRIMARY KEY NONCLUSTERED,
	[ServicePlanId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_ServicePlanPolicyOption_ServicePlan] FOREIGN KEY 
			REFERENCES [Account].[ServicePlan] ([ServicePlanId]), 
	[ServicePolicyId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_ServicePlanPolicyOption_ServicePolicy] FOREIGN KEY 
			REFERENCES [Account].[ServicePolicy] ([ServicePolicyId]), 

	CONSTRAINT [AK_ServicePlanPolicyOption_Unique] UNIQUE CLUSTERED 
	( 
		[ServicePlanId],
		[ServicePolicyId]
	)
) ON [PRIMARY]
GO



PRINT 'Add [Subscription] table' 
IF OBJECT_ID(N'[Account].[Subscription]') IS NOT NULL 
	DROP TABLE [Account].[Subscription] 
GO
CREATE TABLE [Account].[Subscription] ( 

	[SubscriptionId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_Subscription] PRIMARY KEY NONCLUSTERED,
	[UserId] [uniqueidentifier] NOT NULL,
	[ServicePlanId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_Subscription_ServicePlan] FOREIGN KEY 
			REFERENCES [Account].[ServicePlan] ([ServicePlanId]), 
	[DiscountAmount] [Currency] NOT NULL,
	[DiscountExplanation] [varchar](256) NOT NULL,
	[IsActive] [Boolean] NOT NULL,

	CONSTRAINT [AK_Subscription_Unique] UNIQUE CLUSTERED 
	( 
		[UserId]
	)
) ON [PRIMARY]
EXEC sp_bindefault '[Default_String]', '[Account].[Subscription].[DiscountExplanation]'
GO



PRINT 'Add [SubscriptionServicePolicy] table' 
IF OBJECT_ID(N'[Account].[SubscriptionServicePolicy]') IS NOT NULL 
	DROP TABLE [Account].[SubscriptionServicePolicy] 
GO
CREATE TABLE [Account].[SubscriptionServicePolicy] ( 

	[SubscriptionServicePolicyId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_SubscriptionServicePolicy] PRIMARY KEY NONCLUSTERED,
	[SubscriptionId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_SubscriptionServicePolicy_Subscription] FOREIGN KEY 
			REFERENCES [Account].[Subscription] ([SubscriptionId]), 
	[ServicePolicyId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_SubscriptionServicePolicy_ServicePolicy] FOREIGN KEY 
			REFERENCES [Account].[ServicePolicy] ([ServicePolicyId]), 

	CONSTRAINT [AK_SubscriptionServicePolicy_Unique] UNIQUE CLUSTERED 
	( 
		[SubscriptionId],
		[ServicePolicyId]
	)
) ON [PRIMARY]
GO



PRINT 'Add [SubscriptionPaymentHistory] table' 
IF OBJECT_ID(N'[Account].[SubscriptionPaymentHistory]') IS NOT NULL 
	DROP TABLE [Account].[SubscriptionPaymentHistory] 
GO
CREATE TABLE [Account].[SubscriptionPaymentHistory] ( 

	[SubscriptionPaymentHistoryId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_SubscriptionPaymentHistory] PRIMARY KEY NONCLUSTERED,
	[SubscriptionId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_SubscriptionPaymentHistory_Subscription] FOREIGN KEY 
			REFERENCES [Account].[Subscription] ([SubscriptionId]), 
	[InvoiceAmount] [Currency] NOT NULL,
	[CollectedAmount] [Currency] NOT NULL,
	[PaymentDate] [smalldatetime] NOT NULL,

	CONSTRAINT [AK_SubscriptionPaymentHistory_Unique] UNIQUE CLUSTERED 
	( 
		[SubscriptionId],
		[PaymentDate]
	)
) ON [PRIMARY]
GO



PRINT 'Add [UserPolicyAlerts] table' 
IF OBJECT_ID(N'[Account].[UserPolicyAlerts]') IS NOT NULL 
	DROP TABLE [Account].[UserPolicyAlerts] 
GO
CREATE TABLE [Account].[UserPolicyAlerts] ( 

	[UserPolicyAlertsId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_UserPolicyAlerts] PRIMARY KEY NONCLUSTERED,
	[UserId] [uniqueidentifier] NOT NULL,
	[ServicePolicyId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_UserPolicyAlerts_ServicePolicy] FOREIGN KEY 
			REFERENCES [Account].[ServicePolicy] ([ServicePolicyId]), 
	[EffectiveDate] [smalldatetime] NOT NULL,

	CONSTRAINT [AK_UserPolicyAlerts_Unique] UNIQUE CLUSTERED 
	( 
		[UserId],
		[ServicePolicyId],
		[EffectiveDate]
	)
) ON [PRIMARY]
GO



PRINT 'Add [PasswordHistory] table' 
IF OBJECT_ID(N'[Account].[PasswordHistory]') IS NOT NULL 
	DROP TABLE [Account].[PasswordHistory] 
GO
CREATE TABLE [Account].[PasswordHistory] ( 

	[PasswordHistoryId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_PasswordHistory] PRIMARY KEY NONCLUSTERED,
	[UserId] [uniqueidentifier] NOT NULL,
	[Username] [nvarchar](256) NOT NULL,
	[PasswordHash] [nvarchar](150) NOT NULL,
	[PasswordSalt] [nvarchar](150) NOT NULL,
	[ChangeDate] [smalldatetime] NOT NULL,

	CONSTRAINT [AK_PasswordHistory_Unique] UNIQUE CLUSTERED 
	( 
		[UserId],
		[ChangeDate]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Account].[PasswordHistory].[Username]'
EXEC sp_bindrule '[Rule_Req_String]', '[Account].[PasswordHistory].[PasswordHash]'
EXEC sp_bindrule '[Rule_Req_String]', '[Account].[PasswordHistory].[PasswordSalt]'
GO



PRINT 'Add [UserApplicationPreferences] table' 
IF OBJECT_ID(N'[Account].[UserApplicationPreferences]') IS NOT NULL 
	DROP TABLE [Account].[UserApplicationPreferences] 
GO
CREATE TABLE [Account].[UserApplicationPreferences] ( 

	[UserApplicationPreferencesId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_UserApplicationPreferences] PRIMARY KEY NONCLUSTERED,
	[UserId] [uniqueidentifier] NOT NULL,
	[ShowTips] [Boolean] NOT NULL,
	[ShowHeader] [Boolean] NOT NULL,
	[AutoSave] [Boolean] NOT NULL,

	CONSTRAINT [AK_UserApplicationPreferences_Unique] UNIQUE CLUSTERED 
	( 
		[UserId]
	)
) ON [PRIMARY]
GO



PRINT 'Add [UserMapping] table' 
IF OBJECT_ID(N'[Account].[UserMapping]') IS NOT NULL 
	DROP TABLE [Account].[UserMapping] 
GO
CREATE TABLE [Account].[UserMapping] ( 

	[UserMappingId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_UserMapping] PRIMARY KEY NONCLUSTERED,
	[UserId] [uniqueidentifier] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[ApplicationAccountType] [varchar](30) NOT NULL,
	[ApplicationMappingId] [int] NOT NULL,
	[CampaignId] [int] NULL,

	CONSTRAINT [AK_UserMapping_Unique] UNIQUE CLUSTERED 
	( 
		[ApplicationId],
		[ApplicationAccountType],
		[ApplicationMappingId]
	)
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Account].[UserMapping].[ApplicationAccountType]'
GO

--<<#SQL_TABLE_SCRIPT#>>











