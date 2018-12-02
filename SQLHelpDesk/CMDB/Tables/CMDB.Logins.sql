CREATE TABLE [CMDB].[Logins]
(
	[LoginId] BIGINT IDENTITY(1,1),
	[name] sysname NOT NULL,
	[SID] varbinary(85) NOT NULL,
	[IsSQLLogin] BIT NOT NULL,
	[CreatedBy] sysname not null,
	[CreatedDateTimeUTC] DATETIME NOT NULL DEFAULT GETUTCDATE(),
	[ModifiedBy] sysname NULL,
	[ModifiedDateTimeUTC] DateTime NULL
)
GO
ALTER TABLE CMDB.Logins ADD CONSTRAINT PK_dboLogins_LoginId PRIMARY KEY CLUSTERED (LoginId)
GO