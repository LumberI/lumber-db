-- Deploy lumberi:default_permission to pg

BEGIN;

DO
$verify$
BEGIN
    PERFORM has_database_privilege('lumber_dba', 'postgres', 'connect');
    PERFORM has_database_privilege('lumber_app', 'postgres', 'connect');
END
$verify$;

ALTER DEFAULT PRIVILEGES
FOR ROLE lumber_dba
GRANT USAGE ON SCHEMAS TO lumber_app;

COMMIT;
