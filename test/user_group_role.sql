BEGIN;
CREATE EXTENSION IF NOT EXISTS pgtap;
SELECT plan(21);

--setup for tests
set client_min_messages = WARNING;
TRUNCATE account.inventory_user RESTART IDENTITY CASCADE;
TRUNCATE account.inventory_group RESTART IDENTITY CASCADE;
TRUNCATE account.inventory_role RESTART IDENTITY CASCADE;

-- inventory_user tests
SELECT lives_ok(
    $$ INSERT INTO account.inventory_user (login_id, password,
		full_name, preferred_name, email, is_active, created_time)
       VALUES ('admin', 'admin', 'admin', 'user', NULL, true, now()),
	   ('alexdoe', 'alex123', 'alex', 'doe', 'alex@inventory.com', true, now()),
	   ('johndoe', 'john123', 'john', 'doe', 'john@inventory.com', true, now()),
	   ('foobar', 'foo123', 'foo', 'bar', 'foo@bar.com', false, now()),
	   ('foobaz', 'foo123', 'foo', 'baz', NULL, false, now()) $$,
    'Insert users'
);
SELECT throws_ok(
    $$ INSERT INTO account.inventory_user (login_id, password,
		full_name, preferred_name, email, is_active, created_time)
       VALUES ('admin', 'administrator', 'ad', 'login', NULL, true, now()) $$,
    '23505', NULL, 'Insert duplicate user login_id should throw'
);
SELECT throws_ok(
    $$ INSERT INTO account.inventory_user (login_id, password,
		full_name, preferred_name, email, is_active, created_time)
       VALUES ('fooboo', 'boo123', 'foo', 'boo', 'foo@bar.com', true, now()) $$,
    '23505', NULL, 'Insert duplicate user email should throw'
);
SELECT results_eq(
    $$ SELECT id, login_id, password, full_name, preferred_name, email, is_active
       FROM account.inventory_user
       ORDER BY id $$,
    $$ VALUES (1::bigint, 'admin', 'admin', 'admin', 'user', NULL::text, true),
	(2::bigint, 'alexdoe', 'alex123', 'alex', 'doe', 'alex@inventory.com', true),
	(3::bigint, 'johndoe', 'john123', 'john', 'doe', 'john@inventory.com', true),
	(4::bigint, 'foobar', 'foo123', 'foo', 'bar', 'foo@bar.com', false),
	(5::bigint, 'foobaz', 'foo123', 'foo', 'baz', NULL::text, false) $$,
    'verify inserted users'
);

-- inventory_group tests
SELECT lives_ok(
    $$ INSERT INTO account.inventory_group (name, description, is_active, created_time)
       VALUES ('admin', NULL, true, now()),
	   ('operator', NULL, true, now()),
	   ('technician', 'reefer repair tech', true, now()),
	   ('foo', NULL, false, now()),
	   ('bar', 'foo bar baz', false, now()) $$,
    'Insert groups'
);
SELECT throws_ok(
    $$ INSERT INTO account.inventory_group (name, description, is_active, created_time)
       VALUES ('technician', 'reefer service team', true, now()) $$,
    '23505', NULL, 'Insert duplicate group name should throw'
);
SELECT results_eq(
    $$ SELECT id, name, description, is_active
       FROM account.inventory_group
       ORDER BY id $$,
    $$ VALUES (1::bigint, 'admin', NULL::text, true),
	(2::bigint, 'operator', NULL::text, true),
	(3::bigint, 'technician', 'reefer repair tech', true),
	(4::bigint, 'foo', NULL::text, false),
	(5::bigint, 'bar', 'foo bar baz', false) $$,
    'verify inserted groups'
);

-- inventory_role tests
SELECT lives_ok(
    $$ INSERT INTO account.inventory_role (id, name)
       VALUES (1, 'admin'), (2, 'readonly'), (3, 'remote-operation') $$,
    'Insert roles'
);
SELECT throws_ok(
    $$ INSERT INTO account.inventory_role (id, name)
       VALUES (4, 'readonly') $$,
    '23505', NULL, 'Insert duplicate role name should throw'
);
SELECT results_eq(
    $$ SELECT id, name
       FROM account.inventory_role
       ORDER BY id $$,
    $$ VALUES (1, 'admin'),
	(2, 'readonly'),
	(3, 'remote-operation') $$,
    'verify inserted roles'
);

-- inventory_user_group tests
SELECT lives_ok(
    $$ INSERT INTO account.inventory_user_group
       VALUES (1, 1), (2, 3), (3, 2), (3, 3), (4, 4), (4, 5), (5, 4) $$,
    'Insert user-group relationships'
);
SELECT throws_ok(
    $$ INSERT INTO account.inventory_user_group
       VALUES (6, 2) $$,
    '23503', NULL, 'Insert non-existing user should throw'
);
SELECT throws_ok(
    $$ INSERT INTO account.inventory_user_group
       VALUES (3, 6) $$,
    '23503', NULL, 'Insert non-existing group should throw'
);

-- inventory_group_role tests
SELECT lives_ok(
    $$ INSERT INTO account.inventory_group_role
       VALUES (1, 1), (2, 2), (3, 2), (3, 3) $$,
    'Insert group-role relationships'
);
SELECT throws_ok(
    $$ INSERT INTO account.inventory_group_role
       VALUES (6, 3) $$,
    '23503', NULL, 'Insert non-existing group should throw'
);
SELECT throws_ok(
    $$ INSERT INTO account.inventory_group_role
       VALUES (2, 4) $$,
    '23503', NULL, 'Insert non-existing role should throw'
);

-- user-group-role tests
SELECT lives_ok(
    $$ DELETE FROM account.inventory_user
       WHERE id = 5 $$,
    'Delete user'
);
SELECT lives_ok(
    $$ DELETE FROM account.inventory_group
       WHERE id = 3 $$,
    'Delete group'
);
SELECT lives_ok(
    $$ DELETE FROM account.inventory_role
       WHERE id = 1 $$,
    'Delete group'
);
SELECT results_eq(
    $$ SELECT * FROM account.inventory_user_group
       ORDER BY user_id, group_id $$,
    $$ VALUES (1::bigint, 1::bigint), (3::bigint, 2::bigint),
		(4::bigint, 4::bigint), (4::bigint, 5::bigint) $$,
    'verify updated user-group relationships'
);
SELECT results_eq(
    $$ SELECT * FROM account.inventory_group_role
       ORDER BY group_id, role_id $$,
    $$ VALUES (2::bigint, 2) $$,
    'verify updated group-role relationships'
);


SELECT * FROM finish();
ROLLBACK;
