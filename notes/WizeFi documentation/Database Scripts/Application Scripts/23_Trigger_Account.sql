USE [Membership]
GO

/* Abondoned because need to use the same hash to be able to compare and the one MSFT uses is sealed (I think) */


IF OBJECT_ID(N'[dbo].[PasswordHistory_Capture]') IS NOT NULL
	DROP TRIGGER [dbo].[PasswordHistory_Capture]
GO

CREATE TRIGGER [dbo].[PasswordHistory_Capture]
	ON [dbo].[aspnet_Membership]
		FOR INSERT, UPDATE
AS
SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET XACT_ABORT OFF


IF NOT EXISTS (SELECT 0 FROM inserted i LEFT JOIN deleted d ON i.ApplicationId = d.ApplicationId AND i.UserId = d.UserId 
		WHERE d.UserId IS NULL OR i.[Password] <> d.[Password]) 
	
	RETURN

BEGIN TRY 

	PRINT 'Capture password change/insert'
	INSERT INTO [Account].[PasswordHistory] (Username, UserId, PasswordHash, PasswordSalt, ChangeDate)
	SELECT 
		Username = U.UserName,
		UserId = i.UserId, 
		PasswordHash = i.[Password],
		PasswordSalt = i.PasswordSalt, 
		ChangeDate = GETDATE()
	FROM 
		inserted i 
		JOIN dbo.aspnet_Users U
			ON i.ApplicationId = U.ApplicationId
				AND i.UserId = U.UserId


END TRY
BEGIN CATCH
	PRINT 'ERROR: Uh-oh, borked'

END CATCH
GO


