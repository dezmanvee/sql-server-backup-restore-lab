# Case Study: Restore-Test Validation of a SQL Server Backup Chain

## Problem

A successful backup job does not by itself prove that a database can be recovered within an acceptable process. A DBA must validate the backup chain, restore order, file placement, database state, and data/integrity checks.

## Lab design

A synthetic `PensionOpsLab` database is created in FULL recovery model. The lab introduces changes at three points:

1. **Baseline data** before the full backup.
2. **Differential rows** inserted after the full backup.
3. **Log rows** inserted after the differential backup.

The restore sequence must be:

```text
Full backup WITH NORECOVERY
→ Differential backup WITH NORECOVERY
→ Transaction log backup WITH RECOVERY
```

The destination is `PensionOpsLab_RestoreTest`, not the source database.

## Validation evidence

| Image | Why it matters |
|---|---|
| `01-filelistonly-output.png` | Shows that logical file names were checked before writing `MOVE` clauses. |
| `02-full-diff-log-backups.png` | Shows the backup chain was produced in the lab. |
| `03-restore-in-progress.png` | Shows controlled restore activity and progress monitoring. |
| `04-restored-database-online.png` | Shows the restored database is online. |
| `05-row-count-validation.png` | Shows source and restored row counts match. |
| `06-log-row-validation.png` | Confirms changes made after the differential backup were recovered. |
| `07-dbcc-checkdb-result.png` | Shows integrity validation after recovery. |

## Result statement for the README

> The lab restored a synthetic SQL Server database from a full backup, a differential backup, and a transaction-log backup into a separate restore-test database. Post-restore checks confirmed that the destination database was online, the row counts matched the source, the final log-backed-up transactions were present, and `DBCC CHECKDB` completed without reported errors.

Use this statement only after you have run the lab and captured the matching evidence.

## Lessons demonstrated

- A restore plan begins with inspecting the backup set and file metadata.
- Restore order matters.
- `NORECOVERY` keeps the database ready for the next restore in the chain.
- A safe restore test avoids overwriting the source database.
- Validation includes database state, critical records, row counts, and integrity checks.
