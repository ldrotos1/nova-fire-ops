# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

nova-fire-ops is a fire and rescue operations dashboard for Northern Virginia.

## Build System

Gradle 8.12 multiproject build. Use the wrapper (`./gradlew`) rather than a locally installed Gradle.

```bash
./gradlew projects          # list all subprojects
./gradlew build             # build all subprojects
./gradlew :data:tasks       # list tasks for the data subproject
```

## Subprojects

### `nova-fire-ops-data`
Not a Java project. Contains SQL schema definitions, seed/reference data, and scripts for loading data into PostgreSQL.

- `nova-fire-ops-data/sql/schema/` — DDL (table definitions, indexes)
- `nova-fire-ops-data/sql/seed/` — seed and reference data SQL
- `nova-fire-ops-data/scripts/` — scripts for loading data into PostgreSQL

## Database Setup

Run once to configure connection properties before executing any load scripts:

```bash
./gradlew setDBConnProps
```

Prompts for hostname, port, database user, and password, then writes two files to `~/.nova-fire-ops/`:

| File | Purpose |
|------|---------|
| `.pgpass` | PostgreSQL password file (`hostname:port:*:user:password`). Set `PGPASSFILE=~/.nova-fire-ops/.pgpass` so `psql` and `pg_restore` pick up credentials automatically. |
| `.dbconnprops` | Key/value properties (`db.hostname`, `db.port`, `db.user`, `db.password`) read by load scripts. |

## Notes

Future Java subprojects should apply `plugin: 'java'` in their own `build.gradle` and set a Java toolchain version. The root `build.gradle` only configures shared repositories.
