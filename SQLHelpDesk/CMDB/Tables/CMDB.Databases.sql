CREATE TABLE [CMDB].[Databases]
(
	[DatabaseId] BIGINT IDENTITY(1,1),
	[name] sysname NOT NULL,
	[RecoveryMode] sysname NOT NULL,
	[DBOwnerRoleMember] sysname NOT NULL,
	[CreatedBy] sysname NOT NULL,
	[CreatedDateTimeUTC] DATETIME NOT NULL DEFAULT GETUTCDATE(),
	[ModifiedBy] sysname NULL,
	[ModifiedDateTimeUTC] DATETIME NULL
)
GO
ALTER TABLE [CMDB].[Databases] ADD CONSTRAINT PK_dboDatabases_DatabaseId PRIMARY KEY CLUSTERED (DatabaseId)
GO