/*
    SQL Server Backup & Restore Validation Lab
    Step 4: Restore full -> differential -> transaction log to a new database.

    Safety:
      - This script DOES NOT use WITH REPLACE.
      - It stops if PensionOpsLab_RestoreTest already exists.
      - Update logical file names if RESTORE FILELISTONLY returns different names.
*/

USE master;
GO

DECLARE @BackupDirectory nvarchar(260) = N'C:\SQLBackups\DbaPortfolioLab';
DECLARE @DataDirectory   nvarchar(260) = N'C:\SQLData\DbaPortfolioLab';

DECLARE @RestoreDatabase sysname = N'PensionOpsLab_RestoreTest';

-- Update these from the output of 03_restore_filelistonly.sql if necessary.
DECLARE @DataLogicalName sysname = N'PensionOpsLab';
DECLARE @LogLogicalName  sysname = N'PensionOpsLab_log';

DECLARE @FullBackupPath nvarchar(4000) = @BackupDirectory + N'\PensionOpsLab_FULL.bak';
DECLARE @DiffBackupPath nvarchar(4000) = @BackupDirectory + N'\PensionOpsLab_DIFF.bak';
DECLARE @LogBackupPath  nvarchar(4000) = @BackupDirectory + N'\PensionOpsLab_LOG.trn';

DECLARE @DataFilePath nvarchar(4000) = @DataDirectory + N'\PensionOpsLab_RestoreTest.mdf';
DECLARE @LogFilePath  nvarchar(4000) = @DataDirectory + N'\PensionOpsLab_RestoreTest_log.ldf';
DECLARE @Sql nvarchar(max);

IF DB_ID(@RestoreDatabase) IS NOT NULL
BEGIN
    THROW 50003, 'PensionOpsLab_RestoreTest already exists. Drop it manually only if you no longer need it, then rerun this restore test.', 1;
END;

SET @Sql = N'
RESTORE DATABASE ' + QUOTENAME(@RestoreDatabase) + N'
FROM DISK = N''' + REPLACE(@FullBackupPath, '''', '''''') + N'''
WITH
    MOVE N''' + REPLACE(@DataLogicalName, '''', '''''') + N''' TO N''' + REPLACE(@DataFilePath, '''', '''''') + N''',
    MOVE N''' + REPLACE(@LogLogicalName, '''', '''''') + N''' TO N''' + REPLACE(@LogFilePath, '''', '''''') + N''',
    NORECOVERY,
    CHECKSUM,
    STATS = 5;';
EXEC sys.sp_executesql @Sql;

SET @Sql = N'
RESTORE DATABASE ' + QUOTENAME(@RestoreDatabase) + N'
FROM DISK = N''' + REPLACE(@DiffBackupPath, '''', '''''') + N'''
WITH
    NORECOVERY,
    CHECKSUM,
    STATS = 5;';
EXEC sys.sp_executesql @Sql;

SET @Sql = N'
RESTORE LOG ' + QUOTENAME(@RestoreDatabase) + N'
FROM DISK = N''' + REPLACE(@LogBackupPath, '''', '''''') + N'''
WITH
    RECOVERY,
    CHECKSUM,
    STATS = 5;';
EXEC sys.sp_executesql @Sql;
GO

SELECT
    name,
    state_desc,
    recovery_model_desc,
    create_date
FROM sys.databases
WHERE name = N'PensionOpsLab_RestoreTest';
GO
