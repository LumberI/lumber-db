-- Verify lumberi:history on pg

BEGIN;

DO
$verify$
BEGIN
	ASSERT(SELECT has_schema_privilege('lumber_dba', 'history', 'create'));
	ASSERT(SELECT has_schema_privilege('lumber_app', 'history', 'usage'));
END
$verify$;

ROLLBACK;
