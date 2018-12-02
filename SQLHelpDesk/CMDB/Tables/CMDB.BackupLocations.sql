CREATE TABLE [CMDB].[BackupLocations]
(
	BackupLocationId INT IDENTITY(1,1)
	CONSTRAINT [PK_BackupLocations_BackupLocationId] PRIMARY KEY CLUSTERED,
	FilePath nvarchar(256) NOT NULL,
	IsTLogBackups BIT NOT NULL
	CONSTRAINT [DF_BackupLocations_IsTLogBackups] DEFAULT(0),
	IsDifferentialBackups BIT NOT NULL
	CONSTRAINT [DF_BackupLocations_IsDifferentialBackups] DEFAULT(0),
	IsFullBackups BIT NOT NULL
	CONSTRAINT [DF_BackupLocations_IsFullBackups] DEFAULT(0),
	CreatedDate Datetime2 NOT NULL
	CONSTRAINT [DF_BackupLocations_CreatedDate] DEFAULT(GETDATE()),
	ModifiedDate DateTime2 NOT NULL
	CONSTRAINT [DF_BackupLocations_ModifieddDate] DEFAULT(GETDATE()),
	CreatedBy sysname,
	ModifiedBy sysname
)
