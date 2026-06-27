# Evidence Capture Guide — Backup & Restore Lab

All screenshots must be taken from your local synthetic lab. Use `PensionOpsLab` and `PensionOpsLab_RestoreTest` only.

## Capture order

### 01-filelistonly-output.png

Run `03_restore_filelistonly.sql`.

**Capture:** the `LogicalName`, `PhysicalName`, and `Type` columns.

**Caption:** `Backup file metadata was reviewed before defining the restore target paths.`

### 02-full-diff-log-backups.png

Run `02_full_diff_log_backup.sql`.

**Capture:** the final result grid that groups records by `SourceStage`.

**Caption:** `Synthetic transactions were introduced at baseline, differential, and transaction-log stages to validate the restore chain.`

### 03-restore-in-progress.png

During a backup or restore, run `06_restore_progress_monitor.sql`.

**Capture:** command, percent complete, elapsed minutes, and estimated completion time.

**Caption:** `Backup/restore progress was monitored from SQL Server execution requests in the local lab.`

### 04-restored-database-online.png

Run the final query in `04_restore_to_new_database.sql`.

**Capture:** `PensionOpsLab_RestoreTest` with `ONLINE` state.

**Caption:** `The recovery chain completed and brought the restore-test database online.`

### 05-row-count-validation.png

Run the row-count section of `05_post_restore_validation.sql`.

**Capture:** all table rows with `MATCH` status.

**Caption:** `Source and restored table counts matched after recovery.`

### 06-log-row-validation.png

Run the query for `LOG-000001` and `LOG-000002`.

**Capture:** both rows.

**Caption:** `Transactions added after the differential backup were present after the transaction-log restore.`

### 07-dbcc-checkdb-result.png

Run `DBCC CHECKDB` in `05_post_restore_validation.sql`.

**Capture:** the final message output that contains no reported consistency errors.

**Caption:** `Integrity validation was run against the restored database after the recovery test.`

## Before uploading

- Crop out Windows usernames, server names, local paths, and unrelated database names if visible.
- Do not edit result values. Use synthetic data instead of redaction.
- Make the text readable at GitHub page width.
