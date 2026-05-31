# Data Engineering 2026
![dbt CI](https://github.com/dvorakinna/data-eng-2026/actions/workflows/dbt.yml/badge.svg)

End-to-end data engineering portfolio project: 
raw data → staging → analytical marts, fully tested and CI-automated.

## Stack
- **Database:** PostgreSQL 16 (local, Docker) → Snowflake (M2)
- **Transformation:** dbt Core 1.8 (models, tests, Jinja, packages)
- **CI/CD:** GitHub Actions (dbt build on every push/PR)
- **Containerization:** Docker Compose (Postgres + dbt runner)

## Project structure

```
data-eng-2026/
├── analytics/              # dbt project
│   ├── models/
│   │   ├── staging/        # 4 views — rename, cast, clean
│   │   └── marts/          # 7 tables — dims, facts, metrics
│   ├── dbt_project.yml
│   └── packages.yml        # dbt_utils
├── sql/
│   └── day_2/              # raw schema + seed data + SQL drills
├── docker/
│   ├── docker-compose.yaml # Postgres + dbt services
│   ├── Dockerfile          # dbt-core + postgres + snowflake adapters
│   └── *.cmd               # start/stop/dbt helper scripts (Windows)
├── profiles/               # dbt profiles.yml (gitignored)
└── .github/workflows/
    └── dbt.yml             # CI pipeline
```

## Data model

```
raw.* (source)
  → analytics_staging.stg_* (views: rename + cast)
    → analytics_marts.dim_* / fct_* (tables: joins + business logic)
    → analytics_marts.monthly_revenue, cohort_retention, ...
```

## Current status

| Metric     | Value                              |
|------------|------------------------------------|
| Models     | 11 (4 staging + 7 marts)           |
| Tests      | 35                                 |
| CI         | GitHub Actions — dbt build on push |
| Phase      | 1 / 5 (Snowflake, M1–M2)          |

## Local setup

```bash
cd docker
.\start.cmd                          # start Postgres
psql -h localhost -U dbt -d source -f ../sql/day_2/schema.sql
psql -h localhost -U dbt -d source -f ../sql/day_2/seed.sql
.\dbt.cmd deps
.\dbt.cmd build
```

