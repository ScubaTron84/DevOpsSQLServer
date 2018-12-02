/*
***********************************
*SQL HelpDesk Demo
Proc: Restore a database backup
Params: @DatabaseName

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2017-05-20
***********************************
*/
CREATE PROCEDURE [HelpDesk].[RestoreDatabase]
	@DatabaseName sysname,
	@BackupLocation VARCHAR(256) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @Message VARCHAR(1000)
	DECLARE @procname sysname 
	DECLARE @HelpDeskUser sysname
	
	SELECT @procname = object_name(@@Procid), @HelpDeskUser = ORIGINAL_Login();
	--SQL Injection check
	--QuoteName your input! make sure no one is doing something sneaky or you just executed it!
	DECLARE @QuoteDatabaseName sysname
	SET @QuoteDatabaseName = QUOTENAME(@DatabaseName);

	--Start the log
	EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @BackupLocation, @message = 'Starting Helpdesk.RestoreDatabase Sproc'

	EXEC @RC = [dbo].SqlInjectionCheck @QuoteDatabaseName, @BackupLocation;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@QuoteDatabaseName, @BackupLocation, @message = 'INJECT CHECK FAILED!';
		RETURN 1;
	END
	
	--Verify Access check
	EXECUTE AS LOGIN = ORIGINAL_LOGIN();
	EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@DatabaseName, @BackupLocation, @message = 'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END

	BEGIN TRY
		EXEC @RC = dbo.RestoreDatabase @DatabaseName, @BackupLocation OUTPUT
		IF(@RC <> 0)
		BEGIN
			EXEC [dbo].LogAction @procname, @HelpDeskUser,@DatabaseName, @BackupLocation, @message = 'Failed to Restore database in Helpdesk.RestoreDatabase' 
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Database ('+ @DatabaseName+') Restored on from location ('+@BackupLocation+')' 
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @BackupLocation, @message = @Message
		RETURN 0
		END

	END TRY
	BEGIN CATCH

		RETURN 1;
	END CATCH 
END
