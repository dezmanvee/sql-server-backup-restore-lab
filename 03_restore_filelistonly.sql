/*
    SQL Server Backup & Restore Validation Lab
    Step 3: Inspect the full backup before writing the restore command.

    Use the LogicalName values returned by RESTORE FILELISTONLY in Step 4.
*/

DECLARE @FullBackupPath nvarchar(4000) = N'C:\SQLBackups\DbaPortfolioLab\PensionOpsLab_FULL.bak';
DECLARE @Sql nvarchar(max);

SET @Sql = N'RESTORE FILELISTONLY FROM DISK = N''' + REPLACE(@FullBackupPath, '''', '''''') + N''';';
EXEC sys.sp_executesql @Sql;
GO

-- Optional: inspect backup metadata, including backup type and LSN information.
DECLARE @FullBackupPath nvarchar(4000) = N'C:\SQLBackups\DbaPortfolioLab\PensionOpsLab_FULL.bak';
DECLARE @Sql nvarchar(max);

SET @Sql = N'RESTORE HEADERONLY FROM DISK = N''' + REPLACE(@FullBackupPath, '''', '''''') + N''';';
EXEC sys.sp_executesql @Sql;
GO
