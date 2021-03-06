--1.) create the database (alter as needed to move drives and change growth)
USE [master]
CREATE DATABASE [SQLSelfService]
ALTER DATABASE [SQLSelfService] SET RECOVERY SIMPLE
GO
USE master
--2.) Create our HelpDesk_JohnDoe login, our low access user
IF NOT EXISTS (SELECT NULL FROM sys.server_principals WHERE [name] = 'HelpDesk_JohnDoe')
	CREATE LOGIN [HelpDesk_JohnDoe] WITH PASSWORD = 'Test123' 
--3.) Create our database objects
USE [SQLSelfService]
/****** Object:  DatabaseRole [HelpDeskUsers]    Script Date: 2017-07-29 10:57:40 PM ******/
CREATE ROLE [HelpDeskUsers]
GO
/****** Object:  Schema [Audit]    Script Date: 2017-07-29 10:57:40 PM ******/
CREATE SCHEMA [Audit]
GO
/****** Object:  Schema [CMDB]    Script Date: 2017-07-29 10:57:40 PM ******/
CREATE SCHEMA [CMDB]
GO
/****** Object:  Schema [HelpDesk]    Script Date: 2017-07-29 10:57:40 PM ******/
CREATE SCHEMA [HelpDesk]
GO
/****** Object:  UserDefinedFunction [dbo].[InjectionCheck]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Object:  Table [Audit].[HelpDeskLog]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[HelpDeskLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HelpDeskUser] [sysname] NOT NULL,
	[RunDateTime] [datetime2](7) NOT NULL,
	[ProcName] [sysname] NOT NULL,
	[Input1] [sysname] NULL,
	[Input2] [sysname] NULL,
	[Input3] [sysname] NULL,
	[input4] [sysname] NULL,
	[input5] [sysname] NULL,
	[input6] [sysname] NULL,
	[input7] [sysname] NULL,
	[MessageLog] [varchar](1024) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CMDB].[AlwaysOnDatabases]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CMDB].[AlwaysOnDatabases](
	[AlwaysOnDatabaseId] [bigint] IDENTITY(1,1) NOT NULL,
	[DatabaseId] [bigint] NOT NULL,
 CONSTRAINT [PK_AlawysOnDatabases_AlwaysOnDatabaseId] PRIMARY KEY CLUSTERED 
(
	[AlwaysOnDatabaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CMDB].[AlwaysOnGroups]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CMDB].[AlwaysOnGroups](
	[AlwaysOnGroupId] [bigint] IDENTITY(1,1) NOT NULL,
	[AlwaysOnGroupName] [sysname] NOT NULL,
	[AlwaysOnReplicaHostId1] [bigint] NOT NULL,
	[Replica1SyncSetting] [bit] NOT NULL,
	[AlwaysOnReplicaHostId2] [bigint] NULL,
	[Replica2SyncSetting] [bit] NULL,
	[AlwaysOnReplicaHostId3] [bigint] NULL,
	[Replica3SyncSetting] [bit] NULL,
	[AlwaysOnReplicaHostId4] [bigint] NULL,
	[Replica4SyncSetting] [bit] NULL,
	[AlwaysOnReplicaHostId5] [bigint] NULL,
	[Replica5SyncSetting] [bit] NULL,
	[AlwaysOnReplicaHostId6] [bigint] NULL,
	[Replica6SyncSetting] [bit] NULL,
	[AlwaysOnReplicaHostId7] [bigint] NULL,
	[Replica7SyncSetting] [bit] NULL,
	[AlwaysOnReplicaHostId8] [bigint] NULL,
	[Replica8SyncSetting] [bit] NULL,
 CONSTRAINT [PK_AlwaysOnGroups_AlwaysOnGroupId] PRIMARY KEY CLUSTERED 
(
	[AlwaysOnGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CMDB].[Databases]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CMDB].[Databases](
	[DatabaseId] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [sysname] NOT NULL,
	[RecoveryMode] [sysname] NOT NULL,
	[DBOwnerRoleMember] [sysname] NOT NULL,
	[CreatedBy] [sysname] NOT NULL,
	[CreatedDateTimeUTC] [datetime] NOT NULL,
	[ModifiedBy] [sysname] NULL,
	[ModifiedDateTimeUTC] [datetime] NULL,
 CONSTRAINT [PK_dboDatabases_DatabaseId] PRIMARY KEY CLUSTERED 
(
	[DatabaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CMDB].[Hosts]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CMDB].[Hosts](
	[HostId] [bigint] IDENTITY(1,1) NOT NULL,
	[FullyQualifiedDomainName] [sysname] NOT NULL,
 CONSTRAINT [PK_Hosts_HostId] PRIMARY KEY CLUSTERED 
(
	[HostId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CMDB].[Instances]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CMDB].[Instances](
	[InstanceId] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceName] [sysname] NOT NULL,
	[HostId] [bigint] NOT NULL,
	[SQLVersion] [varchar](20) NOT NULL,
	[SQLEdition] [varchar](20) NOT NULL,
	[SQLServiceLoginId] [bigint] NOT NULL,
 CONSTRAINT [PK_Instances_InstanceId] PRIMARY KEY CLUSTERED 
(
	[InstanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CMDB].[Logins]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CMDB].[Logins](
	[LoginId] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [sysname] NOT NULL,
	[SID] [varbinary](85) NOT NULL,
	[IsSQLLogin] [bit] NOT NULL,
	[CreatedBy] [sysname] NOT NULL,
	[CreatedDateTimeUTC] [datetime] NOT NULL,
	[ModifiedBy] [sysname] NULL,
	[ModifiedDateTimeUTC] [datetime] NULL,
 CONSTRAINT [PK_dboLogins_LoginId] PRIMARY KEY CLUSTERED 
(
	[LoginId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AlwaysOnListeners]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlwaysOnListeners](
	[AlwaysOnListenerId] [bigint] IDENTITY(1,1) NOT NULL,
	[ListenerName] [sysname] NOT NULL,
	[ListenerIP1] [varchar](16) NOT NULL,
	[ListenerIP2] [varchar](16) NULL,
	[ListenerIP3] [varchar](16) NULL,
	[ListenerIP4] [varchar](16) NULL,
	[ListenerIP5] [varchar](16) NULL,
	[ListenerIP6] [varchar](16) NULL,
	[ListenerIP7] [varchar](16) NULL,
	[ListenerIP8] [varchar](16) NULL,
 CONSTRAINT [PK_AlwaysOnListeners_AlwaysOnListenerId] PRIMARY KEY CLUSTERED 
(
	[AlwaysOnListenerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BackupLocations]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BackupLocations](
	[BackupLocationId] [int] IDENTITY(1,1) NOT NULL,
	[Location] [nvarchar](200) NOT NULL,
	[IsForFull] [bit] NOT NULL,
	[IsForDiff] [bit] NOT NULL,
	[IsForLog] [bit] NOT NULL,
	[CreatedBy] [sysname] NOT NULL,
	[CreatedDatetimeUTC] [datetime] NOT NULL,
	[ModifiedBy] [sysname] NULL,
	[ModifiedDateTimeUTC] [datetime] NULL,
 CONSTRAINT [PK_dboBackupLocations_BackupLocationsId] PRIMARY KEY CLUSTERED 
(
	[BackupLocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[HelpDeskLog] ADD  DEFAULT (getdate()) FOR [RunDateTime]
GO
ALTER TABLE [CMDB].[Databases] ADD  DEFAULT (getutcdate()) FOR [CreatedDateTimeUTC]
GO
ALTER TABLE [CMDB].[Logins] ADD  DEFAULT (getutcdate()) FOR [CreatedDateTimeUTC]
GO
ALTER TABLE [dbo].[BackupLocations] ADD  DEFAULT (getutcdate()) FOR [CreatedDatetimeUTC]
GO
ALTER TABLE [CMDB].[AlwaysOnDatabases]  WITH CHECK ADD  CONSTRAINT [FK_AlwaysOnDatabases_Databases_DatabaseId] FOREIGN KEY([DatabaseId])
REFERENCES [CMDB].[Databases] ([DatabaseId])
GO
ALTER TABLE [CMDB].[AlwaysOnDatabases] CHECK CONSTRAINT [FK_AlwaysOnDatabases_Databases_DatabaseId]
GO
ALTER TABLE [CMDB].[AlwaysOnGroups]  WITH CHECK ADD  CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica1] FOREIGN KEY([AlwaysOnReplicaHostId1])
REFERENCES [CMDB].[Hosts] ([HostId])
GO
ALTER TABLE [CMDB].[AlwaysOnGroups] CHECK CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica1]
GO
ALTER TABLE [CMDB].[AlwaysOnGroups]  WITH CHECK ADD  CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica2] FOREIGN KEY([AlwaysOnReplicaHostId2])
REFERENCES [CMDB].[Hosts] ([HostId])
GO
ALTER TABLE [CMDB].[AlwaysOnGroups] CHECK CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica2]
GO
ALTER TABLE [CMDB].[AlwaysOnGroups]  WITH CHECK ADD  CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica3] FOREIGN KEY([AlwaysOnReplicaHostId3])
REFERENCES [CMDB].[Hosts] ([HostId])
GO
ALTER TABLE [CMDB].[AlwaysOnGroups] CHECK CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica3]
GO
ALTER TABLE [CMDB].[AlwaysOnGroups]  WITH CHECK ADD  CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica4] FOREIGN KEY([AlwaysOnReplicaHostId4])
REFERENCES [CMDB].[Hosts] ([HostId])
GO
ALTER TABLE [CMDB].[AlwaysOnGroups] CHECK CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica4]
GO
ALTER TABLE [CMDB].[AlwaysOnGroups]  WITH CHECK ADD  CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica5] FOREIGN KEY([AlwaysOnReplicaHostId5])
REFERENCES [CMDB].[Hosts] ([HostId])
GO
ALTER TABLE [CMDB].[AlwaysOnGroups] CHECK CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica5]
GO
ALTER TABLE [CMDB].[AlwaysOnGroups]  WITH CHECK ADD  CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica6] FOREIGN KEY([AlwaysOnReplicaHostId6])
REFERENCES [CMDB].[Hosts] ([HostId])
GO
ALTER TABLE [CMDB].[AlwaysOnGroups] CHECK CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica6]
GO
ALTER TABLE [CMDB].[AlwaysOnGroups]  WITH CHECK ADD  CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica7] FOREIGN KEY([AlwaysOnReplicaHostId7])
REFERENCES [CMDB].[Hosts] ([HostId])
GO
ALTER TABLE [CMDB].[AlwaysOnGroups] CHECK CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica7]
GO
ALTER TABLE [CMDB].[AlwaysOnGroups]  WITH CHECK ADD  CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica8] FOREIGN KEY([AlwaysOnReplicaHostId8])
REFERENCES [CMDB].[Hosts] ([HostId])
GO
ALTER TABLE [CMDB].[AlwaysOnGroups] CHECK CONSTRAINT [FK_AlwaysOnGroups_Hosts_Replica8]
GO
ALTER TABLE [CMDB].[Instances]  WITH CHECK ADD  CONSTRAINT [FK_Instances_Hosts_HostId] FOREIGN KEY([HostId])
REFERENCES [CMDB].[Hosts] ([HostId])
GO
ALTER TABLE [CMDB].[Instances] CHECK CONSTRAINT [FK_Instances_Hosts_HostId]
GO
ALTER TABLE [CMDB].[Instances]  WITH CHECK ADD  CONSTRAINT [FK_Instances_Logins_SQLServiceLoginId] FOREIGN KEY([SQLServiceLoginId])
REFERENCES [CMDB].[Logins] ([LoginId])
GO
ALTER TABLE [CMDB].[Instances] CHECK CONSTRAINT [FK_Instances_Logins_SQLServiceLoginId]
GO
/****** Object:  StoredProcedure [dbo].[AddDatabaseUser]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddDatabaseUser]
	@DatabaseName sysname,
	@DatabaseUser sysname
WITH EXECUTE AS OWNER	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname, @OriLogin SYSNAME
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	
	--No injection check since this should be handled out sie of this sproc.
	EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @DatabaseUser, @message = 'Starting AddDBUser Proc.';
	BEGIN TRY
		DECLARE @SQL nvarchar(4000)
		DECLARE @QuotedDatabaseName sysname,@QuotedDatabaseUser sysname
		IF(CHARINDEX('[',@DatabaseName,0) = 0)
		BEGIN
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName)
		END
		ELSE
			SET @QuotedDatabaseName = @DatabaseName
		IF(CHARINDEX('[',@DatabaseUser,0) = 0)
		BEGIN
			SET @QuotedDatabaseUser = QUOTENAME(@DatabaseUser)
		END
		ELSE
			SET @QuotedDatabaseUser = @DatabaseUser
		SET @SQL = 'USE '+@QuotedDatabaseName+'; 
		CREATE USER'+@QuotedDatabaseUser+' FROM LOGIN '+@QuotedDatabaseUser+';'
		--alter the database
		EXEC (@SQL)
		--To do add an if to confirm for rare failure of try catch
			EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @DatabaseUser, @message = 'Successfully Finished AddDBUser Proc.';
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @DatabaseUser, @message= 'Problem creating Database User: failed!'
		RETURN 1;
	END CATCH
	RETURN 0;
END
GO
/****** Object:  StoredProcedure [dbo].[AddDbOwnerRoleMember]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
***********************************
*SQL HelpDesk Demo
Proc: SetDatabaseRecoveryMode
Params: @DatabaseName, @DbOwner_RoleMember

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2016-04-01
***********************************
*/

