-- Verify lumberi:user_group_role on pg

BEGIN;

DO
$verify$
BEGIN
    ASSERT(SELECT has_table_privilege('lumber_dba', 'account.inventory_user',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT has_table_privilege('lumber_dba', 'account.inventory_group',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT has_table_privilege('lumber_dba', 'account.inventory_role',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT has_table_privilege('lumber_dba', 'account.inventory_user_group',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT has_table_privilege('lumber_dba', 'account.inventory_group_role',
		'insert, select, update, delete, truncate, references, trigger'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'account.inventory_user', 'select'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'account.inventory_group', 'select'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'account.inventory_role', 'select'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'account.inventory_user_group', 'select'));
    ASSERT(SELECT NOT has_table_privilege('lumber_app', 'account.inventory_group_role', 'select'));
END
$verify$;

ROLLBACK;
