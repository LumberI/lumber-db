-- Deploy lumber-global:lumberi to pg
-- requires: roles

CREATE DATABASE lumberi WITH OWNER = lumber_dba;
GRANT ALL ON DATABASE lumberi TO lumber_dba;
GRANT CONNECT ON DATABASE lumberi TO lumber_app;
REVOKE ALL ON DATABASE lumberi FROM PUBLIC;
