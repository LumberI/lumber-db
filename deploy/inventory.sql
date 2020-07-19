-- Deploy lumberi:inventory to pg
-- requires: default_permission

BEGIN;

CREATE SCHEMA IF NOT EXISTS inventory
    AUTHORIZATION lumber_dba;

COMMIT;
