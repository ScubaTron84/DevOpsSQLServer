/*
***********************************
*SQL HelpDesk Demo
Proc: SetDatabaseRecoveryMode
Params: @DatabaseName, @DbOwner_RoleMember

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2016-04-01
***********************************
*/

CREATE PROCEDURE [dbo].[AddDbOwnerRoleMember]
	@DatabaseName sysname,
	@DbOwner_RoleMember sysname
WITH EXECUTE AS OWNER	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname, @OriLogin sysname
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	
	--No injection check since this should be handled out sie of this sproc.
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @DbOwner_RoleMember, @message = 'Starting DBOwner_roleMember Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname,@QuotedDBOwner sysname
		DECLARE @SQL nvarchar(4000)
		IF(CHARINDEX('[',@DatabaseName,0) = 0)
		BEGIN
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName)
		END
		IF(CHARINDEX('[',@DbOwner_RoleMember,0) = 0)
		BEGIN
			SET @QuotedDBOwner = QUOTENAME(@DbOwner_RoleMember)
		END
		SET @SQL = 'USE '+@QuotedDatabaseName+'; ALTER ROLE [db_Owner] ADD MEMBER '+@QuotedDBOwner+';'
		--alter the database
		EXEC (@SQL)
		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @DbOwner_RoleMember, @Message = 'Successfully finsihed DBOwner_roleMember Proc.';
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @DbOwner_RoleMember, @message= 'Setting DBOwner_roleMember mode failed!'
		RETURN 1;
	END CATCH
	RETURN 0;
END