CREATE PROCEDURE [dbo].[CreateDatabase]
	@DatabaseName sysname
WITH EXECUTE AS OWNER	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname
	DECLARE @OriLogin SYSNAME 
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @message = 'Starting CreateDatabase Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname
		DECLARE @SQL nvarchar(4000)

		--check if our db needs to be quote named, we shouldnt have to 
		--this should have been done in the top level sproc in helpdesk schema,
		--but it never hurts to be SURE!
		IF(CHARINDEX('[',@DatabaseName,0)=0)
		BEGIN
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName)
		END
		ELSE
			SET @QuotedDatabaseName = @DatabaseName
		SET @SQL = 'USE MASTER; CREATE DATABASE '+ @QuotedDatabaseName +';'
		--Create the database
		EXEC (@SQL)
		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @Message = 'Successfully Finished CreateDatabase Proc.'; 
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @message= 'The New database Failed to create!'
		RETURN 1;
	END CATCH
	RETURN 0;
END
