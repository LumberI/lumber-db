-- Revert lumber-global:roles from pg

BEGIN;

DROP USER IF EXISTS lumber_inventory;
DROP USER IF EXISTS lumber_admin;
DROP ROLE IF EXISTS lumber_app;
DROP ROLE IF EXISTS lumber_dba;

COMMIT;
