-- Verify lumberi:account on pg

BEGIN;

DO
$verify$
BEGIN
	ASSERT(SELECT has_schema_privilege('lumber_dba', 'account', 'create'));
	ASSERT(SELECT has_schema_privilege('lumber_app', 'account', 'usage'));
END
$verify$;

ROLLBACK;
