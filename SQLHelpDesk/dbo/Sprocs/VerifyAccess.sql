CREATE PROCEDURE [dbo].[VerifyAccess]
AS
BEGIN
--NOTICE:  This is not executed as OWNER.  we want the original login to fire this.
	DECLARE @ReturnCode INT
	DECLARE @OrgLogin Nvarchar(max) = (SELECT ORIGINAL_LOGIN())
	--IS_Member can take a windows group, or a DB role
	--if it returns 1,  user is a member
	--if it returns 0,  user is not a member
	--if it is null,  the group/role is probably typo'd......
	SELECT @ReturnCode = IS_ROLEMEMBER('HelpDeskUsers')
	IF (@ReturnCode <> 1 AND IS_SRVROLEMEMBER('sysadmin',@orgLogin) <> 1)
	BEGIN
		--Printing an error message for the demo.  Optionally Log this/email it/raise an eventlog!  
		EXEC dbo.LogAction @procname ='VerifyAccess', @helpDeskUser = @OrgLogin, @message =  'You are not a member of the appropriate group or role. Please contact the DBA'
		--I use the return code of 1 to mark a failure.  
		RETURN 1;
	END
	ELSE
	BEGIN
		RETURN 0;
	END
END
