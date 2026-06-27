/*
    SQL Server Backup & Restore Validation Lab
    Step 5: Validate the restored database.

    Validation scope:
      - Database is ONLINE
      - Source and restored row counts match
      - The post-differential log rows exist in the restored copy
      - DBCC CHECKDB completes without reported errors
*/

USE master;
GO

IF DB_ID(N'PensionOpsLab') IS NULL OR DB_ID(N'PensionOpsLab_RestoreTest') IS NULL
BEGIN
    THROW 50004, 'Both PensionOpsLab and PensionOpsLab_RestoreTest must exist before validation.', 1;
END;

SELECT
    DatabaseName = d.name,
    DatabaseState = d.state_desc,
    RecoveryModel = d.recovery_model_desc
FROM sys.databases AS d
WHERE d.name IN (N'PensionOpsLab', N'PensionOpsLab_RestoreTest');
GO

SELECT
    TableName = 'MemberProfile',
    SourceRows = (SELECT COUNT(*) FROM PensionOpsLab.dbo.MemberProfile),
    RestoredRows = (SELECT COUNT(*) FROM PensionOpsLab_RestoreTest.dbo.MemberProfile),
    ValidationStatus = CASE
        WHEN (SELECT COUNT(*) FROM PensionOpsLab.dbo.MemberProfile)
           = (SELECT COUNT(*) FROM PensionOpsLab_RestoreTest.dbo.MemberProfile)
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END
UNION ALL
SELECT
    TableName = 'ContributionTransaction',
    SourceRows = (SELECT COUNT(*) FROM PensionOpsLab.dbo.ContributionTransaction),
    RestoredRows = (SELECT COUNT(*) FROM PensionOpsLab_RestoreTest.dbo.ContributionTransaction),
    ValidationStatus = CASE
        WHEN (SELECT COUNT(*) FROM PensionOpsLab.dbo.ContributionTransaction)
           = (SELECT COUNT(*) FROM PensionOpsLab_RestoreTest.dbo.ContributionTransaction)
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END
UNION ALL
SELECT
    TableName = 'LabRunLog',
    SourceRows = (SELECT COUNT(*) FROM PensionOpsLab.dbo.LabRunLog),
    RestoredRows = (SELECT COUNT(*) FROM PensionOpsLab_RestoreTest.dbo.LabRunLog),
    ValidationStatus = CASE
        WHEN (SELECT COUNT(*) FROM PensionOpsLab.dbo.LabRunLog)
           = (SELECT COUNT(*) FROM PensionOpsLab_RestoreTest.dbo.LabRunLog)
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END;
GO

SELECT
    SourceStage,
    TransactionCount = COUNT(*),
    TotalAmount = SUM(Amount)
FROM PensionOpsLab_RestoreTest.dbo.ContributionTransaction
GROUP BY SourceStage
ORDER BY SourceStage;
GO

-- Expected to return two rows: LOG-000001 and LOG-000002.
SELECT
    ReferenceNo,
    FundId,
    ValueDate,
    Amount,
    SourceStage
FROM PensionOpsLab_RestoreTest.dbo.ContributionTransaction
WHERE ReferenceNo IN (N'LOG-000001', N'LOG-000002')
ORDER BY ReferenceNo;
GO

DBCC CHECKDB (N'PensionOpsLab_RestoreTest') WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO
