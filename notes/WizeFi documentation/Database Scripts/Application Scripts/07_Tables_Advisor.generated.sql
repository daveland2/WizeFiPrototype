SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO



IF SCHEMA_ID('Advisor') IS NULL
	EXEC('CREATE SCHEMA [Advisor]') 
GO




PRINT 'Add [Company] table' 
IF OBJECT_ID(N'[Advisor].[Company]') IS NOT NULL 
	DROP TABLE [Advisor].[Company] 
GO
CREATE TABLE [Advisor].[Company] ( 

	[CompanyId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED,
	[Name] [varchar](50) NOT NULL,
	[FullName] [varchar](70) NOT NULL,
	[MainPhone] [varchar](10) NOT NULL,
	[AddressLine] [varchar](100) NOT NULL,
	[AddressLine2] [varchar](100) NOT NULL,
	[PhysicalCity] [varchar](35) NOT NULL,
	[PhysicalState] [varchar](2) NOT NULL,
	[PhysicalZip] [varchar](9) NOT NULL,
	[PasswordReuseRestriction] [tinyint] NOT NULL,
	[PasswordExpiry] [tinyint] NOT NULL,
	[IsInternal] [Boolean] NOT NULL,
	[BrokerageText] [varchar](1000) NOT NULL,
	[LogoReportOffset] [varchar](10) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Advisor].[Company].[Name]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[Company].[FullName]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[Company].[MainPhone]'
EXEC sp_bindrule '[Rule_Req_String]', '[Advisor].[Company].[AddressLine]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[Company].[AddressLine2]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[Company].[PhysicalCity]'
EXEC sp_bindrule '[Rule_Req_String]', '[Advisor].[Company].[PhysicalState]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[Company].[PhysicalZip]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[Company].[BrokerageText]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[Company].[LogoReportOffset]'
GO



PRINT 'Add [FinancialAdvisor] table' 
IF OBJECT_ID(N'[Advisor].[FinancialAdvisor]') IS NOT NULL 
	DROP TABLE [Advisor].[FinancialAdvisor] 
GO
CREATE TABLE [Advisor].[FinancialAdvisor] ( 

	[FinancialAdvisorId] [RecordID] IDENTITY(1,1) 
		CONSTRAINT [PK_FinancialAdvisor] PRIMARY KEY CLUSTERED,
	[LastName] [varchar](30) NOT NULL,
	[FirstName] [varchar](30) NOT NULL,
	[CompanyId] [ReferenceID] NOT NULL
		CONSTRAINT [FK_FinancialAdvisor_Company] FOREIGN KEY 
			REFERENCES [Advisor].[Company] ([CompanyId]), 
	[OfficePhone] [varchar](10) NOT NULL,
	[Title] [varchar](50) NOT NULL,
	[PhysicalAddressLine] [varchar](100) NOT NULL,
	[PhysicalAddressLine2] [varchar](100) NOT NULL,
	[PhysicalCity] [varchar](35) NOT NULL,
	[PhysicalState] [varchar](2) NOT NULL,
	[PhysicalZip] [varchar](10) NOT NULL,
	[Username] [varchar](30) NOT NULL,
	[IsCompanyAdmin] [Boolean] NOT NULL,
	[IsPasswordExpired] [Boolean] NOT NULL,
	[LicenseText] [varchar](1000) NOT NULL,
) ON [PRIMARY]
EXEC sp_bindrule '[Rule_Req_String]', '[Advisor].[FinancialAdvisor].[LastName]'
EXEC sp_bindrule '[Rule_Req_String]', '[Advisor].[FinancialAdvisor].[FirstName]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[FinancialAdvisor].[OfficePhone]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[FinancialAdvisor].[Title]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[FinancialAdvisor].[PhysicalAddressLine]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[FinancialAdvisor].[PhysicalAddressLine2]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[FinancialAdvisor].[PhysicalCity]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[FinancialAdvisor].[PhysicalState]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[FinancialAdvisor].[PhysicalZip]'
EXEC sp_bindrule '[Rule_Req_String]', '[Advisor].[FinancialAdvisor].[Username]'
EXEC sp_bindefault '[Default_String]', '[Advisor].[FinancialAdvisor].[LicenseText]'
GO

--<<#SQL_TABLE_SCRIPT#>>


