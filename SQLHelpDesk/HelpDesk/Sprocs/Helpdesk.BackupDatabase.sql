/*
***********************************
*SQL HelpDesk Demo
Proc: Take a database backup
Params: @DatabaseName

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2017-05-20
***********************************
*/
CREATE PROCEDURE [HelpDesk].[BackupDatabase]
	@DatabaseName sysname,
	@BackupLocation VARCHAR(256) = 'C:\Temp\',
	@BackupFileName VARCHAR(100) = NULL
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
	EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @BackupLocation, @BackupFileName, @message = 'Starting Helpdesk.BackupDatabase Sproc'

	EXEC @RC = [dbo].SqlInjectionCheck @QuoteDatabaseName, @BackupLocation, @BackupFileName;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@QuoteDatabaseName, @BackupLocation,@BackupFileName, @message = 'INJECT CHECK FAILED!';
		RETURN 1;
	END
	
	--Verify Access check
	EXECUTE AS LOGIN = ORIGINAL_LOGIN();
	EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@DatabaseName, @BackupLocation, @BackupFileName, @message = 'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END

	BEGIN TRY
		EXEC @RC = dbo.BackupDatabase @DatabaseName, @BackupLocation, @BackupFileName
		IF(@RC <> 0)
		BEGIN
			EXEC [dbo].LogAction @procname, @HelpDeskUser,@DatabaseName, @BackupLocation, @BackupFileName, @message = 'Failed to backup database in Helpdesk.BackupDatabase' 
			RETURN 1;
		END
		SET @Message = 'Database (' + @DatabaseName +') on Instance ('+ @@SERVERNAME+') Backed up to location ('+@BackupLocation+') to file ('+@BackupFileName+')' 
		EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @BackupLocation, @BackupFileName, @message = @Message
		RETURN 0
	END TRY
	BEGIN CATCH

		RETURN 1;
	END CATCH 
END
