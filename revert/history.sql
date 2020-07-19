-- Revert lumberi:history from pg

BEGIN;

DROP SCHEMA IF EXISTS history;

COMMIT;
