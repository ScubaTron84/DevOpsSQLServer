CREATE FUNCTION [dbo].[InjectionCheck]
(
	@StringToVerify sysname
)
RETURNS INT
AS
BEGIN
	--Start Return code in FAIL mode, saves us reseting the variable multiple times.
	DECLARE @RC INT = 1
	IF(CHARINDEX(';',ISNULL(@StringToVerify,0)) > 0)
	BEGIN
		RETURN @RC;
	END
	IF(PATINDEX('%add%rolemember%',ISNULL(@StringToVerify,0))>0)
	BEGIN 
		RETURN @RC;
	END
	IF(PATINDEX('%GRANT%',ISNULL(@StringToVerify,0))>0)
	BEGIN 
		RETURN @RC;
	END
	IF(PATINDEX('%DENY%',ISNULL(@StringToVerify,0))>0)
	BEGIN
		RETURN @RC;
	END
	IF(PATINDEX('%ROLE%',ISNULL(@StringToVerify,0))>0)
	BEGIN
		RETURN @RC;
	END
	IF(PATINDEX('%REVOKE%',ISNULL(@StringToVerify,0))>0)
	BEGIN
		RETURN @RC;
	END
	IF(PATINDEX('%AUTHORIZATION%',ISNULL(@StringToVerify,0))>0)
	BEGIN
		RETURN @RC;
	END
	IF(PATINDEX('%ADD%',ISNULL(@StringToVerify,0))>0)
	BEGIN 
		RETURN @RC
	END
	--Nothing harmful was found,  resest Return code to 0 (all clear) and return it
	SET @RC = 0
	RETURN @RC
END
