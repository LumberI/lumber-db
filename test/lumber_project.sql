BEGIN;
CREATE EXTENSION IF NOT EXISTS pgtap;
SELECT plan(28);

--setup for tests
set client_min_messages = WARNING;
TRUNCATE inventory.lumber RESTART IDENTITY CASCADE;
TRUNCATE inventory.user_project RESTART IDENTITY CASCADE;
TRUNCATE inventory.work_log RESTART IDENTITY CASCADE;
TRUNCATE inventory.lumber_project RESTART IDENTITY CASCADE;
TRUNCATE inventory.lumber_type RESTART IDENTITY CASCADE;
TRUNCATE account.inventory_user RESTART IDENTITY CASCADE;

-- insert users
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

-- lumber_type tests
SELECT lives_ok(
    $$ INSERT INTO inventory.lumber_type (id, name)
       VALUES (1, 'maple'),
	   (2, 'oakwood'),
	   (3, 'walnut'),
	   (4, 'balsa'),
	   (5, 'ashwood') $$,
    'Insert lumber types'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.lumber_type (id, name)
       VALUES (6, 'walnut') $$,
    '23505', NULL, 'Insert duplicate type should throw'
);
SELECT results_eq(
    $$ SELECT id, name
       FROM inventory.lumber_type
       ORDER BY id $$,
    $$ VALUES (1::smallint, 'maple'),
	(2::smallint, 'oakwood'),
	(3::smallint, 'walnut'),
	(4::smallint, 'balsa'),
	(5::smallint, 'ashwood') $$,
    'verify inserted lumber types'
);

-- lumber_project tests
SELECT lives_ok(
    $$ INSERT INTO inventory.lumber_project (name, creator_id, cost, board_feet,
    cost_per_board_foot, create_time, schedule)
       VALUES ('table', 1, 252.15::numeric, 219, 1.1514::numeric, now(), '[2020-05-25,2020-08-05]'::tstzrange),
	   ('chair1', 1, 52.15::numeric, 45, 1.1589::numeric, now(), NULL),
	   ('chair2', 1, 52.15::numeric, 45, 1.1589::numeric, now(), NULL),
	   ('cutting board', 2, 18.15::numeric, 15, 1.21::numeric, now(), '[2020-06-03,2020-06-04]'::tstzrange),
	   ('stand', 2, 32.15::numeric, 28, 1.1482::numeric, now(), NULL) $$,
    'Insert lumber projects'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.lumber_project (name, creator_id, cost, board_feet,
    cost_per_board_foot, create_time, schedule)
       VALUES ('table', 1, 450::numeric, 225, 2::numeric, now(), NULL) $$,
    '23505', NULL, 'Insert duplicate name should throw'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.lumber_project (name, creator_id, cost, board_feet,
    cost_per_board_foot, create_time, schedule)
       VALUES ('closet', 6, 1500::numeric, 1000, 1.5::numeric, now(), NULL) $$,
    '23503', NULL, 'Insert non-existing user should throw'
);
SELECT results_eq(
    $$ SELECT id, name, creator_id, cost, board_feet, cost_per_board_foot, schedule
       FROM inventory.lumber_project
       ORDER BY id $$,
    $$ VALUES (1::bigint, 'table', 1::bigint, 252.15::numeric, 219, 1.1514::numeric, '[2020-05-25,2020-08-05]'::tstzrange),
	(2::bigint, 'chair1', 1::bigint, 52.15::numeric, 45, 1.1589::numeric, NULL::tstzrange),
	(3::bigint, 'chair2', 1::bigint, 52.15::numeric, 45, 1.1589::numeric, NULL::tstzrange),
	(4::bigint, 'cutting board', 2::bigint, 18.15::numeric, 15, 1.21::numeric, '[2020-06-03,2020-06-04]'::tstzrange),
	(5::bigint, 'stand', 2::bigint, 32.15::numeric, 28, 1.1482::numeric, NULL::tstzrange) $$,
    'verify inserted lumber projects'
);

