-- Deploy lumberi:activity to pg
-- requires: history

BEGIN;

CREATE TABLE IF NOT EXISTS history.lumber_activity
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    log_time timestamp with time zone NOT NULL,
    log_id smallint NOT NULL,
    user_login_id text NOT NULL,
    lumber_serial text NOT NULL,
    data jsonb,
    CONSTRAINT lumber_activity_pkey PRIMARY KEY (id)
);

ALTER TABLE history.lumber_activity
    OWNER to lumber_dba;

CREATE TABLE IF NOT EXISTS history.project_activity
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    log_time timestamp with time zone NOT NULL,
    log_id smallint NOT NULL,
    user_login_id text NOT NULL,
    project_name text NOT NULL,
    data jsonb,
    CONSTRAINT project_activity_pkey PRIMARY KEY (id)
);

ALTER TABLE history.project_activity
    OWNER to lumber_dba;

COMMIT;
