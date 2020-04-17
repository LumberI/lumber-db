-- Deploy lumberi:user_group_role to pg
-- requires: account

BEGIN;

CREATE TABLE IF NOT EXISTS account.inventory_user
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    login_id text NOT NULL,
    password text NOT NULL,
    full_name text NOT NULL,
    preferred_name text NOT NULL,
    email text,
    is_active boolean NOT NULL,
    created_time timestamp with time zone NOT NULL,
    last_login_time timestamp with time zone,
    CONSTRAINT inventory_user_pkey PRIMARY KEY (id),
    CONSTRAINT inventory_user_email_key UNIQUE (email),
    CONSTRAINT inventory_user_login_id_key UNIQUE (login_id)
);

ALTER TABLE account.inventory_user
    OWNER to lumber_dba;

CREATE TABLE IF NOT EXISTS account.inventory_group
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    name text NOT NULL,
    description text,
    is_active boolean NOT NULL,
    created_time timestamp with time zone NOT NULL,
    CONSTRAINT inventory_group_pkey PRIMARY KEY (id),
    CONSTRAINT inventory_group_name_key UNIQUE (name)
);

ALTER TABLE account.inventory_group
    OWNER to lumber_dba;

CREATE TABLE IF NOT EXISTS account.inventory_role
(
    id integer,
    name text NOT NULL,
    CONSTRAINT inventory_role_pkey PRIMARY KEY (id),
    CONSTRAINT inventory_role_name_key UNIQUE (name)
);

ALTER TABLE account.inventory_role
    OWNER to lumber_dba;

CREATE TABLE IF NOT EXISTS account.inventory_user_group
(
    user_id bigint,
    group_id bigint,
    CONSTRAINT inventory_user_group_pkey PRIMARY KEY (user_id, group_id),
    CONSTRAINT inventory_user_group_group_id_fkey FOREIGN KEY (group_id)
        REFERENCES account.inventory_group (id) ON DELETE CASCADE,
    CONSTRAINT inventory_user_group_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES account.inventory_user (id) ON DELETE CASCADE
);

ALTER TABLE account.inventory_user_group
    OWNER to lumber_dba;

CREATE TABLE IF NOT EXISTS account.inventory_group_role
(
    group_id bigint,
    role_id integer,
    CONSTRAINT inventory_group_role_pkey PRIMARY KEY (group_id, role_id),
    CONSTRAINT inventory_group_role_group_id_fkey FOREIGN KEY (group_id)
        REFERENCES account.inventory_group (id) ON DELETE CASCADE,
    CONSTRAINT inventory_group_role_role_id_fkey FOREIGN KEY (role_id)
        REFERENCES account.inventory_role (id) ON DELETE CASCADE
);

ALTER TABLE account.inventory_group_role
    OWNER to lumber_dba;

COMMIT;
