/*
***********************************
*SQL HelpDesk Demo
Proc: Create A Database
Params: @DatabaseName

NOT Using Execute as owner directly
calls sub-sproc using EXECUTE AS OWNER
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2016-04-02
***********************************
*/
CREATE PROCEDURE [HelpDesk].[CreateDatabase]
	@DatabaseName sysname,
	@RecoveryMode sysname = 'SIMPLE',
	@DBOwner_RoleMember sysname = NULL,
	@DBOwner_isSQLLogin BIT = 0,
	@DBOwner_sqlLoginPassword VARCHAR(85) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname 
	DECLARE @HelpDeskUser sysname
	
	SELECT @procname = object_name(@@Procid), @HelpDeskUser = ORIGINAL_Login();
	--SQL Injection check
	--QuoteName your input! make sure no one is doing something sneaky or you just executed it!
	DECLARE @QuoteDatabaseName sysname
	DECLARE @QuoteRecoveryMode sysname 
	DECLARE @QuoteDBOwner sysname
	DECLARE @QuotedPassword VARCHAR(85)

	IF(@DBOwner_RoleMember is NULL)
	BEGIN
		EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @recoveryMode, @DBOwner_rolemember, @DBOwner_isSQLLogin, 'MASKED PASSWORD', @message = 'Please supply a DBOwner_Rolemember login for Helpdesk.CreateDatabase..'
		RETURN 1;
	END
	IF(@DBOwner_isSQLLogin = 1 AND @DBOwner_sqlLoginPassword IS NULL)
	BEGIN
		EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @recoveryMode, @DBOwner_rolemember, @DBOwner_isSQLLogin, @DBOwner_sqlLoginPassword, @message = 'Please supply a Password for the sql login for Helpdesk.CreateDatabase.'
		RETURN 1;
	END

	SET @QuoteDatabaseName = QUOTENAME(@DatabaseName);
	SET @QuoteRecoveryMode = QUOTENAME(@RecoveryMode);
	SET @QuoteDBOwner = QUOTENAME(@DBOwner_RoleMember);
	SET @QuotedPassword = QUOTENAME(@DBOwner_sqlLoginPassword);

	--Start the log
	EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @recoveryMode, @DBOwner_rolemember, @DBOwner_isSQLLogin, 'MASKED PASSWORD', @message = 'Starting Helpdesk.CreateDatabase Sproc'

	EXEC @RC = [dbo].SqlInjectionCheck @QuoteDatabaseName, @QuoteRecoveryMode, @QuoteDBOwner, @QuotedPassword;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@QuoteDatabaseName, @QuoteRecoveryMode, @DBOwner_isSQLLogin,'MASKED PASSWORD',@message = 'INJECT CHECK FAILED!';
		RETURN 1;
	END
	
	--Verify Access check
	EXECUTE AS LOGIN = ORIGINAL_LOGIN();
	EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@Databasename, @RecoveryMode,@DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD',@message = 'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END

	--Build our create database statement,  For ease of the demo,  I am not doing much here.  Just a simple create
	--You can make this more dynamic, controlling file locations.
	DECLARE @SQL nvarchar(4000)
	DECLARE @Message Nvarchar(1000)
	
	BEGIN TRY
		--Validate there is enough space on disk!
		--Validate the dbowner!
		EXEC @RC = [HelpDesk].CreateLogin @LoginName = @DBOwner_RoleMember, @isSQLLogin = @DBOwner_isSQLLogin, @Password = @DBOwner_sqlLoginPassword
		IF (@RC <> 0)
		BEGIN
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem Creating login for DBOwner: failed.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Login (' + @DBOwner_RoleMember +') Ready for use on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message = @Message
		END
		--Create the database
		-----SHOULD ADD A CHECK HERE TO SEE IF THE DBNAME ALREADY EXISTS!!!
		EXEC @RC = dbo.CreateDatabase @DatabaseName
		IF (@RC <> 0)
		BEGIN
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem Creating Database from Helpdesk.CreateDatabase Sproc.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Database (' + @DatabaseName +') Created on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message = @Message
		END
		--Create the database user for the dbowner.
		EXEC @RC = dbo.AddDatabaseUser @DatabaseName,@DBOwner_RoleMember
		IF(@RC <> 0)
		BEGIN 
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem Creating Database user in Helpdesk.CreateDatabase Sproc.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Database User (' + @DBOwner_RoleMember +') created in Database ('+@DatabaseName+') on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember, @DBOwner_isSQLLogin,'MASKED PASSWORD',@message = @Message
		END
		--Change the recovery mode.
		EXEC @RC = dbo.SetDatabaseRecoveryMode @DatabaseName, @RecoveryMode;
		IF (@RC <> 0)
		BEGIN
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem setting recovery mode in Helpdesk.CreateDatabase Sproc.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Set DB recovery mode to (' + @RecoveryMode+') Database ('+@DatabaseName+') on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message = @Message
		END
		--SET the DBOwner
		EXEC @RC = dbo.AddDbOwnerRoleMember @DatabaseName, @DbOwner_RoleMember
		IF (@RC <> 0)
		BEGIN
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem Adding DBOwner_RoleMemeber mode: failed.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Added DB_owner User (' + @DBOwner_RoleMember +') for Database ('+@DatabaseName+') on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember, @DBOwner_isSQLLogin,'MASKED PASSWORD',@message = @Message
		END
		/*
		Log the settings it should have for future lookup!
		Again we are doing the bare minimun,  you could select from sys.databases, and dump that information
		along with any additional paramemeters from the SPROC.
		*/
		INSERT CMDB.Databases (Name, RecoveryMode, DBOwnerRoleMember, CreatedBy)
		VALUES (@DatabaseName,@RecoveryMode,@DBOwner_RoleMember,@HelpDeskUser)
		
		EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message = 'Successfully Completed Helpdesk.CreateDatabase Sproc!'
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname, @Helpdeskuser, @QuoteDatabaseName, @RecoveryMode,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message= 'Database creation failed!'
		RETURN 1;
	END CATCH
	RETURN 0;
END