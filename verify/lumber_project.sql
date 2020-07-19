-- Verify lumberi:lumber_project on pg

BEGIN;

DO
$verify$
BEGIN
    ASSERT(SELECT has_table_privilege('lumber_dba', 'inventory.lumber_type',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT has_table_privilege('lumber_dba', 'inventory.lumber_project',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT has_table_privilege('lumber_dba', 'inventory.work_log',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT has_table_privilege('lumber_dba', 'inventory.user_project',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT has_table_privilege('lumber_dba', 'inventory.lumber',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'inventory.lumber_type', 'select'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'inventory.lumber_project', 'select'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'inventory.work_log', 'select'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'inventory.user_project', 'select'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'inventory.lumber', 'select'));
END
$verify$;

ROLLBACK;
