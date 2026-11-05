-- 1 Revoking permissions on the current database to all non-superusers
REVOKE CONNECT ON DATABASE my_database FROM PUBLIC;
REVOKE TEMPORARY, TEMP ON DATABASE my_database FROM PUBLIC;

-- 2 Lockdown the public schema
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- 3 Restrict automatic function execution
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- 4 Create database schemas early
CREATE SCHEMA IF NOT EXISTS telegram_bot;
CREATE SCHEMA IF NOT EXISTS web_tracker;

-- 5 Shared Senior Dev role setup
\getenv pw_senior SENIOR_DEV_PASSWORD

CREATE ROLE grp_senior_dev NOLOGIN;
CREATE ROLE usr_senior_dev WITH LOGIN CREATEDB CREATEROLE PASSWORD :'pw_senior' INHERIT;

GRANT grp_senior_dev TO usr_senior_dev;
ALTER ROLE usr_senior_dev SET search_path TO telegram_bot, web_tracker, public;