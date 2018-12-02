/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
USE [master]
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'HelpDesk_JohnDoe' and type = 'S')
 EXEC ('CREATE LOGIN [HelpDesk_JohnDoe] WITH PASSWORD = ''SCUBA123'', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;')
GO
USE [$(DatabaseName)]
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'HelpDesk_JohnDoe' and type = 'S')
BEGIN
	exec ('CREATE USER [HelpDesk_JohnDoe] FROM LOGIN [HelpDesk_JohnDoe]')
	Exec ('ALTER ROLE [HelpDeskUsers] ADD MEMBER [HelpDesk_JohnDoe]')
END
GO

USE [$(DatabaseName)]
EXEC sp_changedbowner @loginame = 'sa'
GO
ALTER DATABASE [$(DatabaseName)] SET TRUSTWORTHY ON;
GO
