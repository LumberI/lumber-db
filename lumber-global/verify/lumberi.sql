-- Verify lumber-global:lumberi on pg

BEGIN;

DO
$verify$
BEGIN
    ASSERT(SELECT has_database_privilege('lumber_dba', 'lumberi', 'create'));
    ASSERT(SELECT has_database_privilege('lumber_app', 'lumberi', 'connect'));
END
$verify$;

ROLLBACK;
