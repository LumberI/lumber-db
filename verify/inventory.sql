-- Verify lumberi:inventory on pg

BEGIN;

DO
$verify$
BEGIN
	ASSERT(SELECT has_schema_privilege('lumber_dba', 'inventory', 'create'));
	ASSERT(SELECT has_schema_privilege('lumber_app', 'inventory', 'usage'));
END
$verify$;

ROLLBACK;