CREATE PROCEDURE [dbo].[AddDbOwnerRoleMember]
	@DatabaseName sysname,
	@DbOwner_RoleMember sysname
WITH EXECUTE AS OWNER	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname, @OriLogin sysname
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	
	--No injection check since this should be handled out sie of this sproc.
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @DbOwner_RoleMember, @message = 'Starting DBOwner_roleMember Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname,@QuotedDBOwner sysname
		DECLARE @SQL nvarchar(4000)
		IF(CHARINDEX('[',@DatabaseName,0) = 0)
		BEGIN
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName)
		END
		IF(CHARINDEX('[',@DbOwner_RoleMember,0) = 0)
		BEGIN
			SET @QuotedDBOwner = QUOTENAME(@DbOwner_RoleMember)
		END
		SET @SQL = 'USE '+@QuotedDatabaseName+'; ALTER ROLE [db_Owner] ADD MEMBER '+@QuotedDBOwner+';'
		--alter the database
		EXEC (@SQL)
		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @DbOwner_RoleMember, @Message = 'Successfully finsihed DBOwner_roleMember Proc.';
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @DbOwner_RoleMember, @message= 'Setting DBOwner_roleMember mode failed!'
		RETURN 1;
	END CATCH
	RETURN 0;
END
GO
/****** Object:  StoredProcedure [dbo].[BackupDatabase]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BackupDatabase]
	@DatabaseName Sysname,
	@BackupLocation VARCHAR(256) = 'C:\Temp\',
	@BackupFileName VARCHAR(100) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	--TODO add flexibility for other database backup types
	SET NOCOUNT ON;
	
	DECLARE @RC INT = 0;
	DECLARE @procname sysname
	DECLARE @OriLogin SYSNAME 
	DECLARE @Message NVARCHAR(1000)
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName,@BackupLocation,@BackupFileName, @message = 'Starting Backup of the database Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname
		DECLARE @SQL nvarchar(4000)
		--Make sure our DB name is quoted!
		IF(CHARINDEX('[',@DAtabaseName,0) = 0)
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName);
		ELSE
			SET @QuotedDatabaseName = @DatabaseName;
	--Check backupLocation has a '\' at the end
	IF(CHARINDEX('\',REVERSE(@BackupLocation),0) <> 1)
		SET @BackupLocation = @BackupLocation +'\';
	IF(@BackupFileName IS NULL)
		SET @BackupFileName = @DatabaseName +'_FULL_'+CAST(GETDATE() AS VARCHAR(25))+'.bak'
	
	--Make sure our DB exists
	IF NOT EXISTS (SELECT 1 FROM master.sys.databases WHERE QUOTENAME(NAME) = @QuotedDatabaseName)
	BEGIN
		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName,@BackupLocation,@BackupFileName, @message = 'Cannot Backup a database that does not exist!';
		RETURN 1;
	END
	ELSE
	BEGIN
		SET @SQL = 'BACKUP DATABASE ' + @QuotedDatabaseName + '
		TO DISK = '''+@BackupLocation+@BackupFileName+'''
		WITH INIT, STATS = 1'
		EXEC (@SQL)
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName,@BackupLocation,@BackupFileName, @message= 'Successfully backed up the database!';
		RETURN 0;
	END
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName,@BackupLocation,@BackupFileName, @message= 'The database Failed to Backup!';
		RETURN 1;
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[CreateDatabase]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CreateDatabase]
	@DatabaseName sysname
WITH EXECUTE AS OWNER	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname
	DECLARE @OriLogin SYSNAME 
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @message = 'Starting CreateDatabase Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname
		DECLARE @SQL nvarchar(4000)

		--check if our db needs to be quote named, we shouldnt have to 
		--this should have been done in the top level sproc in helpdesk schema,
		--but it never hurts to be SURE!
		IF(CHARINDEX('[',@DatabaseName,0)=0)
		BEGIN
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName)
		END
		ELSE
			SET @QuotedDatabaseName = @DatabaseName
		SET @SQL = 'USE MASTER; CREATE DATABASE '+ @QuotedDatabaseName +';'
		--Create the database
		EXEC (@SQL)
		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @Message = 'Successfully Finished CreateDatabase Proc.'; 
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @message= 'The New database Failed to create!'
		RETURN 1;
	END CATCH
	RETURN 0;
END
GO
/****** Object:  StoredProcedure [dbo].[LogAction]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Object:  StoredProcedure [dbo].[RestoreDatabase]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RestoreDatabase]
	@DatabaseName Sysname,
	@BackupLocation VARCHAR(256) = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	--TODO add flexibility for other database backup types
	SET NOCOUNT ON;
	
	DECLARE @RC INT = 0;
	DECLARE @procname sysname
	DECLARE @OriLogin SYSNAME 
	DECLARE @Message NVARCHAR(1000)
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName,@BackupLocation, @message = 'Starting inner RestoreDatabase Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname
		DECLARE @SQL nvarchar(4000)
		--Make sure our DB name is quoted!
		IF(CHARINDEX('[',@DatabaseName,0) = 0)
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName);
		ELSE
			SET @QuotedDatabaseName = @DatabaseName;
	--Check backupLocation has a '\' at the end
	IF(CHARINDEX('\',REVERSE(@BackupLocation),0) <> 1)
		SET @BackupLocation = @BackupLocation +'\';
	--If we dont have a backup file find the last one
	--***** WHAT PROBLEM DO WE HAVE RIGHT NOW, HINT WE ACCEPT A FILE!
	IF(@BackupLocation IS NULL)
		BEGIN
			SET @BackupLocation = (SELECT TOP 1 physical_device_name 
				FROM msdb.dbo.backupset bs 
				INNER JOIN msdb.dbo.backupmediafamily bmf on bs.media_set_id = bmf.media_set_id
				WHERE QUOTENAME(bs.database_name) = @QuotedDatabaseName
				ORDER BY Bs.backup_start_date desc
				)
		END
		--WE SHOULD BE CAREFUL OF DESTRUCTIVE THINGS!!!!
		SET @SQL = 'USE [master]; ALTER DATABASE ' +@QuotedDatabaseName+' SET OFFLINE WITH ROLLBACK IMMEDIATE;
		RESTORE DATABASE ' + @QuotedDatabaseName + '
		FROM DISK = '''+@BackupLocation+'''
		WITH RECOVERY,REPLACE, STATS = 1'
		EXEC (@SQL)
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName,@BackupLocation, @message= 'Successfully RESTORED the database!';
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName,@BackupLocation, @message= 'The database Failed to RESTORE!';
		RETURN 1;
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[SetDatabaseRecoveryMode]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
***********************************
*SQL HelpDesk Demo
Proc: SetDatabaseRecoveryMode
Params: @DatabaseName, @RecoveryMode

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2016-04-01
***********************************
*/

