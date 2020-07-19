-- Revert lumberi:lumber_project from pg

BEGIN;

DROP TABLE IF EXISTS inventory.lumber;
DROP TABLE IF EXISTS inventory.user_project;
DROP TABLE IF EXISTS inventory.work_log;
DROP TABLE IF EXISTS inventory.lumber_project;
DROP TABLE IF EXISTS inventory.lumber_type;

COMMIT;
