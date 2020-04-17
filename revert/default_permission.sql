-- Revert lumberi:default_permission from pg

BEGIN;

ALTER DEFAULT PRIVILEGES FOR ROLE lumber_dba REVOKE USAGE ON SCHEMAS FROM lumber_app;

COMMIT;