-- work_log tests
SELECT lives_ok(
    $$ INSERT INTO inventory.work_log (project_id, logger_id, work_time, description)
       VALUES (1, 1, '02:17:28', 'cut pieces to right size'),
	   (1, 3, '01:25:55', 'assembled pieces'),
	   (1, 3, '01:30:06', 'polished details'),
	   (4, 1, '20:00:00', 'completed'),
	   (5, 3, '04:25:15', 'completed') $$,
    'Insert work logs'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.work_log (project_id, logger_id, work_time, description)
       VALUES (6, 3, '00:30:00', 'done') $$,
    '23503', NULL, 'Insert non-existing project should throw'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.work_log (project_id, logger_id, work_time, description)
       VALUES (2, 6, '01:00:00', 'expensed needed lumber') $$,
    '23503', NULL, 'Insert non-existing user should throw'
);
SELECT results_eq(
    $$ SELECT id, project_id, logger_id, description
       FROM inventory.work_log
       ORDER BY id $$,
    $$ VALUES (1::bigint, 1::bigint, 1::bigint, 'cut pieces to right size'),
	(2::bigint, 1::bigint, 3::bigint, 'assembled pieces'),
	(3::bigint, 1::bigint, 3::bigint, 'polished details'),
	(4::bigint, 4::bigint, 1::bigint, 'completed'),
	(5::bigint, 5::bigint, 3::bigint, 'completed') $$,
    'verify inserted work logs'
);

-- user_project tests
SELECT lives_ok(
    $$ INSERT INTO inventory.user_project
       VALUES (1, 1), (2, 3), (3, 2), (3, 3), (4, 4), (4, 5), (5, 4) $$,
    'Insert user-project relationships'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.user_project
       VALUES (6, 2) $$,
    '23503', NULL, 'Insert non-existing user should throw'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.user_project
       VALUES (3, 6) $$,
    '23503', NULL, 'Insert non-existing project should throw'
);

