CREATE TABLE [Audit].[HelpDeskLog]
(
	[Id] int NOT NULL PRIMARY KEY IDENTITY(1,1),
	[HelpDeskUser] sysname NOT NULL,
	[RunDateTime] datetime2 NOT NULL DEFAULT GETDATE(),
	[ProcName] sysname NOT NULL,
	[Input1] sysname NULL,
	[Input2] sysname NULL,
	[Input3] sysname NULL,
	[input4] sysname null,
	[input5] sysname null,
	[input6] sysname null,
	[input7] sysname null, 
    [MessageLog] VARCHAR(1024) NULL
)
