-- The password comes from the environment
\getenv pgbouncer_auth_password PGBOUNCER_AUTH_PASSWORD

CREATE ROLE pgbouncer_auth WITH LOGIN PASSWORD :'pgbouncer_auth_password' CONNECTION LIMIT 5;

-- PgBouncer's auth_query instead of keeping a static file of every
-- role's password hash in sync by hand, PgBouncer asks Postgres for a role's
-- current hash live, on each new connection. pgbouncer_auth authenticates
-- itself once (via config/pgbouncer/userlist.txt, which holds only this one
-- role's own hash) and then calls this function to look up everyone else.

-- SECURITY DEFINER makes this run as its owner (a superuser), so it can read
-- pg_shadow -- pgbouncer_auth itself only ever gets EXECUTE, nothing more.
CREATE FUNCTION public.pgbouncer_auth_lookup(in_username text)
RETURNS TABLE (usename name, passwd text)
LANGUAGE sql
SECURITY DEFINER                 -- run with the owner's (superuser's) rights
SET search_path = pg_catalog     -- only look inside the system catalog
AS $$
    SELECT usename, passwd FROM pg_shadow WHERE usename = in_username;
$$;

-- STEP 4: by default everyone may run a new function, so remove that,
-- then give the right to pgbouncer_auth only.
REVOKE ALL ON FUNCTION public.pgbouncer_auth_lookup(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pgbouncer_auth_lookup(text) TO pgbouncer_auth;