-- 1. Tighten existing permissions on the current database
-- Removes the default ability for ANY authenticated user to connect to this database
REVOKE CONNECT ON DATABASE my_database FROM PUBLIC;

-- Removes the ability to create temporary tables, preventing disk space abuse
REVOKE TEMPORARY, TEMP ON DATABASE my_database FROM PUBLIC;

-- 2. Lockdown the public schema
-- Prevents any user from creating new tables/objects in the public schema
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- (Optional) If you want absolute isolation, revoke usage too (requires explicit schema grants later)
-- REVOKE USAGE ON SCHEMA public FROM PUBLIC;

-- 3. Block automatic execution of newly created functions
-- By default, Postgres allows PUBLIC to run all functions. This restricts future functions:
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- 4. Strip execution from all existing functions in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