-- lumber tests
SELECT lives_ok(
    $$ INSERT INTO inventory.lumber (serial, type_id, project_id, color, length,
    width, thickness, is_surface1_smooth, is_surface2_smooth, is_live_edge,
    has_metal, is_reclaimed, moisture_content, cost, board_feet,
    cost_per_board_foot, surface1_defects_count, surface2_defects_count,
    surface1_clear_percentage, surface2_clear_percentage, grade, date_acquired,
    date_expensed, last_update_date)
       VALUES ('001', 1::smallint, 5::bigint, '00FF00', 128::smallint, 12::smallint,
         21::smallint, true, true, false, false, false, 500::smallint, 8.05::numeric,
         5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint,
         'A', current_date, current_date, current_date),
	   ('002', 1::smallint, NULL::bigint, NULL::text, NULL::smallint, NULL::smallint,
       NULL::smallint, NULL::boolean, NULL::boolean, NULL::boolean, NULL::boolean, false, NULL::smallint, NULL::numeric,
       NULL::integer, NULL::numeric, NULL::smallint, NULL::smallint, NULL::smallint, NULL::smallint,
       NULL::character, NULL::date, NULL::date, current_date),
	   ('003', 1::smallint, NULL::bigint, '20FF00', 25::smallint, 20::smallint,
       4::smallint, false, true, false, true, true, 315::smallint, 8.05::numeric,
       5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint,
       'B', current_date, current_date, current_date),
	   ('004', 3::smallint, 2::bigint, '10FF00', 15::smallint, 8::smallint,
       1::smallint, true, false, true, true, true, 225::smallint, 8.05::numeric,
       5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint,
       'E', current_date, current_date, current_date),
	   ('005', 2::smallint, 2::bigint, '11FF00', 13::smallint, 9::smallint,
       2::smallint, true, true, false, true, true, 189::smallint, 8.05::numeric,
       5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint,
       'A', current_date, current_date, current_date) $$,
    'Insert lumbers'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.lumber (serial, type_id, project_id, color, length,
    width, thickness, is_surface1_smooth, is_surface2_smooth, is_live_edge,
    has_metal, is_reclaimed, moisture_content, cost, board_feet,
    cost_per_board_foot, surface1_defects_count, surface2_defects_count,
    surface1_clear_percentage, surface2_clear_percentage, grade, date_acquired,
    date_expensed, last_update_date)
       VALUES ('002', 3::smallint, NULL::bigint, NULL::text, NULL::smallint, NULL::smallint,
         NULL::smallint, NULL::boolean, NULL::boolean, NULL::boolean, NULL::boolean, false, NULL::smallint, NULL::numeric,
         NULL::integer, NULL::numeric, NULL::smallint, NULL::smallint, NULL::smallint, NULL::smallint,
         NULL::character, current_date::date, NULL::date, current_date) $$,
    '23505', NULL, 'Insert duplicate serial should throw'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.lumber (serial, type_id, project_id, color, length,
    width, thickness, is_surface1_smooth, is_surface2_smooth, is_live_edge,
    has_metal, is_reclaimed, moisture_content, cost, board_feet,
    cost_per_board_foot, surface1_defects_count, surface2_defects_count,
    surface1_clear_percentage, surface2_clear_percentage, grade, date_acquired,
    date_expensed, last_update_date)
       VALUES ('006', 6::smallint, NULL::bigint, NULL::text, NULL::smallint, NULL::smallint,
         NULL::smallint, NULL::boolean, NULL::boolean, NULL::boolean, NULL::boolean, false, NULL::smallint, NULL::numeric,
         NULL::integer, NULL::numeric, NULL::smallint, NULL::smallint, NULL::smallint, NULL::smallint,
         NULL::character, NULL::date, NULL::date, current_date) $$,
    '23503', NULL, 'Insert non-existing type should throw'
);
SELECT throws_ok(
    $$ INSERT INTO inventory.lumber (serial, type_id, project_id, color, length,
    width, thickness, is_surface1_smooth, is_surface2_smooth, is_live_edge,
    has_metal, is_reclaimed, moisture_content, cost, board_feet,
    cost_per_board_foot, surface1_defects_count, surface2_defects_count,
    surface1_clear_percentage, surface2_clear_percentage, grade, date_acquired,
    date_expensed, last_update_date)
       VALUES ('007', 2::smallint, 6::bigint, NULL::text, NULL::smallint, NULL::smallint,
         NULL::smallint, NULL::boolean, NULL::boolean, NULL::boolean, NULL::boolean, false, NULL::smallint, NULL::numeric,
         NULL::integer, NULL::numeric, NULL::smallint, NULL::smallint, NULL::smallint, NULL::smallint,
         NULL::character, current_date::date, NULL::date, current_date) $$,
    '23503', NULL, 'Insert non-existing project should throw'
);
SELECT results_eq(
    $$ SELECT id, serial, type_id, project_id, color, length,
    width, thickness, is_surface1_smooth, is_surface2_smooth, is_live_edge,
    has_metal, is_reclaimed, moisture_content, cost, board_feet,
    cost_per_board_foot, surface1_defects_count, surface2_defects_count,
    surface1_clear_percentage, surface2_clear_percentage, grade
       FROM inventory.lumber
       ORDER BY id $$,
    $$ VALUES (1::bigint, '001', 1::smallint, 5::bigint, '00FF00', 128::smallint, 12::smallint,
      21::smallint, true, true, false, false, false, 500::smallint, 8.05::numeric,
      5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint, 'A'),
  (2::bigint, '002', 1::smallint, NULL::bigint, NULL::text, NULL::smallint, NULL::smallint,
    NULL::smallint, NULL::boolean, NULL::boolean, NULL::boolean, NULL::boolean, false, NULL::smallint, NULL::numeric,
    NULL::integer, NULL::numeric, NULL::smallint, NULL::smallint, NULL::smallint, NULL::smallint, NULL::character),
  (3::bigint, '003', 1::smallint, NULL::bigint, '20FF00', 25::smallint, 20::smallint,
    4::smallint, false, true, false, true, true, 315::smallint, 8.05::numeric,
    5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint, 'B'),
  (4::bigint, '004', 3::smallint, 2::bigint, '10FF00', 15::smallint, 8::smallint,
    1::smallint, true, false, true, true, true, 225::smallint, 8.05::numeric,
    5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint, 'E'),
  (5::bigint, '005', 2::smallint, 2::bigint, '11FF00', 13::smallint, 9::smallint,
    2::smallint, true, true, false, true, true, 189::smallint, 8.05::numeric,
    5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint, 'A') $$,
    'verify inserted lumbers'
);

