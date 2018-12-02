# DevOpsSQLServer
A Database Code framework to Automate your DBAs, and empower your developers
This is intended to help DBAs automate away mundane tasks safely and securly.  Things like taking backups, creating new logins, setting up alwaysOn, etc. 

## Whats In thus package
An inital database, with several core functions, tables, and sprocs to get you started.  
* Create a login (windows or SQL)
* Create a Database
* Set the database owner
* Set the Database recovery mode
* Take a database backup (FULL) *
* Restore a database backup (FULL) *
* Create a database user and map user to login
* Add database user to role

## The *
The backup and restore stored procedures assume a default backup location.  This should be changed as needed for your environment.  The restore stored proc, currently looks at msdb for the last known backup.  This can be altered to take in a file path (be careful), or supplied date.

## To install
1. Run the CreateSQLSelfService.sql Script to create the base objects. OR Publish the Databse project from visual studio against a targer server.
2. Set up a login (sql or windows), map it as a user to the db.
3. Add the new user to the [HelpDeskUsers] role.
4. The new user will now have access to run the self service stored procedures.
5. For further information see the presentations at: https://github.com/ScubaTron84/Presentations

