# SQL Server Backup & Restore Validation Lab

A reproducible SQL Server lab that demonstrates a complete recovery chain:

```text
Full backup → Differential backup → Transaction log backup → Restore to a new database → Validation
```

The lab uses only a synthetic database named `PensionOpsLab`. It is designed to demonstrate recovery thinking without exposing production data.

> **Safety:** Review all paths before execution. Run only on a local lab or an authorised non-production SQL Server instance. The restore script intentionally refuses to overwrite an existing database.

## What this lab demonstrates

- Creating a controlled database with fictional pension-style member and contribution data.
- Switching the lab database to FULL recovery model.
- Creating full, differential, and transaction-log backups.
- Inspecting backup logical file names with `RESTORE FILELISTONLY`.
- Restoring the chain to a different database name and file location.
- Validating data consistency, database state, and integrity after recovery.

## Run sequence

| Order | Script | Purpose |
|---|---|---|
| 1 | `01_create_backup_restore_lab.sql` | Create `PensionOpsLab` and seed synthetic data. |
| 2 | `02_full_diff_log_backup.sql` | Create full, differential, and log backups. |
| 3 | `03_restore_filelistonly.sql` | Identify logical file names and inspect the backup set. |
| 4 | `04_restore_to_new_database.sql` | Restore to `PensionOpsLab_RestoreTest`. |
| 5 | `05_post_restore_validation.sql` | Compare source and restored data and run `DBCC CHECKDB`. |
| 6 | `06_restore_progress_monitor.sql` | Optional: monitor a long-running backup or restore. |

## Before you run it

1. Create these two local folders, or change the variables in the scripts:

```text
C:\SQLBackups\DbaPortfolioLab
C:\SQLData\DbaPortfolioLab
```

2. Confirm that the SQL Server service account can write to both folders.
3. Run the scripts in the sequence above.
4. Capture screenshots using [`docs/images/README.md`](docs/images/README.md).

## Recovery design decision

This repository restores to a new database named `PensionOpsLab_RestoreTest` rather than overwriting the source database. That gives a safer demonstration of a restore test and makes validation easier.

`RESTORE VERIFYONLY` is useful for checking whether a backup set is readable, but it is **not a substitute for an actual restore test**. A real restore test validates the recovery procedure, file placement, access, database state, and post-restore checks.

## Evidence checklist

See [`docs/CASE_STUDY.md`](docs/CASE_STUDY.md) and [`docs/images/README.md`](docs/images/README.md).

## Repository structure

```text
.
├── README.md
├── 01_create_backup_restore_lab.sql
├── 02_full_diff_log_backup.sql
├── 03_restore_filelistonly.sql
├── 04_restore_to_new_database.sql
├── 05_post_restore_validation.sql
├── 06_restore_progress_monitor.sql
└── docs
    ├── CASE_STUDY.md
    └── images
        └── README.md
```