CREATE PROCEDURE [dbo].[SetDatabaseRecoveryMode]
	@DatabaseName sysname,
	@RecoveryMode sysname
WITH EXECUTE AS OWNER	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname, @OriLogin sysname

	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()
	--No injection check since this should be handled out sie of this sproc.
	EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @RecoveryMode, @message = 'Starting Set RecoveryMode  Proc.';
	BEGIN TRY
		DECLARE @QuotedDatabaseName sysname
		DECLARE @SQL nvarchar(4000)
		IF(CHARINDEX('[',@DatabaseName,0) = 0)
		BEGIN
			SET @QuotedDatabaseName = QUOTENAME(@DatabaseName)
		END
		ELSE 
			SET @QuotedDatabaseName = @DatabaseName
		SET @SQL = 'ALTER DATABASE '+@QuotedDatabaseName+' SET RECOVERY '+@RecoveryMode+';'
		--alter the database
		EXEC (@SQL)
		--Update the CMDB with the new recovery mode for our records.
		--only update if the entry exists and the database recovery mode isnt the same.  This is incase we have
		--not entered the database in yet via the createdb SPROC. 
		IF EXISTS(SELECT name FROM sys.databases where name = @DatabaseName and recovery_model_desc <> @RecoveryMode)
		BEGIN
			UPDATE CMDB.Databases
			SET RecoveryMode = @RecoveryMode
			WHERE name = @DatabaseName
		END

		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @RecoveryMode, @message = 'Successfully Logged RecoveryMode change to CMDB Proc.';
		EXEC [dbo].LogAction @procname, @OriLogin, @DatabaseName, @RecoveryMode, @message = 'Successfully finished Set RecoveryMode  Proc.'
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname,@OriLogin, @DatabaseName, @RecoveryMode, @message= 'Setting database recovery mode failed!'
		RETURN 1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SqlInjectionCheck]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Object:  StoredProcedure [dbo].[VerifyAccess]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
		EXEC dbo.LogAction @procname ='VerifyAccess', @helpDeskUser = @OrgLogin, @Message =  'You are not a member of the appropriate group or role. Please contact the DBA'
		--I use the return code of 1 to mark a failure.  
		RETURN 1;
	END
	ELSE
	BEGIN
		RETURN 0;
	END
