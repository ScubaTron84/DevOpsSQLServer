/*
***********************************
*SQL HelpDesk Demo
Proc: LogAction
Params: @procname, @helpdeskuser, @input1-7, @message

Logs the actions taken into the audit table.

Created By: Stephen Mokszycki
Demo Date: 2015-04-14
***********************************
*/
CREATE PROCEDURE [dbo].[LogAction]
	@procname sysname,
	@HelpDeskUser sysname,
	@input1 sysname  = NULL,
	@input2 sysname = NULL,
	@input3 sysname = NULL,
	@input4 sysname = null,
	@input5 sysname = null,
	@input6 sysname = null,
	@input7 sysname = null,
	@message varchar(1024) = NULL
AS
BEGIN
	--Ensuring everything is quotenamed, to capture the full input of the user
	--If they did inject, i want to see what they did!
	SET @input1 = QUOTENAME(@input1);
	SET @input2 = QUOTENAME(@input2);
	SET @input3 = QUOTENAME(@input3);
	SET @input4 = QUOTENAME(@input4);
	SET @input5 = QUOTENAME(@input5);
	SET @input6 = QUOTENAME(@input6);
	SET @input7 = QUOTENAME(@input7);
	
	INSERT INTO Audit.HelpDeskLog (ProcName,HelpDeskUser,Input1,Input2,Input3,MessageLog)
	VALUES (@procname,@HelpDeskUser,@input1,@input2,@input3,@message)
	PRINT @message;
	RETURN 0
END
