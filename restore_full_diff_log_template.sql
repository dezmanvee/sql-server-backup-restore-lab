/*
LAB TEMPLATE ONLY - replace names and paths.
Example restore sequence for a FULL backup, then DIFFERENTIAL, then LOG backups.
*/
RESTORE DATABASE YourDatabase
FROM DISK = N'C:\SQLBackups\YourDatabase_FULL.bak'
WITH
    MOVE N'YourDatabase' TO N'D:\SQLData\YourDatabase.mdf',
    MOVE N'YourDatabase_log' TO N'E:\SQLLogs\YourDatabase_log.ldf',
    NORECOVERY,
    REPLACE,
    STATS = 10;
GO

RESTORE DATABASE YourDatabase
FROM DISK = N'C:\SQLBackups\YourDatabase_DIFF.bak'
WITH NORECOVERY, STATS = 10;
GO

RESTORE LOG YourDatabase
FROM DISK = N'C:\SQLBackups\YourDatabase_LOG.trn'
WITH RECOVERY, STATS = 10;
GO