END
GO
/****** Object:  StoredProcedure [HelpDesk].[BackupDatabase]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
***********************************
*SQL HelpDesk Demo
Proc: Take a database backup
Params: @DatabaseName

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2017-05-20
***********************************
*/
CREATE PROCEDURE [HelpDesk].[BackupDatabase]
	@DatabaseName sysname,
	@BackupLocation VARCHAR(256) = 'C:\Temp\',
	@BackupFileName VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @Message VARCHAR(1000)
	DECLARE @procname sysname 
	DECLARE @HelpDeskUser sysname
	
	SELECT @procname = object_name(@@Procid), @HelpDeskUser = ORIGINAL_Login();
	--SQL Injection check
	--QuoteName your input! make sure no one is doing something sneaky or you just executed it!
	DECLARE @QuoteDatabaseName sysname
	SET @QuoteDatabaseName = QUOTENAME(@DatabaseName);

	--Start the log
	EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @BackupLocation, @BackupFileName, @message = 'Starting Helpdesk.BackupDatabase Sproc'

	EXEC @RC = [dbo].SqlInjectionCheck @QuoteDatabaseName, @BackupLocation, @BackupFileName;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@QuoteDatabaseName, @BackupLocation,@BackupFileName, @message = 'INJECT CHECK FAILED!';
		RETURN 1;
	END
	
	--Verify Access check
	EXECUTE AS LOGIN = ORIGINAL_LOGIN();
	EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@DatabaseName, @BackupLocation, @BackupFileName, @message = 'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END

	BEGIN TRY
		EXEC @RC = dbo.BackupDatabase @DatabaseName, @BackupLocation, @BackupFileName
		IF(@RC <> 0)
		BEGIN
			EXEC [dbo].LogAction @procname, @HelpDeskUser,@DatabaseName, @BackupLocation, @BackupFileName, @message = 'Failed to backup database in Helpdesk.BackupDatabase' 
			RETURN 1;
		END
		SET @Message = 'Database (' + @DatabaseName +') on Instance ('+ @@SERVERNAME+') Backed up to location ('+@BackupLocation+') to file ('+@BackupFileName+')' 
		EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @BackupLocation, @BackupFileName, @message = @Message
		RETURN 0
	END TRY
	BEGIN CATCH

		RETURN 1;
	END CATCH 
