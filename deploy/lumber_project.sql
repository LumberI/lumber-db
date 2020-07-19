-- Deploy lumberi:lumber_project to pg
-- requires: inventory

BEGIN;

CREATE TABLE IF NOT EXISTS inventory.lumber_type
(
    id smallint NOT NULL,
    name text NOT NULL,
    CONSTRAINT lumber_type_pkey PRIMARY KEY (id),
    CONSTRAINT lumber_type_name_key UNIQUE (name)
);

ALTER TABLE inventory.lumber_type
    OWNER to lumber_dba;

CREATE TABLE IF NOT EXISTS inventory.lumber_project
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    name text NOT NULL,
    creator_id bigint NOT NULL,
    cost numeric NOT NULL,
    board_feet integer NOT NULL,
    cost_per_board_foot numeric NOT NULL,
    create_time timestamp with time zone NOT NULL,
    schedule tstzrange,
    CONSTRAINT lumber_project_pkey PRIMARY KEY (id),
    CONSTRAINT lumber_project_name_key UNIQUE (name),
    CONSTRAINT lumber_project_creator_id_fkey FOREIGN KEY (creator_id)
        REFERENCES account.inventory_user (id)
);

ALTER TABLE inventory.lumber_project
    OWNER to lumber_dba;

CREATE TABLE IF NOT EXISTS inventory.work_log
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    project_id bigint NOT NULL,
    logger_id bigint NOT NULL,
    work_time interval NOT NULL,
    description text NOT NULL,
    CONSTRAINT work_log_pkey PRIMARY KEY (id),
    CONSTRAINT work_log_logger_id_fkey FOREIGN KEY (logger_id)
        REFERENCES account.inventory_user (id),
    CONSTRAINT work_log_project_id_fkey FOREIGN KEY (project_id)
        REFERENCES inventory.lumber_project (id) ON DELETE CASCADE
);

ALTER TABLE inventory.work_log
    OWNER to lumber_dba;

CREATE TABLE IF NOT EXISTS inventory.user_project
(
    user_id bigint NOT NULL,
    project_id bigint NOT NULL,
    CONSTRAINT user_project_pkey PRIMARY KEY (user_id, project_id),
    CONSTRAINT user_project_project_id_fkey FOREIGN KEY (project_id)
        REFERENCES inventory.lumber_project (id) ON DELETE CASCADE,
    CONSTRAINT user_project_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES account.inventory_user (id)
);

ALTER TABLE inventory.user_project
    OWNER to lumber_dba;

CREATE TABLE IF NOT EXISTS inventory.lumber
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    serial text NOT NULL,
    type_id smallint NOT NULL,
    project_id bigint,
    color text,
    length smallint,
    width smallint,
    thickness smallint,
    is_surface1_smooth boolean,
    is_surface2_smooth boolean,
    is_live_edge boolean,
    has_metal boolean,
    is_reclaimed boolean NOT NULL,
    moisture_content smallint,
    cost numeric,
    board_feet integer,
    cost_per_board_foot numeric,
    surface1_defects_count smallint,
    surface2_defects_count smallint,
    surface1_clear_percentage smallint,
    surface2_clear_percentage smallint,
    grade character(1),
    date_acquired date,
    date_expensed date,
    last_update_date date NOT NULL,
    CONSTRAINT lumber_pkey PRIMARY KEY (id),
    CONSTRAINT lumber_serial_key UNIQUE (serial),
    CONSTRAINT lumber_project_id_fkey FOREIGN KEY (project_id)
        REFERENCES inventory.lumber_project (id) ON DELETE SET NULL,
    CONSTRAINT lumber_type_id_fkey FOREIGN KEY (type_id)
        REFERENCES inventory.lumber_type (id)
);

ALTER TABLE inventory.lumber
    OWNER to lumber_dba;

COMMIT;
