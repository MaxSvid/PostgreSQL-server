# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal PostgreSQL + pgAdmin setup on a VPS serving multiple projects from a single server. One pgAdmin instance manages multiple PostgreSQL databases; access is restricted per user via pgAdmin's login management.

## Architecture & Patterns

- **Single Docker bridge network** — all containers share one custom bridge network and communicate by container name; no inter-container port exposure needed.
- **One pgAdmin, many databases** — pgAdmin user management controls which server connections each login can access, isolating project teams from each other.

## Stack Best Practices

- Docker Compose for orchestration
- PostgreSQL (one container per project or shared)
- pgAdmin 4 as the web UI

## Anti-Patterns

- Do not expose inter-container ports on the host — containers should communicate over the bridge network by name.
- Do not rely on network-level firewall rules between containers as the primary access control; use pgAdmin's user restrictions instead.

## File Structure

```
compose.yaml              — Docker Compose service definitions (postgres_server, pgadmin_server)
.env.example              — Template showing required env vars; copy to .env and fill in values
.env                      — Actual credentials (gitignored, never committed)
.dockerignore             — Empty placeholder (present but no rules yet)
init.sh                   — Bootstrap script (set -e / set -u guards; run chmod +x init.sh first)
README.md                 — Project overview and network-setup explanation
docs/TUTORIAL.md          — Extended walkthrough (currently empty placeholder)
database/01_init.sql      — server_admin schema: projects, project_databases, access_grants
database/02_roles.sql     — PostgreSQL role definitions (empty placeholder)
```

## Services (compose.yaml)

| Service | Image | Container name | Exposed port |
|---|---|---|---|
| PostgreSQL | `postgres:16` | `postgres_server` | `${POSTGRES_PORT_HOST}:5432` |
| pgAdmin 4 | `dpage/pgadmin4` | `pgadmin_server` | `${PGADMIN_PORT}:80` |

Both services share the `pg_network` bridge network and use named volumes for persistence (`postgres_server_data`, `pgadmin_data`). Both restart `unless-stopped`.

## Required `.env` Variables

```
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=
POSTGRES_PORT_HOST=
PGADMIN_EMAIL=
PGADMIN_PASSWORD=
PGADMIN_PORT=
```

Copy `.env.example` as a starting point; the example only contains pgAdmin defaults — add the Postgres variables before first run.

## Data Models (`database/01_init.sql`)

Meta-database `server_admin` tracks all project databases and access grants on this server. Run against `server_admin` after creating it manually (see Commands section).

### `projects`
Top-level project registry.

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | `gen_random_uuid()` |
| `name` | TEXT UNIQUE | Human-readable name |
| `slug` | TEXT UNIQUE | URL/identifier-friendly key |
| `description` | TEXT | Optional |
| `status` | TEXT | `active` \| `paused` \| `archived` |
| `created_at` / `updated_at` | TIMESTAMPTZ | `updated_at` auto-maintained by trigger |

### `project_databases`
Each PostgreSQL database belonging to a project.

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | |
| `project_id` | UUID FK | → `projects.id` ON DELETE RESTRICT |
| `db_name` | TEXT | Actual PostgreSQL database name |
| `container_name` | TEXT | Docker container hostname (used as pgAdmin server host) |
| `pg_port` | INT | Default `5432` |
| `environment` | TEXT | `production` \| `staging` \| `development` \| `local` |
| `is_active` | BOOLEAN | Default `true` |
| `created_at` / `updated_at` | TIMESTAMPTZ | `updated_at` auto-maintained by trigger |

Unique constraint on `(project_id, db_name, environment)`.

### `access_grants`
Which pgAdmin users can access which project database.

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | |
| `project_database_id` | UUID FK | → `project_databases.id` ON DELETE RESTRICT |
| `pgadmin_email` | TEXT | pgAdmin login email of the grantee |
| `access_level` | TEXT | `read_only` \| `read_write` \| `admin` |
| `granted_by` | TEXT | Defaults to `current_user` |
| `granted_at` | TIMESTAMPTZ | |
| `revoked_at` | TIMESTAMPTZ | `NULL` = active grant; set to revoke without losing history |

Partial unique index on `(project_database_id, pgadmin_email) WHERE revoked_at IS NULL` — one active grant per user per database, re-grantable after revocation.

## Security & Configuration

- Credentials (passwords, connection strings) live in `.env` files, which are gitignored and never committed.
- pgAdmin server definitions and user restrictions are the primary access-control layer.
- PostgreSQL port is exposed on the host (for external tooling); inter-container traffic stays on the bridge network.
- `server_admin` database: `REVOKE ALL ON SCHEMA public FROM PUBLIC` — only the owner role has access. Grant additional users explicitly via `access_grants` table and pgAdmin user management.
- `.claude/` is gitignored and never committed (Claude Code local config, skills, memory).

## Commands & Scripts

```bash
# First run
chmod +x init.sh
cp .env.example .env   # then fill in all variables

# Start stack
docker compose up -d

# Stop stack
docker compose down

# Wipe volumes (destructive — drops all DB data)
docker compose down -v
```

### Initialising the server_admin database

Run the following once as superuser (e.g. via pgAdmin Query Tool connected to `postgres`):

```sql
CREATE DATABASE server_admin
    OWNER      = <your POSTGRES_USER>
    ENCODING   = 'UTF8'
    TEMPLATE   = template0;
REVOKE ALL ON DATABASE server_admin FROM PUBLIC;
```

Then connect to `server_admin` and run `database/01_init.sql` in full.
