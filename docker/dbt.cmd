@echo off
for %%a in ("%~dp0\..") do set "parent=%%~nxa"
docker compose -p %parent% run --rm dbt %*