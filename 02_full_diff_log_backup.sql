/*
    SQL Server Backup & Restore Validation Lab
    Step 2: Create a full backup, differential backup, and transaction log backup.

    Before running:
      - Create the folder in @BackupDirectory.
      - Confirm the SQL Server service account can write to that location.
*/

USE master;
GO

DECLARE @BackupDirectory nvarchar(260) = N'C:\SQLBackups\DbaPortfolioLab';
DECLARE @Sql nvarchar(max);

DECLARE @FullBackupPath nvarchar(4000) = @BackupDirectory + N'\PensionOpsLab_FULL.bak';
DECLARE @DiffBackupPath nvarchar(4000) = @BackupDirectory + N'\PensionOpsLab_DIFF.bak';
DECLARE @LogBackupPath  nvarchar(4000) = @BackupDirectory + N'\PensionOpsLab_LOG.trn';

IF DB_ID(N'PensionOpsLab') IS NULL
BEGIN
    THROW 50002, 'PensionOpsLab does not exist. Run 01_create_backup_restore_lab.sql first.', 1;
END;

-- Full backup: creates the base of the recovery chain.
SET @Sql = N'
BACKUP DATABASE PensionOpsLab
TO DISK = N''' + REPLACE(@FullBackupPath, '''', '''''') + N'''
WITH INIT, CHECKSUM, STATS = 5,
     NAME = N''PensionOpsLab full backup for DBA portfolio lab'';';
EXEC sys.sp_executesql @Sql;
GO

USE PensionOpsLab;
GO

-- Changes made after the full backup will be included in the differential backup.
INSERT dbo.ContributionTransaction
(
    MemberId, FundId, ValueDate, Amount, SourceStage, ReferenceNo
)
VALUES
    (1, '001', CAST(GETDATE() AS date), 150000.00, 'DIFFERENTIAL', 'DIFF-000001'),
    (2, '002', CAST(GETDATE() AS date), 175000.00, 'DIFFERENTIAL', 'DIFF-000002'),
    (3, '003', CAST(GETDATE() AS date), 200000.00, 'DIFFERENTIAL', 'DIFF-000003');

INSERT dbo.LabRunLog (EventName, Notes)
VALUES ('DIFFERENTIAL DATA INSERTED', 'Three synthetic transactions inserted after the full backup.');
GO

USE master;
GO

DECLARE @BackupDirectory nvarchar(260) = N'C:\SQLBackups\DbaPortfolioLab';
DECLARE @DiffBackupPath nvarchar(4000) = @BackupDirectory + N'\PensionOpsLab_DIFF.bak';
DECLARE @Sql nvarchar(max);

SET @Sql = N'
BACKUP DATABASE PensionOpsLab
TO DISK = N''' + REPLACE(@DiffBackupPath, '''', '''''') + N'''
WITH DIFFERENTIAL, INIT, CHECKSUM, STATS = 5,
     NAME = N''PensionOpsLab differential backup for DBA portfolio lab'';';
EXEC sys.sp_executesql @Sql;
GO

USE PensionOpsLab;
GO

-- Changes made after the differential backup will be included in the log backup.
INSERT dbo.ContributionTransaction
(
    MemberId, FundId, ValueDate, Amount, SourceStage, ReferenceNo
)
VALUES
    (4, '001', CAST(GETDATE() AS date), 225000.00, 'TRANSACTION_LOG', 'LOG-000001'),
    (5, '002', CAST(GETDATE() AS date), 250000.00, 'TRANSACTION_LOG', 'LOG-000002');

INSERT dbo.LabRunLog (EventName, Notes)
VALUES ('LOG DATA INSERTED', 'Two synthetic transactions inserted after the differential backup.');
GO

USE master;
GO

DECLARE @BackupDirectory nvarchar(260) = N'C:\SQLBackups\DbaPortfolioLab';
DECLARE @LogBackupPath nvarchar(4000) = @BackupDirectory + N'\PensionOpsLab_LOG.trn';
DECLARE @Sql nvarchar(max);

SET @Sql = N'
BACKUP LOG PensionOpsLab
TO DISK = N''' + REPLACE(@LogBackupPath, '''', '''''') + N'''
WITH INIT, CHECKSUM, STATS = 5,
     NAME = N''PensionOpsLab transaction log backup for DBA portfolio lab'';';
EXEC sys.sp_executesql @Sql;
GO

USE PensionOpsLab;
GO

SELECT
    SourceStage,
    TransactionCount = COUNT(*),
    TotalAmount = SUM(Amount)
FROM dbo.ContributionTransaction
GROUP BY SourceStage
ORDER BY SourceStage;
GO
