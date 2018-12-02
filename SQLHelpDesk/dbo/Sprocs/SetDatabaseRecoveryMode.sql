/*
***********************************
*SQL HelpDesk Demo
Proc: SetDatabaseRecoveryMode
Params: @DatabaseName, @RecoveryMode

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2016-04-01
***********************************
*/

CREATE PROCEDURE [dbo].[SetDatabaseRecoveryMode]
	@DatabaseName sysname,
	@RecoveryMode sysname
WITH EXECUTE AS OWNER	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname, @OriLogin sysname

	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	--No injection check since this should be handled out sie of this sproc.
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @RecoveryMode, @message = 'Starting Set RecoveryMode  Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname
		DECLARE @SQL nvarchar(4000)
		IF(CHARINDEX('[',@DatabaseName,0) = 0)
		BEGIN
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName)
		END
		ELSE 
			SET @QuotedDatabaseName = @DatabaseName
		SET @SQL = 'ALTER DATABASE '+@QuotedDatabaseName+' SET RECOVERY '+@RecoveryMode+';'
		--alter the database
		EXEC (@SQL)
		--Update the CMDB with the new recovery mode for our records.
		--only update if the entry exists and the database recovery mode isnt the same.  This is incase we have
		--not entered the database in yet via the createdb SPROC. 
		IF EXISTS(SELECT name FROM CMDB.databases where name = @DatabaseName and RecoveryMode <> @RecoveryMode)
		BEGIN
			UPDATE CMDB.Databases
			SET RecoveryMode = @RecoveryMode
			WHERE [name] = @DatabaseName
		END

		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @RecoveryMode, @message = 'Successfully Logged RecoveryMode change to CMDB Proc.';
		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @RecoveryMode, @message = 'Successfully finished Set RecoveryMode  Proc.'
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @RecoveryMode, @message= 'Setting database recovery mode failed!'
		RETURN 1;
	END CATCH
END