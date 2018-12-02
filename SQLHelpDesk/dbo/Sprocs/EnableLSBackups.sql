/*
Author: Stephen Mokszycki
Creation Date: 2017-09-24 (currently in San Diego chillin at Lofty Coffee).
Description:  Creates and enables LS_Backups for a given Database.

Help doc: https://docs.microsoft.com/en-us/sql/database-engine/log-shipping/configure-log-shipping-sql-server#TsqlProcedure
*/
CREATE PROCEDURE [dbo].[EnableLSBackups]
	@DatabaseName sysname,
	@InstanceName sysname,
	@BackupLocation nvarchar(256),
	@BackupLogRetentionHours INT = 72,
	@IsDatabaseAlwaysOn BIT = 0 --0 = not in alwayson, 1 = in always on
AS
BEGIN
	--Add Standard Checks
	DECLARE @RC INT = 0;
	DECLARE @procname sysname
	DECLARE @OriLogin SYSNAME 
	DECLARE @Message NVARCHAR(1000)
	SELECT @procname = object_name(@@Procid), @OriLogin = ORIGINAL_LOGIN()

	--check if backlocation is in the cmdb  (frame work for cmdb work)
	IF NOT EXISTS (SELECT FilePath FROM CMDB.BackupLocations WHERE FilePath = @BackupLocation)
		BEGIN
			PRINT 'WARNING FilePath (' +@BackupLocation+ ') not listed in CMDB.BackupLocations'
			INSERT INTO CMDB.BackupLocations(FilePath,IsTLogBackups,CreatedBy)
			VALUES (@BackupLocation,1,ORIGINAL_LOGIN())
		END

		--Check if database is already enabled in logshipping
		IF NOT EXISTS (SELECT 1 from MSDB.Dbo.log_shipping_primary_databases where primary_database = @DatabaseName)
		BEGIN
			--Check if the Database is in Full Recovery Mode,  If not put the DB in Full
			IF ((SELECT recovery_model_desc FROM master.sys.databases WHERE [name] = @DatabaseName) <> 'FULL')
			BEGIN
				SET @Message = 'Database ('+@DatabaseName+') on Instance('+@InstanceName+') not in FULL Recovery for Logshipping backups. Adjusting Recovery Model...'
				EXEC dbo.LogAction @procname = @procname, @HelpDeskUser = @OriLogin, 
					@input1 = @DatabaseName, @input2 = @InstanceName, @input3= @BackupLocation,
					@input4 = @BackupLogRetentionHours,@Message = @Message
				--Update Database Setting
				EXEC @RC = dbo.SetDatabaseRecoveryMode @DatabaseName = @DatabaseName, @RecoveryMode = 'FULL'
				--If Database Recovery mode fails to change, error out.
				IF(@RC <> 0)
				BEGIN
					SET @Message = 'Failed to set Database ('+@DatabaseName+') on Instance('+@InstanceName+') to FULL Recovery in Procedure('+@procname+')'
					
					EXEC dbo.LogAction @procname = @procname, @HelpDeskUser = @OriLogin, 
					@input1 = @DatabaseName, @input2 = @InstanceName, @input3= @BackupLocation,
					@input4 = @BackupLogRetentionHours,@Message = @Message
					
					RETURN 1;
				END
				ELSE
				BEGIN
					--UPDATE CMDB
					IF((SELECT RecoveryMode FROM CMDB.Databases WHERE [name] = @DatabaseName) <> 'FULL')
					BEGIN
						UPDATE CMDB.Databases 
						SET RecoveryMode = 'FULL'
						WHERE [name] = @DatabaseName
					END
				END
			END
			--Adds the database to logshipping as a primary
			DECLARE @LS_BackupJobId AS uniqueidentifier 
			DECLARE @LS_PrimaryId AS uniqueidentifier 
			DECLARE @LSBackupJobName Nvarchar(60) = N'LSBackup_'+@DatabaseName
			DECLARE @LSBackupJobScheduleName Nvarchar(60) = N'LSBackup_Schedule_'+@DatabaseName
			DECLARE @BackupThresholdMinutes INT = @BackupLogRetentionHours*60
			-----TODO update this sample code:
			--EXEC master.dbo.sp_add_log_shipping_primary_database 
			--	@database = @DatabaseName
			--	,@backup_directory = @BackupLocation
			--	,@backup_share = @BackupLocation
			--	,@backup_job_name = @LSBackupJobName
			--	,@backup_retention_period = 1440
			--	,@monitor_server = @@SERVERNAME 
			--	,@monitor_server_security_mode = 1 
			--	,@backup_threshold = @BackupThresholdMinutes 
			--	,@threshold_alert = 14420 
			--	,@threshold_alert_enabled = 1 
			--	,@history_retention_period = 14420 
			--	,@backup_job_id = @LS_BackupJobId OUTPUT 
			--	,@primary_id = @LS_PrimaryId OUTPUT 
			--	,@overwrite = 1 
			--	,@backup_compression = 0
			----Adds the LS Backup job schedule
			--exec msdb.dbo.sp_add_jobschedule 
			--@job_id = @LS_BackupJobId
			--,@name = @LSBackupJobScheduleName
			--,@enabled = 1
			--,@freq_type = --get freqtype numbe
			--,@freq_interval = --same
			--,@freq_subday_type = -- same
			--,@freq_subday_interval = --same
			--,@freq_relative_interval = 
			--,@freq_recurrence_factor =  
			--,@active_start_date = GETDAte()
			--,@active_end_date = null 
			--,@active_start_time = '00:00:00' 
			--,@active_end_time = '23:59:59' 
			--,@schedule_id = schedule_id OUTPUT
			--,@automaticpostbit = 
			--.@Schedule_UID = schedule_uid OUTPUT 
			---EXEC msdb.dbo

			--IF ALWAYS ON ADD NEW STEP TO JOB TO SKIP IF NOT CURRENTLY PRIMARY
		END
		ELSE
		BEGIN
			PRINT 'Database ('+@DatabaseName+') on SQL Instance (' +@InstanceName+') skipping setup of LSbackups...'
		END
END