CREATE PROCEDURE [dbo].[BackupDatabase]
	@DatabaseName Sysname,
	@BackupLocation VARCHAR(256) = 'C:\Temp\',
	@BackupFileName VARCHAR(100) = NULL
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
	
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName,@BackupLocation,@BackupFileName, @message = 'Starting Backup of the database Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname
		DECLARE @SQL nvarchar(4000)
		--Make sure our DB name is quoted!
		IF(CHARINDEX('[',@DAtabaseName,0) = 0)
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName);
		ELSE
			SET @QuotedDatabaseName = @DatabaseName;
	--Check backupLocation has a '\' at the end
	IF(CHARINDEX('\',REVERSE(@BackupLocation),0) <> 1)
		SET @BackupLocation = @BackupLocation +'\';
	IF(@BackupFileName IS NULL)
		SET @BackupFileName = @DatabaseName +'_FULL_'+CAST(GETDATE() AS VARCHAR(25))+'.bak'
	
	--Make sure our DB exists
	IF NOT EXISTS (SELECT 1 FROM master.sys.databases WHERE QUOTENAME(NAME) = @QuotedDatabaseName)
	BEGIN
		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName,@BackupLocation,@BackupFileName, @message = 'Cannot Backup a database that does not exist!';
		RETURN 1;
	END
	ELSE
	BEGIN
		SET @SQL = 'BACKUP DATABASE ' + @QuotedDatabaseName + '
		TO DISK = '''+@BackupLocation+@BackupFileName+'''
		WITH INIT, STATS = 1'
		EXEC (@SQL)
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName,@BackupLocation,@BackupFileName, @message= 'Successfully backed up the database!';
		RETURN 0;
	END
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName,@BackupLocation,@BackupFileName, @message= 'The database Failed to Backup!';
		RETURN 1;
	END CATCH

END