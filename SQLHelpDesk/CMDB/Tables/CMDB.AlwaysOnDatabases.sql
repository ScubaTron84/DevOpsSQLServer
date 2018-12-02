CREATE TABLE [CMDB].[AlwaysOnDatabases]
(
	[AlwaysOnDatabaseId] BIGINT IDENTITY (1,1)
	CONSTRAINT [PK_AlawysOnDatabases_AlwaysOnDatabaseId] PRIMARY KEY CLUSTERED,
	DatabaseId BIGINT NOT NULL
	CONSTRAINT [FK_AlwaysOnDatabases_Databases_DatabaseId] FOREIGN KEY REFERENCES CMDB.Databases(DatabaseId)

)
