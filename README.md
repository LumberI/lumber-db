# lumber-db

## Project setup

\**Note that steps 4~7 is for setting up a database instance for development purpose and is recommended so as to not corrupt the live production database*

1. Install [PostgreSQL](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads "PostgreSQL downlaod"), [sqitch](https://sqitch.org/download/ "sqitch download") with PostgreSQL support, and [pgTAP](https://pgxn.org/dist/pgtap/ "pgTAP download")
    - pgAdmin (GUI) is also included in PostgreSQL installation and is recommended over psql (CLI) when configuring the database
2. Add PostgreSQL `bin` path to Environment Variable
3. _(Optional)_ Setup global username for sqitch with
```
sqitch config --user user.name 'John Doe'
```
4. Edit engine.pg.target in lumber-global/sqitch.conf, or specify target as command line option to point sqitch commands to the server instance
    - sqitch target formatting is specified [here](https://sqitch.org/docs/manual/sqitch-target/#description)
	- password is recommended to be supplied with [.pgpass](https://www.postgresql.org/docs/current/libpq-pgpass.html)
    - **NOTE** sqitch.plan is used by sqitch to track changes and **should not be manually edited**
5. Deploy all changes in lumber-global folder with
```
sqitch deploy -t db:pg://postgres@localhost
```
6. Edit engine.pg.target in sqitch.conf, or specify target as command line option to point sqitch commands to the new lumberi database
7. Deploy all changes with
```
sqitch deploy -t db:pg://lumber_admin@localhost/lumberi
```
8. For changes that applies to the whole server instance, such as roles and database, use the lumber-global sqitch projects; for changes within the lumberi database, use the lumberi sqitch project
    - To create database or user/role with lumber_admin or other user of lumber_dba role, the following must be executed first upon login
    ```sql
    SET ROLE lumber_dba;
    ```
9. Use pg_prove to do unit testing with
```
pg_prove -d lumberi -U lumber_admin test/*
```
where test is the folder containing all `.sql` files with tests
    - Add path to pg_prove to PATH environment variable if it is not already included in PATH yet
	- **NOTE** tests may corrupt ids and **should not be run against production database**
10. When releasing new version and deploying (with `sqitch deploy`) to production server, make sure engine.pg.target in sqitch.conf is correct, or manually specify target as command line option to override

11. Use
```
sqitch bundle --dest-dir path/to/releases/lumberi_v0.1.0
```
to create a copy of sqitch project for a specific release

For comprehensive tutorial, refer to
- sqtich: https://sqitch.org/docs/manual/sqitchtutorial/
- pgTAP: https://pgtap.org/documentation.html
