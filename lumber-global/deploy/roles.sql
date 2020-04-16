-- Deploy lumber-global:roles to pg

BEGIN;

DO
$role$
BEGIN
    IF NOT EXISTS (
        SELECT
        FROM pg_catalog.pg_roles
        WHERE rolname = 'lumber_dba') THEN

		CREATE ROLE lumber_dba WITH
			NOLOGIN
			NOSUPERUSER
			CREATEDB
			CREATEROLE
			NOINHERIT
			NOREPLICATION;

		COMMENT ON ROLE lumber_dba IS 'For database management tasks, including role and database related tasks.';
   END IF;
END
$role$;

DO
$role$
BEGIN
    IF NOT EXISTS (
        SELECT
        FROM pg_catalog.pg_roles
        WHERE rolname = 'lumber_app') THEN

		CREATE ROLE lumber_app WITH
			NOLOGIN
			NOSUPERUSER
			NOINHERIT
			NOCREATEDB
			NOCREATEROLE
			NOREPLICATION;

		COMMENT ON ROLE lumber_app IS 'For all apps in lumber inventory system';
   END IF;
END
$role$;

DO
$user$
BEGIN
    IF NOT EXISTS (
        SELECT
        FROM pg_catalog.pg_roles
        WHERE rolname = 'lumber_admin') THEN

		CREATE USER lumber_admin WITH PASSWORD 'admin';
   END IF;
END
$user$;
GRANT lumber_dba TO lumber_admin;

DO
$user$
BEGIN
    IF NOT EXISTS (
        SELECT
        FROM pg_catalog.pg_roles
        WHERE rolname = 'lumber_inventory') THEN

		CREATE USER lumber_inventory WITH PASSWORD 'lumber';
   END IF;
END
$user$;
GRANT lumber_app TO lumber_inventory;

COMMIT;
