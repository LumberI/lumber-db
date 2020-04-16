-- Verify lumber-global:roles on pg

BEGIN;

DO
$verify$
BEGIN
    PERFORM has_database_privilege('lumber_dba', 'postgres', 'connect');
    PERFORM has_database_privilege('lumber_app', 'postgres', 'connect');
    PERFORM has_database_privilege('lumber_admin', 'postgres', 'connect');
    PERFORM has_database_privilege('lumber_inventory', 'postgres', 'connect');
END
$verify$;

ROLLBACK;
