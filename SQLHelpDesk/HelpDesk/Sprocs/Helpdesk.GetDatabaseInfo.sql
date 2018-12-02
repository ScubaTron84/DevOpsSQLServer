/*
***********************************
*SQL HelpDesk Demo
Proc: GetDatabaseInfo
Params: @DatabaseName

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2015-04-14
***********************************
*/

--NOTICE Most of this should be wrapped in try catch blocks! shame on the guy that wrote this!

CREATE PROCEDURE [HelpDesk].[GetDatabaseInfo]
	@DatabaseName sysname  --NOTICE SYSNAME is our data type

--Here is where we add execute as owner
WITH EXECUTE AS OWNER	
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @HelpDeskUser sysname;
	DECLARE @procname sysname

	SELECT @procname = object_name(@@Procid), @HelpDeskUser = ORIGINAL_Login();
	
	--SQL Injection check
	--QuoteName your input! make sure no one is doing something sneaky or you just executed it!
	DECLARE @QuotedDatabaseName sysname 
	SET @QuotedDatabaseName = QUOTENAME(@DatabaseName);
	EXEC @RC = [dbo].SqlInjectionCheck @QuotedDatabaseName;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@Databasename, NULL,NULL,'INJECT CHECK FAILED!';
		RETURN 1;
	END

	EXEC [dbo].LogAction @procname, @HelpDeskUser, @DatabaseName, NULL, NULL, 'Starting Proc.';
	--Check if the user has the right access, dont just rely on schema perms make sure!	
	--NOTICE we execute this sub section as the user
	--And revert immediately!!! we need SA to continue our sproc!
	EXECUTE AS USER = ORIGINAL_LOGIN();
		EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@Databasename, NULL,NULL,'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END
	
	--We can now safely run the the actual sproc we want!
	SELECT SUSER_NAME() AS ExecutedAS, ORIGINAL_LOGIN() AS OriginalUserLogin, * 
	FROM sys.databases 
	WHERE name = @DatabaseName; 

	--Log the results
	EXEC [dbo].LogAction @procname,@HelpDeskUser,@DatabaseName,Null,Null,'Sproc completed Successfully';
	RETURN 0
END