
IF OBJECT_ID(N'MEMBERSHIP_USER_MAPPING') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_USER_MAPPING
	FOR Membership.Account.UserMapping
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_Applications table
IF OBJECT_ID(N'MEMBERSHIP_APPLICATIONS') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_APPLICATIONS
	FOR Membership.dbo.aspnet_Applications
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_Membership table
IF OBJECT_ID(N'MEMBERSHIP_LOGINS') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_LOGINS
	FOR Membership.dbo.aspnet_Membership
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_Users table
IF OBJECT_ID(N'MEMBERSHIP_USERS') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_USERS
	FOR Membership.dbo.aspnet_Users
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_UsersInRoles table
IF OBJECT_ID(N'MEMBERSHIP_USER_ROLES') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_USER_ROLES
	FOR Membership.dbo.aspnet_UsersInRoles
END
GO
--NOTE: Dependent on the Membership database and dbo.aspnet_Profile table
IF OBJECT_ID(N'MEMBERSHIP_PROFILES') IS NULL BEGIN
	CREATE SYNONYM MEMBERSHIP_PROFILES
	FOR Membership.dbo.aspnet_Profile
END
GO



DECLARE csrMembership CURSOR FOR 
	SELECT FR.FinancialRepId, U.UserId, U.UserName
	FROM 
		MOPro_Finance.Code.FinancialRep FR
		JOIN MEMBERSHIP_USERS U
			ON FR.Username = U.UserName
		JOIN MEMBERSHIP_LOGINS M
			ON U.UserId = M.UserId
	WHERE 
		M.IsApproved = 1
		AND M.ApplicationId = 'afd50a10-a64c-49b6-8fb9-eda5fb164fb4'
	ORDER BY 
		FR.FinancialRepId

DECLARE 
	@AdvisorId INT,
	@UserId UNIQUEIDENTIFIER, 
	@UserName NVARCHAR(50),
	@NewAppUserID UNIQUEIDENTIFIER,
	@NewRootUserID UNIQUEIDENTIFIER,
	@NewAppID UNIQUEIDENTIFIER,
	@NewRootID UNIQUEIDENTIFIER

	
OPEN csrMembership

FETCH NEXT FROM csrMembership 
INTO @AdvisorId, @UserId, @UserName

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT 
		@NewAppUserID = NEWID(),
		@NewRootUserID = NEWID(),
		@NewAppID = '3305ea3c-f53f-49f4-9d54-fc367f16890a',
		@NewRootID = '4115b90c-b730-4b3e-ba47-10f3b0f57e17'
	
		
	INSERT INTO MEMBERSHIP_USERS (ApplicationId, UserId, UserName, LoweredUserName, MobileAlias, IsAnonymous, LastActivityDate)
	SELECT @NewRootID, @NewRootUserID, UserName, LoweredUserName, MobileAlias, IsAnonymous, LastActivityDate
	FROM MEMBERSHIP_USERS
	WHERE UserId = @UserId
	
	INSERT INTO MEMBERSHIP_USERS (ApplicationId, UserId, UserName, LoweredUserName, MobileAlias, IsAnonymous, LastActivityDate)
	SELECT @NewAppID, @NewAppUserID, UserName, LoweredUserName, MobileAlias, IsAnonymous, LastActivityDate
	FROM MEMBERSHIP_USERS
	WHERE UserId = @UserId
			
	INSERT INTO MEMBERSHIP_LOGINS (ApplicationId, UserId, [Password], PasswordFormat, PasswordSalt, MobilePIN, Email, LoweredEmail, PasswordQuestion, PasswordAnswer, IsApproved, IsLockedOut, CreateDate, LastLoginDate, LastPasswordChangedDate, LastLockoutDate, FailedPasswordAttemptCount, FailedPasswordAttemptWindowStart, FailedPasswordAnswerAttemptCount, FailedPasswordAnswerAttemptWindowStart, Comment)
	SELECT @NewRootID, @NewRootUserID, [Password], PasswordFormat, PasswordSalt, MobilePIN, Email, LoweredEmail, PasswordQuestion, PasswordAnswer, IsApproved, IsLockedOut, CreateDate, LastLoginDate, LastPasswordChangedDate, LastLockoutDate, FailedPasswordAttemptCount, FailedPasswordAttemptWindowStart, FailedPasswordAnswerAttemptCount, FailedPasswordAnswerAttemptWindowStart, Comment
	FROM MEMBERSHIP_LOGINS
	WHERE UserId = @UserId
			
	INSERT INTO MEMBERSHIP_USER_ROLES (UserId, RoleId)
	VALUES (@NewAppUserID, '64fbd13d-3f20-4a0e-82c2-74556cf916eb')
	INSERT INTO MEMBERSHIP_USER_ROLES (UserId, RoleId)
	VALUES (@NewAppUserID, '35050f38-b1f0-4861-abc8-5cb94a639e14')

	INSERT INTO MEMBERSHIP_USER_MAPPING (UserId, ParentId, ApplicationId, ApplicationAccountType, ApplicationMappingId, CampaignId)
	VALUES (@NewRootUserID, NULL, @NewAppID, 'Professional', @AdvisorId, NULL)

    FETCH NEXT FROM csrMembership 
    INTO @AdvisorId, @UserId, @UserName
END 

CLOSE csrMembership
DEALLOCATE csrMembership


GO



INSERT INTO Advisor.Company (CompanyId, Name, FullName, MainPhone, AddressLine, AddressLine2, PhysicalCity, PhysicalState, PhysicalZip, BrokerageText, PasswordReuseRestriction, PasswordExpiry, IsInternal)
SELECT S.CompanyId, S.Name, S.FullName, '', ISNULL(S.StreetAddress, ''), ISNULL(S.StreetAddress2, ''), ISNULL(S.City, ''), ISNULL(S.State, ''), ISNULL(S.ZipCode, ''), ISNULL(S.BrokerageText, ''), S.PasswordReuseRestriction, S.PasswordExpiry, S.IsInternal
FROM 
	MOPro_Finance.Code.Company S
	LEFT JOIN Advisor.Company T
		ON S.Name = T.Name
WHERE T.Name IS NULL

GO


