-- Verify lumberi:activity on pg

BEGIN;

DO
$verify$
BEGIN
    ASSERT(SELECT has_table_privilege('lumber_dba', 'history.lumber_activity',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT has_table_privilege('lumber_dba', 'history.project_activity',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'history.lumber_activity', 'select'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'history.project_activity', 'select'));
END
$verify$;

ROLLBACK;
