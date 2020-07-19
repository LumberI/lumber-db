-- Revert lumberi:activity from pg

BEGIN;

DROP TABLE IF EXISTS history.project_activity;
DROP TABLE IF EXISTS history.lumber_activity;

COMMIT;
