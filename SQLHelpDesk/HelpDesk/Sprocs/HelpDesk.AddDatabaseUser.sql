CREATE PROCEDURE [HelpDesk].[AddDatabaseUser]
	@DatabaseName sysname,
	@DatabaseUser sysname
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname, @OriLogin SYSNAME
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	
	--No injection check since this should be handled out sie of this sproc.
	EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @DatabaseUser, @message = 'Starting AddDBUser Proc.';
	BEGIN TRY
		DECLARE @SQL nvarchar(4000)
		DECLARE @QuotedDatabaseName sysname,@QuotedDatabaseUser sysname
		IF(CHARINDEX('[',@DatabaseName,0) = 0)
		BEGIN
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName)
		END
		ELSE
		BEGIN
			SET @QuotedDatabaseName = @DatabaseName
		END
		IF(CHARINDEX('[',@DatabaseUser,0) = 0)
		BEGIN
			SET @QuotedDatabaseUser = QUOTENAME(@DatabaseUser)
		END
		ELSE
		BEGIN
			SET @QuotedDatabaseUser = @DatabaseUser 
		END
		EXEC @RC = dbo.AddDatabaseUser @DatabaseName = @QuotedDatabaseName, @DatabaseUser = @QuotedDatabaseUser;
		IF(@RC <> 0)
		BEGIN
			EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @DatabaseUser, @message = 'Failed Helpdesk.AddDBUser Proc.';
			RETURN 1;
		END
		ELSE
		BEGIN
			EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @DatabaseUser, @message = 'Successfully Finished Helpdesk.AddDBUser Proc.';
			RETURN 0;
		END
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @DatabaseUser, @message= 'Problem with HelpDesk.AddDatabaseUser: failed TryCatch Block!'
		RETURN 1;
	END CATCH
	RETURN 0;
END
