-- The password comes from the environment
\getenv pgbouncer_auth_password PGBOUNCER_AUTH_PASSWORD

CREATE ROLE pgbouncer_auth WITH LOGIN PASSWORD: 'pgbouncer_auth_password' CONNECTION LIMIT 5;

-- PgBouncer's auth_query instead of keeping a static file of every
-- role's password hash in sync by hand, PgBouncer asks Postgres for a role's
-- current hash live, on each new connection. pgbouncer_auth authenticates
-- itself once (via config/pgbouncer/userlist.txt, which holds only this one
-- role's own hash) and then calls this function to look up everyone else.

-- SECURITY DEFINER makes this run as its owner (a superuser), so it can read
-- pg_shadow -- pgbouncer_auth itself only ever gets EXECUTE, nothing more.

GRANT CONNECT ON DATABASE my_database TO pgbouncer_auth;

-- dedicated schema for PgBouncer utilities
CREATE SCHEMA IF NOT EXISTS pgbouncer AUTHORIZATION pgbouncer_auth;

-- SECURITY DEFINER function to fetch user password hashes
-- SECURITY DEFINER allows the 'pgbouncer' role to read pg_shadow securely
CREATE OR REPLACE FUNCTION pgbouncer.get_auth(p_usename TEXT)
RETURNS TABLE(usename NAME, passwd TEXT)
LANGUAGE sql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT usename, passwd 
    FROM pg_shadow 
    WHERE usename = p_usename;
$$;

-- Restrict function permissions so only the pgbouncer role can run it
REVOKE ALL ON FUNCTION pgbouncer.get_auth(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION pgbouncer.get_auth(TEXT) TO pgbouncer_auth;