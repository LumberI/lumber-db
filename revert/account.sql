-- Revert lumberi:account from pg

BEGIN;

DROP SCHEMA IF EXISTS account;

COMMIT;
