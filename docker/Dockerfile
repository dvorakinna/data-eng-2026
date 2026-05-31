FROM python:3.11-slim

WORKDIR /usr/app/dbt

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    "dbt-core==1.8.*" \
    "dbt-postgres==1.8.*" \
    "dbt-snowflake==1.8.*"

ENTRYPOINT ["dbt"]