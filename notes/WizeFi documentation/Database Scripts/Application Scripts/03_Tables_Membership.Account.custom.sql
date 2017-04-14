
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

