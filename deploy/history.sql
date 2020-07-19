-- Deploy lumberi:history to pg
-- requires: default_permission

BEGIN;

CREATE SCHEMA IF NOT EXISTS history
    AUTHORIZATION lumber_dba;

COMMIT;
