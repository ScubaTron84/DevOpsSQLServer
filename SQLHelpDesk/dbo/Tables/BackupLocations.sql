CREATE TABLE [dbo].[BackupLocations]
(
	[BackupLocationId] INT IDENTITY(1,1),
	[Location] NVARCHAR(200) NOT NULL,
	[IsForFull] BIT NOT NULL,
	[IsForDiff] BIT NOT NULL,
	[IsForLog] BIT NOT NULL,
	[CreatedBy] sysname NOT NULL,
	[CreatedDatetimeUTC] DATETIME NOT NULL DEFAULT GETUTCDATE(),
	[ModifiedBy] sysname NULL,
	[ModifiedDateTimeUTC] DATETIME NULL
)
GO
ALTER TABLE dbo.BackupLocations ADD CONSTRAINT PK_dboBackupLocations_BackupLocationsId PRIMARY KEY CLUSTERED (BackupLocationId)
GO
