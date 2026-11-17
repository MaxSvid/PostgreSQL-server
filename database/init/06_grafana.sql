\getenv pw_grafana GRAFANA_MONITOR_PASSWORD

-- The extension creates the pg_stat_statements view in this database.
-- Query text is normalised (literals become $1, $2 ...), and
-- pg_stat_statements.track_utility = off in postgres.conf stops it from
-- recording utility commands such as ALTER ROLE ... PASSWORD '...'.
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

CREATE ROLE grafana_monitor LOGIN PASSWORD :'pw_grafana' CONNECTION LIMIT 3;

-- pg_monitor = built-in read-only role: pg_stat_activity with query text
-- of all sessions, pg_stat_statements, locks, sizes. No table data.
GRANT pg_monitor TO grafana_monitor;
SELECT format('GRANT CONNECT ON DATABASE %I TO grafana_monitor', current_database()) \gexec

-- Allow Grafana to see your application schemas (grant SELECT on specific views inside your migration scripts once those views exist)
GRANT USAGE ON SCHEMA telegram_bot, web_tracker TO grafana_monitor;

-- Even if Grafana is compromised it cannot write, and slow panels are cut off
ALTER ROLE grafana_monitor SET default_transaction_read_only = on;
ALTER ROLE grafana_monitor SET statement_timeout = '5s';