-- user-relationships tests
SELECT throws_ok(
    $$ DELETE FROM account.inventory_user
       WHERE id = 2 $$,
    '23503', NULL, 'Delete user who has created lumber project(s) should throw'
);
SELECT throws_ok(
    $$ DELETE FROM account.inventory_user
       WHERE id = 3 $$,
    '23503', NULL, 'Delete user who has created work log(s) should throw'
);
SELECT throws_ok(
    $$ DELETE FROM account.inventory_user
       WHERE id = 5 $$,
    '23503', NULL, 'Delete user who has created work log(s) should throw'
);

-- lumber-project-relationships tests
SELECT lives_ok(
    $$ DELETE FROM inventory.lumber_project
       WHERE id = 5 $$,
    'Delete project'
);
SELECT results_eq(
    $$ SELECT id, project_id, logger_id, description
       FROM inventory.work_log
       ORDER BY id $$,
    $$ VALUES (1::bigint, 1::bigint, 1::bigint, 'cut pieces to right size'),
	(2::bigint, 1::bigint, 3::bigint, 'assembled pieces'),
	(3::bigint, 1::bigint, 3::bigint, 'polished details'),
	(4::bigint, 4::bigint, 1::bigint, 'completed') $$,
    'verify deleted work logs'
);
SELECT results_eq(
    $$ SELECT * FROM inventory.user_project
       ORDER BY user_id, project_id $$,
    $$ VALUES (1::bigint, 1::bigint), (2::bigint, 3::bigint),
    (3::bigint, 2::bigint), (3::bigint, 3::bigint), (4::bigint, 4::bigint),
    (5::bigint, 4::bigint) $$,
    'verify deleted user-project relationship'
);
SELECT results_eq(
    $$ SELECT id, serial, type_id, project_id, color, length,
    width, thickness, is_surface1_smooth, is_surface2_smooth, is_live_edge,
    has_metal, is_reclaimed, moisture_content, cost, board_feet,
    cost_per_board_foot, surface1_defects_count, surface2_defects_count,
    surface1_clear_percentage, surface2_clear_percentage, grade
       FROM inventory.lumber
       ORDER BY id $$,
    $$ VALUES (1::bigint, '001', 1::smallint, NULL::bigint, '00FF00', 128::smallint, 12::smallint,
      21::smallint, true, true, false, false, false, 500::smallint, 8.05::numeric,
      5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint, 'A'),
  (2::bigint, '002', 1::smallint, NULL::bigint, NULL::text, NULL::smallint, NULL::smallint,
    NULL::smallint, NULL::boolean, NULL::boolean, NULL::boolean, NULL::boolean, false, NULL::smallint, NULL::numeric,
    NULL::integer, NULL::numeric, NULL::smallint, NULL::smallint, NULL::smallint, NULL::smallint, NULL::character),
  (3::bigint, '003', 1::smallint, NULL::bigint, '20FF00', 25::smallint, 20::smallint,
    4::smallint, false, true, false, true, true, 315::smallint, 8.05::numeric,
    5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint, 'B'),
  (4::bigint, '004', 3::smallint, 2::bigint, '10FF00', 15::smallint, 8::smallint,
    1::smallint, true, false, true, true, true, 225::smallint, 8.05::numeric,
    5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint, 'E'),
  (5::bigint, '005', 2::smallint, 2::bigint, '11FF00', 13::smallint, 9::smallint,
    2::smallint, true, true, false, true, true, 189::smallint, 8.05::numeric,
    5, 1.61::numeric, 1::smallint, 1::smallint, 1::smallint, 1::smallint, 'A') $$,
    'verify updated lumber with project set to NULL'
);

-- lumber-type-relationships tests
SELECT throws_ok(
    $$ DELETE FROM inventory.lumber_type
       WHERE id = 3 $$,
    '23503', NULL, 'Delete type that is assigned to lumber(s) should throw'
);


SELECT * FROM finish();
ROLLBACK;
