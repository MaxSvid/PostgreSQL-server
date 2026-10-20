-- The password comes from the environment
\getenv pgbouncer_auth_password PGBOUNCER_AUTH_PASSWORD

CREATE ROLE pgbouncer_auth WITH LOGIN PASSWORD :'pgbouncer_auth_password';

-- PgBouncer's auth_query instead of keeping a static file of every
-- role's password hash in sync by hand, PgBouncer asks Postgres for a role's
-- current hash live, on each new connection. pgbouncer_auth authenticates
-- itself once (via a one-line auth file the pgbouncer container writes at
-- start from PGBOUNCER_AUTH_PASSWORD) and then calls this function to look
-- up everyone else.

-- SECURITY DEFINER makes this run as its owner (a superuser), so it can read
-- pg_shadow -- pgbouncer_auth itself only ever gets EXECUTE, nothing more.
-- Superusers and roles whose password has expired (VALID UNTIL) are never
-- returned, so they can't log in through PgBouncer.
-- search_path is pinned with pg_temp last so a caller's temporary table named
-- pg_shadow can't be read instead of the real catalog.
CREATE FUNCTION pgbouncer_auth_lookup(in_username TEXT, OUT usename TEXT, OUT passwd TEXT)
RETURNS SETOF record AS $$
    SELECT usename, passwd FROM pg_catalog.pg_shadow
    WHERE usename = in_username
      AND NOT usesuper
      AND (valuntil IS NULL OR valuntil > now());
$$ LANGUAGE sql SECURITY DEFINER
SET search_path = pg_catalog, pg_temp;

REVOKE ALL ON FUNCTION pgbouncer_auth_lookup(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION pgbouncer_auth_lookup(TEXT) TO pgbouncer_auth;