# Oracle Environment

This document describes the Oracle environment used throughout **SQL-Engineering-Lab**.

The environment documented here is the actual Oracle environment used to develop, test, and verify every lesson in this repository.

Whenever the Oracle environment changes, this document should be updated accordingly.

---

# Environment Summary

| Item | Value |
|------|-------|
| Database Product | Oracle Database 23ai Free |
| Database Version | 23.6.0.24.10 |
| Operating System | Windows |
| Host Name | TOSHIYUKI_PC |
| Database Name (CDB) | FREE |
| Learning PDB | FREEPDB1 |
| SQL Client | SQL*Plus |
| GUI Client | Oracle SQL Developer |
| Character Set | AL32UTF8 |
| NCHAR Character Set | AL16UTF16 |

---

# Database Architecture

```
Oracle Database Free (23ai)

└── Container Database (FREE)
    ├── PDB$SEED
    ├── FREEPDB1   ← SQL-Engineering-Lab
```

The **FREEPDB1** pluggable database is used throughout SQL-Engineering-Lab.

---

# Container Databases

| Container | Status | Purpose |
|-----------|--------|---------|
| CDB$ROOT | READ WRITE | Root Container |
| PDB$SEED | READ ONLY | Template Database |
| FREEPDB1 | READ WRITE | SQL-Engineering-Lab |

---

# Learning Users

| User | Purpose | Status |
|------|---------|--------|
| FREEPDB1ADMIN | Administrative User | ✅ Active |
| FREEPDB1USER01 | Existing Learning User | ✅ Active |
| SQL_LAB | Dedicated Course User | 📅 Planned |

---

# Learning Schemas

| Schema | Purpose | Status |
|---------|---------|--------|
| FREEPDB1ADMIN | Administration | ✅ |
| FREEPDB1USER01 | Existing Exercises | ✅ |
| SQL_LAB | SQL-Engineering-Lab Exercises | 📅 Planned |

---

# Tablespaces

| Tablespace | Purpose | Status |
|------------|---------|--------|
| SYSTEM | System Objects | Oracle Managed |
| SYSAUX | Auxiliary System Objects | Oracle Managed |
| TEMP | Temporary Objects | Oracle Managed |
| UNDOTBS1 | Undo Data | Oracle Managed |
| USERS | Default User Tablespace | Oracle Managed |
| FREEPDB1_DATA | Learning Objects | ✅ In Use |

---

# SQL Clients

The following SQL clients are used throughout this repository.

| Tool | Status |
|------|--------|
| SQL*Plus | ✅ |
| Oracle SQL Developer | ✅ |

---

# Existing Database Objects

The following objects currently exist in the learning environment.

## FREEPDB1ADMIN

| Object Type | Count |
|-------------|------:|
| Sequence | 1 |

---

## FREEPDB1USER01

| Object Type | Count |
|-------------|------:|
| Tables | 4 |
| Indexes | 4 |
| Sequences | 1 |

Current tables:

- RESERVATIONS
- SHOPS
- SPORTS_MASTER
- SPORT_CATEGORY_MASTER

These objects were created before the SQL-Engineering-Lab project and are retained for personal learning purposes.

---

# Planned Components

The following components will be added as the repository grows.

## Users

- SQL_LAB

---

## Schemas

- SQL_LAB

---

## Sample Databases

- Environment Check Database
- Book Store Database

---

## Sample Objects

- Sample Tables
- Sample Views
- Sample Sequences
- Sample Indexes

---

## Engineering Objects

- Execution Plan Examples
- Performance Test Tables
- SQL Tuning Examples

---

# Repository Usage

The Oracle environment is organized as follows.

| Environment | Purpose |
|-------------|---------|
| FREEPDB1 | SQL-Engineering-Lab |

Whenever possible, all lessons in this repository should be verified using the environment described in this document.

---

# Environment Verification

The Oracle environment can be verified by executing:

```text
scripts/oracle_environment.sql
```

The output of this script should match the information described in this document.

---

# Change History

| Date | Description |
|------|-------------|
| 2026-07-26 | Initial environment inventory created. |
