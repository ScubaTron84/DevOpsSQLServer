CREATE PROCEDURE [dbo].[RestoreDatabase]
	@DatabaseName Sysname,
	@BackupLocation VARCHAR(256) = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	--TODO add flexibility for other database backup types
	SET NOCOUNT ON;
	
	DECLARE @RC INT = 0;
	DECLARE @procname sysname
	DECLARE @OriLogin SYSNAME 
	DECLARE @Message NVARCHAR(1000)
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName,@BackupLocation, @message = 'Starting inner RestoreDatabase Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname
		DECLARE @SQL nvarchar(4000)
		--Make sure our DB name is quoted!
		IF(CHARINDEX('[',@DatabaseName,0) = 0)
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName);
		ELSE
			SET @QuotedDatabaseName = @DatabaseName;
	--Check backupLocation has a '\' at the end
	IF(CHARINDEX('\',REVERSE(@BackupLocation),0) <> 1)
		SET @BackupLocation = @BackupLocation +'\';
	--If we dont have a backup file find the last one
	--***** WHAT PROBLEM DO WE HAVE RIGHT NOW, HINT WE ACCEPT A FILE!
	IF(@BackupLocation IS NULL)
		BEGIN
			SET @BackupLocation = (SELECT TOP 1 physical_device_name 
				FROM msdb.dbo.backupset bs 
				INNER JOIN msdb.dbo.backupmediafamily bmf on bs.media_set_id = bmf.media_set_id
				WHERE QUOTENAME(bs.database_name) = @QuotedDatabaseName
				ORDER BY Bs.backup_start_date desc
				)
		END
		--WE SHOULD BE CAREFUL OF DESTRUCTIVE THINGS!!!!
		SET @SQL = 'USE [master]; ALTER DATABASE ' +@QuotedDatabaseName+' SET OFFLINE WITH ROLLBACK IMMEDIATE;
		RESTORE DATABASE ' + @QuotedDatabaseName + '
		FROM DISK = '''+@BackupLocation+'''
		WITH RECOVERY,REPLACE, STATS = 1'
		EXEC (@SQL)
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName,@BackupLocation, @message= 'Successfully RESTORED the database!';
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName,@BackupLocation, @message= 'The database Failed to RESTORE!';
		RETURN 1;
	END CATCH

END