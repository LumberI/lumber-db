BEGIN;
CREATE EXTENSION IF NOT EXISTS pgtap;
SELECT plan(4);

--setup for tests
set client_min_messages = WARNING;
TRUNCATE history.project_activity RESTART IDENTITY CASCADE;
TRUNCATE history.lumber_activity RESTART IDENTITY CASCADE;

-- lumber_activity tests
SELECT lives_ok(
    $$ INSERT INTO history.lumber_activity (log_time,
    log_id, user_login_id, lumber_serial, data)
       VALUES (now(), 1, 'admin', '001', NULL),
	   (now(), 5, 'foobar', '005', '{"foo":2.5,"bar":5}'),
	   (now(), 2, 'admin', '002', NULL),
	   (now(), 3, 'foobar', '005', '{"foo":false}'),
	   (now(), 2, 'foobar', '005', NULL) $$,
    'Insert lumber activities'
);
SELECT results_eq(
    $$ SELECT id, log_id, user_login_id, lumber_serial, data
       FROM history.lumber_activity
       ORDER BY id $$,
    $$ VALUES (1::bigint, 1::smallint, 'admin', '001', NULL::jsonb),
	(2::bigint, 5::smallint, 'foobar', '005', '{"foo":2.5,"bar":5}'::jsonb),
	(3::bigint, 2::smallint, 'admin', '002', NULL::jsonb),
	(4::bigint, 3::smallint, 'foobar', '005', '{"foo":false}'::jsonb),
	(5::bigint, 2::smallint, 'foobar', '005', NULL::jsonb) $$,
    'verify inserted lumber activities'
);

-- project_activity tests
SELECT lives_ok(
    $$ INSERT INTO history.project_activity (log_time,
    log_id, user_login_id, project_name, data)
       VALUES (now(), 1, 'admin', 'chair', NULL),
	   (now(), 5, 'foobar', 'table', '{"foo":2.5,"bar":5}'),
	   (now(), 2, 'admin', 'chair', NULL),
	   (now(), 3, 'foobar', 'chair', '{"foo":false}'),
	   (now(), 2, 'foobar', 'cabinet', NULL) $$,
    'Insert project activities'
);
SELECT results_eq(
    $$ SELECT id, log_id, user_login_id, project_name, data
       FROM history.project_activity
       ORDER BY id $$,
    $$ VALUES (1::bigint, 1::smallint, 'admin', 'chair', NULL::jsonb),
	(2::bigint, 5::smallint, 'foobar', 'table', '{"foo":2.5,"bar":5}'::jsonb),
	(3::bigint, 2::smallint, 'admin', 'chair', NULL::jsonb),
	(4::bigint, 3::smallint, 'foobar', 'chair', '{"foo":false}'::jsonb),
	(5::bigint, 2::smallint, 'foobar', 'cabinet', NULL::jsonb) $$,
    'verify inserted project activities'
);


SELECT * FROM finish();
ROLLBACK;
