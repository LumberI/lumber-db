-- Deploy lumberi:account to pg
-- requires: default_permission

BEGIN;

CREATE SCHEMA IF NOT EXISTS account
    AUTHORIZATION lumber_dba;

COMMIT;
