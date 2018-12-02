CREATE PROCEDURE [dbo].[SqlInjectionCheck]
	@input1 sysname,
	@input2 sysname = NULL,
	@input3 sysname = NULL,
	@input4 sysname = NULL,
	@input5 sysname = NULL,
	@input6 sysname = NULL,
	@input7 sysname = NULL

AS
BEGIN
	IF ((SELECT dbo.InjectionCheck(@input1)) > 0 )
		RETURN 1;
	IF ((SELECT dbo.InjectionCheck(@input2)) > 0 )
		RETURN 2;
	IF ((SELECT dbo.InjectionCheck(@input3)) > 0 )
		RETURN 3;
	IF ((SELECT dbo.InjectionCheck(@input4)) > 0 )
		RETURN 4;
	IF ((SELECT dbo.InjectionCheck(@input5)) > 0 )
		RETURN 5;
	IF ((SELECT dbo.InjectionCheck(@input6)) > 0 )
		RETURN 6;
	IF ((SELECT dbo.InjectionCheck(@input7)) > 0 )
		RETURN 7;

END