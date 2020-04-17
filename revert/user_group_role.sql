-- Revert lumberi:user_group_role from pg

BEGIN;

DROP TABLE IF EXISTS account.inventory_group_role;
DROP TABLE IF EXISTS account.inventory_user_group;
DROP TABLE IF EXISTS account.inventory_role;
DROP TABLE IF EXISTS account.inventory_group;
DROP TABLE IF EXISTS account.inventory_user;

COMMIT;
