/*
    SQL Server Backup & Restore Validation Lab
    Step 1: Create a synthetic database and seed fictional pension-style data.

    Safety:
      - Creates a new database named PensionOpsLab.
      - Stops if the database already exists.
*/

USE master;
GO

IF DB_ID(N'PensionOpsLab') IS NOT NULL
BEGIN
    THROW 50001, 'PensionOpsLab already exists. Drop or rename the existing lab database manually before rerunning this script.', 1;
END;
GO

CREATE DATABASE PensionOpsLab;
GO

ALTER DATABASE PensionOpsLab SET RECOVERY FULL;
GO

USE PensionOpsLab;
GO

CREATE TABLE dbo.MemberProfile
(
    MemberId        int IDENTITY(1,1) NOT NULL CONSTRAINT PK_MemberProfile PRIMARY KEY,
    PIN             varchar(12) NOT NULL CONSTRAINT UQ_MemberProfile_PIN UNIQUE,
    Surname         varchar(50) NOT NULL,
    FirstName       varchar(50) NOT NULL,
    DateJoined      date NOT NULL,
    MemberStatus    varchar(20) NOT NULL,
    CreatedAt       datetime2(0) NOT NULL CONSTRAINT DF_MemberProfile_CreatedAt DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.ContributionTransaction
(
    ContributionId  bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_ContributionTransaction PRIMARY KEY,
    MemberId        int NOT NULL,
    FundId          varchar(3) NOT NULL,
    ValueDate       date NOT NULL,
    Amount          decimal(18,2) NOT NULL,
    SourceStage     varchar(30) NOT NULL,
    ReferenceNo     varchar(40) NOT NULL CONSTRAINT UQ_ContributionTransaction_ReferenceNo UNIQUE,
    CreatedAt       datetime2(0) NOT NULL CONSTRAINT DF_ContributionTransaction_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_ContributionTransaction_MemberProfile
        FOREIGN KEY (MemberId) REFERENCES dbo.MemberProfile(MemberId)
);
GO

CREATE TABLE dbo.LabRunLog
(
    LabRunLogId     int IDENTITY(1,1) NOT NULL CONSTRAINT PK_LabRunLog PRIMARY KEY,
    EventName       varchar(100) NOT NULL,
    EventTime       datetime2(0) NOT NULL CONSTRAINT DF_LabRunLog_EventTime DEFAULT SYSDATETIME(),
    Notes           varchar(300) NULL
);
GO

;WITH Numbers AS
(
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
)
INSERT dbo.MemberProfile (PIN, Surname, FirstName, DateJoined, MemberStatus)
SELECT
    CONCAT('PEN', RIGHT(CONCAT('000000000', n), 9)),
    CONCAT('Member', n),
    CONCAT('Test', n),
    DATEADD(DAY, -n, CAST(GETDATE() AS date)),
    CASE WHEN n % 10 = 0 THEN 'INACTIVE' ELSE 'ACTIVE' END
FROM Numbers;
GO

;WITH Numbers AS
(
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
)
INSERT dbo.ContributionTransaction
(
    MemberId,
    FundId,
    ValueDate,
    Amount,
    SourceStage,
    ReferenceNo
)
SELECT
    ((n - 1) % 100) + 1,
    RIGHT(CONCAT('00', ((n - 1) % 3) + 1), 3),
    DATEADD(DAY, -((n - 1) % 365), CAST(GETDATE() AS date)),
    CAST(10000 + ((n % 25) * 2500) AS decimal(18,2)),
    'BASELINE',
    CONCAT('BASE-', RIGHT(CONCAT('000000', n), 6))
FROM Numbers;
GO

INSERT dbo.LabRunLog (EventName, Notes)
VALUES ('LAB CREATED', 'Synthetic member and contribution records created for backup and restore validation.');
GO

CHECKPOINT;
GO

SELECT
    DatabaseName = DB_NAME(),
    RecoveryModel = d.recovery_model_desc,
    MemberCount = (SELECT COUNT(*) FROM dbo.MemberProfile),
    ContributionCount = (SELECT COUNT(*) FROM dbo.ContributionTransaction),
    CreatedAt = SYSDATETIME()
FROM sys.databases AS d
WHERE d.name = DB_NAME();
GO
