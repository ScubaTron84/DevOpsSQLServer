/*
***********************************
*SQL HelpDesk Demo
Proc: CreateLogin
Params: @LoginName, @IsSQLLogin

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2016-04-01
***********************************
*/
CREATE PROCEDURE [HelpDesk].[CreateLogin]
	@LoginName sysname,
	@IsSQLLogin BIT = 0,
	@Password VARCHAR(85) = NULL
	--1.) running as owner, since the database is owned by SA, and TRUSTWORTHY, i can execute code as SA.
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname 
	DECLARE @HelpDeskUser sysname
	/*2.)
	Store the current running proceedure name and the original caller.  
	Since we are running as SA, we need to store the original calling user.
	*/
	SELECT @procname = object_name(@@Procid), @HelpDeskUser = ORIGINAL_Login();

	/*3.)
	SQL Injection check
	QuoteName your input! make sure no one is doing something sneaky or you just executed it!
	*/
	DECLARE @QuotedLoginName sysname 
	IF(CHARINDEX('[',@loginName,0) = 0 AND CHARINDEX(']',@loginname,0) = 0)
		SET @QuotedLoginName = QUOTENAME(@LoginName)
	ELSE
		SET @QuotedLoginName = @LoginName

	EXEC @RC = [dbo].SqlInjectionCheck @QuotedLoginName;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@LoginName, @IsSQLLogin,NULL,'INJECT CHECK FAILED!';
		RETURN 1;
	END

	EXEC [dbo].LogAction @procname, @HelpDeskUser, @LoginName, @IsSQLLogin, NULL, @message = 'Starting Proc CreateLogin';
	/* 4.)
	Check if the user has the right access, dont just rely on schema perms make sure!	
	NOTICE we execute this sub section as the user
	And revert immediately!!! we need SA to continue our sproc!
	*/
	EXECUTE AS LOGIN = ORIGINAL_LOGIN();
		EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@LoginName, @IsSQLLogin,NULL,'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END

	--Ok we passed the injection check, and the access Check, 
	--cool lets verify we need create a login
	BEGIN TRY
		DECLARE @SQLCmd nvarchar (4000)
		DECLARE @Sid  varbinary (85)
		
		IF EXISTS (SELECT 1 FROM master.sys.server_principals WHERE QUOTENAME(name) = @QuotedLoginName)
		BEGIN
			EXEC dbo.LogAction @procName, @HelpDeskUser, @LoginName, @IsSQLLogin, @Sid, @Message = 'Login already Exists! skipping!'
			RETURN 0;
		END

		IF (@IsSQLLogin = 1)
		BEGIN
			SET @SQLCmd = 'CREATE LOGIN '+@QuotedLoginName+' WITH PASSWORD = '''+ CAST(@Password as varchar(max)) + ''' ,CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;'
		END
		ELSE
		BEGIN
			SET @SQLCmd = 'CREATE LOGIN '+@QuotedLoginName+' FROM WINDOWS'
		END
		EXEC (@SQLCmd)
		--get the sid
		SELECT @sid = sid FROM master.sys.server_principals WHERE QUOTENAME(name) = @QuotedLoginName
		INSERT CMDB.Logins (name,SID,IsSQLLogin,CreatedBy)
		VALUES (@LoginName, @Sid, @IsSQLLogin, @HelpDeskUser)

		EXEC dbo.LogAction @procName, @HelpDeskUser, @LoginName, @IsSQLLogin, @Sid, @Message = 'Successfully Updated CMDB.Logins with new Login'
		EXEC dbo.LogAction @procName, @HelpDeskUser, @LoginName, @IsSQLLogin, @Sid, @Message = 'Successfully Created Login'
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname, @HelpdeskUser, @LoginName, @IsSQLLogin, NULL, @Message = 'Something went wrong creating a login, Validate login was created, and inserted into the logins table.'
	END CATCH
END