END
GO
/****** Object:  StoredProcedure [HelpDesk].[CreateDatabase]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
***********************************
*SQL HelpDesk Demo
Proc: Create A Database
Params: @DatabaseName

NOT Using Execute as owner directly
calls sub-sproc using EXECUTE AS OWNER
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2016-04-02
***********************************
*/
CREATE PROCEDURE [HelpDesk].[CreateDatabase]
	@DatabaseName sysname,
	@RecoveryMode sysname = 'SIMPLE',
	@DBOwner_RoleMember sysname = NULL,
	@DBOwner_isSQLLogin BIT = 0,
	@DBOwner_sqlLoginPassword VARCHAR(85) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname 
	DECLARE @HelpDeskUser sysname
	
	SELECT @procname = object_name(@@Procid), @HelpDeskUser = ORIGINAL_Login();
	--SQL Injection check
	--QuoteName your input! make sure no one is doing something sneaky or you just executed it!
	DECLARE @QuoteDatabaseName sysname
	DECLARE @QuoteRecoveryMode sysname 
	DECLARE @QuoteDBOwner sysname
	DECLARE @QuotedPassword VARCHAR(85)

	IF(@DBOwner_RoleMember is NULL)
	BEGIN
		EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @recoveryMode, @DBOwner_rolemember, @DBOwner_isSQLLogin, 'MASKED PASSWORD', @message = 'Please supply a DBOwner_Rolemember login for Helpdesk.CreateDatabase..'
		RETURN 1;
	END
	IF(@DBOwner_isSQLLogin = 1 AND @DBOwner_sqlLoginPassword IS NULL)
	BEGIN
		EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @recoveryMode, @DBOwner_rolemember, @DBOwner_isSQLLogin, @DBOwner_sqlLoginPassword, @message = 'Please supply a Password for the sql login for Helpdesk.CreateDatabase.'
		RETURN 1;
	END

	SET @QuoteDatabaseName = QUOTENAME(@DatabaseName);
	SET @QuoteRecoveryMode = QUOTENAME(@RecoveryMode);
	SET @QuoteDBOwner = QUOTENAME(@DBOwner_RoleMember);
	SET @QuotedPassword = QUOTENAME(@DBOwner_sqlLoginPassword);

	--Start the log
	EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @recoveryMode, @DBOwner_rolemember, @DBOwner_isSQLLogin, 'MASKED PASSWORD', @message = 'Starting Helpdesk.CreateDatabase Sproc'

	EXEC @RC = [dbo].SqlInjectionCheck @QuoteDatabaseName, @QuoteRecoveryMode, @QuoteDBOwner, @QuotedPassword;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@QuoteDatabaseName, @QuoteRecoveryMode, @DBOwner_isSQLLogin,'MASKED PASSWORD',@message = 'INJECT CHECK FAILED!';
		RETURN 1;
	END
	
	--Verify Access check
	EXECUTE AS LOGIN = ORIGINAL_LOGIN();
	EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@Databasename, @RecoveryMode,@DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD',@message = 'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END

	--Build our create database statement,  For ease of the demo,  I am not doing much here.  Just a simple create
	--You can make this more dynamic, controlling file locations.
	DECLARE @SQL nvarchar(4000)
	DECLARE @Message Nvarchar(1000)
	
	BEGIN TRY
		--Validate there is enough space on disk!
		--Validate the dbowner!
		EXEC @RC = [HelpDesk].CreateLogin @LoginName = @DBOwner_RoleMember, @isSQLLogin = @DBOwner_isSQLLogin, @Password = @DBOwner_sqlLoginPassword
		IF (@RC <> 0)
		BEGIN
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem Creating login for DBOwner: failed.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Login (' + @DBOwner_RoleMember +') Ready for use on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message = @Message
		END
		--Create the database
		-----SHOULD ADD A CHECK HERE TO SEE IF THE DBNAME ALREADY EXISTS!!!
		EXEC @RC = dbo.CreateDatabase @DatabaseName
		IF (@RC <> 0)
		BEGIN
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem Creating Database from Helpdesk.CreateDatabase Sproc.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Database (' + @DatabaseName +') Created on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message = @Message
		END
		--Create the database user for the dbowner.
		EXEC @RC = dbo.AddDatabaseUser @DatabaseName,@DBOwner_RoleMember
		IF(@RC <> 0)
		BEGIN 
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem Creating Database user in Helpdesk.CreateDatabase Sproc.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Database User (' + @DBOwner_RoleMember +') created in Database ('+@DatabaseName+') on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember, @DBOwner_isSQLLogin,'MASKED PASSWORD',@message = @Message
		END
		--Change the recovery mode.
		EXEC @RC = dbo.SetDatabaseRecoveryMode @DatabaseName, @RecoveryMode;
		IF (@RC <> 0)
		BEGIN
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem setting recovery mode in Helpdesk.CreateDatabase Sproc.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Set DB recovery mode to (' + @RecoveryMode+') Database ('+@DatabaseName+') on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message = @Message
		END
		--SET the DBOwner
		EXEC @RC = dbo.AddDbOwnerRoleMember @DatabaseName, @DbOwner_RoleMember
		IF (@RC <> 0)
		BEGIN
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message ='Problem Adding DBOwner_RoleMemeber mode: failed.'
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Added DB_owner User (' + @DBOwner_RoleMember +') for Database ('+@DatabaseName+') on Instance ('+ @@SERVERNAME+')'
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember, @DBOwner_isSQLLogin,'MASKED PASSWORD',@message = @Message
		END
		/*
		Log the settings it should have for future lookup!
		Again we are doing the bare minimun,  you could select from sys.databases, and dump that information
		along with any additional paramemeters from the SPROC.
		*/
		INSERT CMDB.Databases (Name, RecoveryMode, DBOwnerRoleMember, CreatedBy)
		VALUES (@DatabaseName,@RecoveryMode,@DBOwner_RoleMember,@HelpDeskUser)
		
		EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @RecoveryMode, @DBOwner_RoleMember,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message = 'Successfully Completed Helpdesk.CreateDatabase Sproc!'
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname, @Helpdeskuser, @QuoteDatabaseName, @RecoveryMode,@DBOwner_isSQLLogin,'MASKED PASSWORD', @message= 'Database creation failed!'
		RETURN 1;
	END CATCH
	RETURN 0;
