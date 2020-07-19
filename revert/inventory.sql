-- Revert lumberi:inventory from pg

BEGIN;

DROP SCHEMA IF EXISTS inventory;

COMMIT;
