
USE Membership
GO

IF SCHEMA_ID('Account') IS NULL
	EXEC('CREATE SCHEMA Account') 
GO


IF OBJECT_ID('[Account].[EnforceExpirationPolicy]') IS NOT NULL
	DROP PROCEDURE [Account].[EnforceExpirationPolicy]
GO
CREATE PROCEDURE [Account].[EnforceExpirationPolicy]  
AS 

--HACK TODO: Really dont want this setting even on the advisor record at all and
--should actually live in the membership database since that is where the policy is
UPDATE REP
SET
	IsPasswordExpired = 1
FROM 
	[MOPro_Core].Advisor.FinancialAdvisor REP
	LEFT JOIN [MOPro_Core].Advisor.Company C
		ON REP.CompanyId = C.CompanyId
	JOIN [Membership].dbo.aspnet_Users U
		ON REP.Username = U.UserName
	JOIN [Membership].dbo.aspnet_Membership M
		ON U.ApplicationId = M.ApplicationId
			AND U.UserId = M.UserId
			AND M.IsApproved = 1
WHERE 
	DATEADD(d, ISNULL(NULLIF(CONVERT(INT, C.PasswordExpiry), 0), 10000), M.LastPasswordChangedDate) < GETDATE()

GO
