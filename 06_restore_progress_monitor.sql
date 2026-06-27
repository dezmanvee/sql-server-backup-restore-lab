/*
    SQL Server Backup & Restore Validation Lab
    Optional: monitor active BACKUP or RESTORE progress.

    Permission note:
      Requires permission to view server-level execution requests.
*/

SELECT
    r.session_id,
    r.command,
    DatabaseName = DB_NAME(r.database_id),
    r.start_time,
    PercentComplete = CAST(r.percent_complete AS decimal(6,2)),
    ElapsedMinutes = CAST(r.total_elapsed_time / 60000.0 AS decimal(18,2)),
    EstimatedMinutesRemaining = CAST(r.estimated_completion_time / 60000.0 AS decimal(18,2)),
    EstimatedCompletionTime = DATEADD(MILLISECOND, r.estimated_completion_time, GETDATE()),
    r.wait_type,
    r.last_wait_type
FROM sys.dm_exec_requests AS r
WHERE r.command IN ('BACKUP DATABASE', 'BACKUP LOG', 'RESTORE DATABASE', 'RESTORE LOG')
ORDER BY r.start_time;
GO