END
GO
/****** Object:  StoredProcedure [HelpDesk].[CreateLogin]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
***********************************
*SQL HelpDesk Demo
Proc: CreateLogin
Params: @LoginName, @IsSQLLogin

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2016-04-01
***********************************
*/
CREATE PROCEDURE [HelpDesk].[CreateLogin]
	@LoginName sysname,
	@IsSQLLogin BIT = 0,
	@Password VARCHAR(85) = NULL
	--1.) running as owner, since the database is owned by SA, and TRUSTWORTHY, i can execute code as SA.
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @procname sysname 
	DECLARE @HelpDeskUser sysname
	/*2.)
	Store the current running proceedure name and the original caller.  
	Since we are running as SA, we need to store the original calling user.
	*/
	SELECT @procname = object_name(@@Procid), @HelpDeskUser = ORIGINAL_Login();

	/*3.)
	SQL Injection check
	QuoteName your input! make sure no one is doing something sneaky or you just executed it!
	*/
	DECLARE @QuotedLoginName sysname 
	IF(CHARINDEX('[',@loginName,0) = 0 AND CHARINDEX(']',@loginname,0) = 0)
		SET @QuotedLoginName = QUOTENAME(@LoginName)
	ELSE
		SET @QuotedLoginName = @LoginName

	EXEC @RC = [dbo].SqlInjectionCheck @QuotedLoginName;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@LoginName, @IsSQLLogin,NULL,'INJECT CHECK FAILED!';
		RETURN 1;
	END

	EXEC [dbo].LogAction @procname, @HelpDeskUser, @LoginName, @IsSQLLogin, NULL, @message = 'Starting Proc CreateLogin';
	/* 4.)
	Check if the user has the right access, dont just rely on schema perms make sure!	
	NOTICE we execute this sub section as the user
	And revert immediately!!! we need SA to continue our sproc!
	*/
	EXECUTE AS LOGIN = ORIGINAL_LOGIN();
		EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@LoginName, @IsSQLLogin,NULL,'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END

	--Ok we passed the injection check, and the access Check, 
	--cool lets verify we need create a login
	BEGIN TRY
		DECLARE @SQLCmd nvarchar (4000)
		DECLARE @Sid  varbinary (85)
		
		IF EXISTS (SELECT 1 FROM master.sys.server_principals WHERE QUOTENAME(name) = @QuotedLoginName)
		BEGIN
			EXEC dbo.LogAction @procName, @HelpDeskUser, @LoginName, @IsSQLLogin, @Sid, @Message = 'Login already Exists! skipping!'
			RETURN 0;
		END

		IF (@IsSQLLogin = 1)
		BEGIN
			SET @SQLCmd = 'CREATE LOGIN '+@QuotedLoginName+' WITH PASSWORD = '''+ CAST(@Password as varchar(max)) + ''' ,CHECK_EXPIRATION = OFF, CHECK_POLICY = ON;'
		END
		ELSE
		BEGIN
			SET @SQLCmd = 'CREATE LOGIN '+@QuotedLoginName+' FROM WINDOWS'
		END
		EXEC (@SQLCmd)
		--get the sid
		SELECT @sid = sid FROM master.sys.server_principals WHERE QUOTENAME(name) = @QuotedLoginName
		INSERT CMDB.Logins (name,SID,IsSQLLogin,CreatedBy)
		VALUES (@LoginName, @Sid, @IsSQLLogin, @HelpDeskUser)

		EXEC dbo.LogAction @procName, @HelpDeskUser, @LoginName, @IsSQLLogin, @Sid, @Message = 'Successfully Updated CMDB.Logins with new Login'
		EXEC dbo.LogAction @procName, @HelpDeskUser, @LoginName, @IsSQLLogin, @Sid, @Message = 'Successfully Created Login'
		RETURN 0;
	END TRY
	BEGIN CATCH
		EXEC [dbo].LogAction @procname, @HelpdeskUser, @LoginName, @IsSQLLogin, NULL, @Message = 'Something went wrong creating a login, Validate login was created, and inserted into the logins table.'
	END CATCH
END
GO
/****** Object:  StoredProcedure [HelpDesk].[GetDatabaseInfo]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
***********************************
*SQL HelpDesk Demo
Proc: GetDatabaseInfo
Params: @DatabaseName

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2015-04-14
***********************************
*/

--NOTICE Most of this should be wrapped in try catch blocks! shame on the guy that wrote this!

CREATE PROCEDURE [HelpDesk].[GetDatabaseInfo]
	@DatabaseName sysname  --NOTICE SYSNAME is our data type

--Here is where we add execute as owner
WITH EXECUTE AS OWNER	
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @HelpDeskUser sysname;
	DECLARE @procname sysname

	SELECT @procname = object_name(@@Procid), @HelpDeskUser = ORIGINAL_Login();
	
	--SQL Injection check
	--QuoteName your input! make sure no one is doing something sneaky or you just executed it!
	DECLARE @QuotedDatabaseName sysname 
	SET @QuotedDatabaseName = QUOTENAME(@DatabaseName);
	EXEC @RC = [dbo].SqlInjectionCheck @QuotedDatabaseName;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@Databasename, NULL,NULL,'INJECT CHECK FAILED!';
		RETURN 1;
	END

	EXEC [dbo].LogAction @procname, @HelpDeskUser, @DatabaseName, NULL, NULL, 'Starting Proc.';
	--Check if the user has the right access, dont just rely on schema perms make sure!	
	--NOTICE we execute this sub section as the user
	--And revert immediately!!! we need SA to continue our sproc!
	EXECUTE AS USER = ORIGINAL_LOGIN();
		EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@Databasename, NULL,NULL,'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END
	
	--We can now safely run the the actual sproc we want!
	SELECT SUSER_NAME() AS ExecutedAS, ORIGINAL_LOGIN() AS OriginalUserLogin, * 
	FROM sys.databases 
	WHERE name = @DatabaseName; 

	--Log the results
	EXEC [dbo].LogAction @procname,@HelpDeskUser,@DatabaseName,Null,Null,'Sproc completed Successfully';
	RETURN 0
END
GO
/****** Object:  StoredProcedure [HelpDesk].[RestoreDatabase]    Script Date: 2017-07-29 10:57:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
***********************************
*SQL HelpDesk Demo
Proc: Restore a database backup
Params: @DatabaseName

Using Execute as owner 
SQL Injection ChecK
Logging
Verify Check

Created By: Stephen Mokszycki
Demo Date: 2017-05-20
***********************************
*/
CREATE PROCEDURE [HelpDesk].[RestoreDatabase]
	@DatabaseName sysname,
	@BackupLocation VARCHAR(256) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RC INT = 0;
	DECLARE @Message VARCHAR(1000)
	DECLARE @procname sysname 
	DECLARE @HelpDeskUser sysname
	
	SELECT @procname = object_name(@@Procid), @HelpDeskUser = ORIGINAL_Login();
	--SQL Injection check
	--QuoteName your input! make sure no one is doing something sneaky or you just executed it!
	DECLARE @QuoteDatabaseName sysname
	SET @QuoteDatabaseName = QUOTENAME(@DatabaseName);

	--Start the log
	EXEC dbo.LogAction @procname, @HelpDeskUser, @databaseName, @BackupLocation, @message = 'Starting Helpdesk.RestoreDatabase Sproc'

	EXEC @RC = [dbo].SqlInjectionCheck @QuoteDatabaseName, @BackupLocation;
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@QuoteDatabaseName, @BackupLocation, @message = 'INJECT CHECK FAILED!';
		RETURN 1;
	END
	
	--Verify Access check
	EXECUTE AS LOGIN = ORIGINAL_LOGIN();
	EXEC @RC = dbo.VerifyAccess;
	REVERT
	--If the user wasnt in the right group/role, kill the sproc
	IF(@RC <> 0)
	BEGIN
		EXEC [dbo].LogAction @procname, @HelpDeskUser,@DatabaseName, @BackupLocation, @message = 'VerifyAccess failed. User does not have correct Group/role membership.' 
		RETURN 1;
	END

	BEGIN TRY
		EXEC @RC = dbo.RestoreDatabase @DatabaseName, @BackupLocation OUTPUT
		IF(@RC <> 0)
		BEGIN
			EXEC [dbo].LogAction @procname, @HelpDeskUser,@DatabaseName, @BackupLocation, @message = 'Failed to Restore database in Helpdesk.RestoreDatabase' 
			RETURN 1;
		END
		ELSE 
		BEGIN
			SET @Message = 'Database ('+ @DatabaseName+') Restored on from location ('+@BackupLocation+')' 
			EXEC dbo.LogAction @procname, @HelpDeskUser, @DatabaseName, @BackupLocation, @message = @Message
		RETURN 0
		END

	END TRY
	BEGIN CATCH

		RETURN 1;
	END CATCH 
END
GO
--4.) Create our database user and map him
USE [SQLSelfService]
CREATE USER [HelpDesk_JohnDoe] FROM LOGIN [HelpDesk_JohnDoe]
ALTER ROLE [HelpDeskUsers] ADD MEMBER [HelpDesk_JohnDoe]

--5.) GRANT ROLE Execute access on Helpdesk Schema
USE SQLSelfService
GRANT EXECUTE ON SCHEMA::HelpDesk TO [HelpDeskUsers]

--6.) Change the DATABASE DBO (database owner) SET TrustworthyOn
USE [Master]
ALTER AUTHORIZATION ON DATABASE::[SQLSelfService] TO [sa]
ALTER DATABASE [SQLSelfService] SET TRUSTWORTHY ON