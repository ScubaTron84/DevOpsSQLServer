CREATE PROCEDURE [dbo].[AddDatabaseUser]
	@DatabaseName sysname,
	@DatabaseUser sysname
WITH EXECUTE AS OWNER	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	BEGIN TRY
		DECLARE @SQL nvarchar(4000)
		DECLARE @QuotedDatabaseName sysname,@QuotedDatabaseUser sysname
		IF(CHARINDEX('[',@DatabaseName,0) = 0)
		BEGIN
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName)
		END
		ELSE
			SET @QuotedDatabaseName = @DatabaseName
		IF(CHARINDEX('[',@DatabaseUser,0) = 0)
		BEGIN
			SET @QuotedDatabaseUser = QUOTENAME(@DatabaseUser)
		END
		ELSE
			SET @QuotedDatabaseUser = @DatabaseUser
		SET @SQL = 'USE '+@QuotedDatabaseName+'; 
		CREATE USER '+@QuotedDatabaseUser+' FROM LOGIN '+@QuotedDatabaseUser+';'
		--alter the database
		EXEC (@SQL)
		--To do add an if to confirm for rare failure of try catch
		RETURN 0;
	END TRY
	BEGIN CATCH
		RETURN 1;
	END CATCH
END
