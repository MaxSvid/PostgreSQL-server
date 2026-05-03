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
compose.yaml        — Docker Compose service definitions (postgres_server, pgadmin_server)
.env.example        — Template showing required env vars; copy to .env and fill in values
.env                — Actual credentials (gitignored, never committed)
.dockerignore       — Empty placeholder (present but no rules yet)
init.sh             — Bootstrap script (set -e / set -u guards; run chmod +x init.sh first)
README.md           — Project overview and network-setup explanation
TUTORIAL.md         — Extended walkthrough (currently empty placeholder)
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

## Data Models

_No data models defined yet._

## Security & Configuration

- Credentials (passwords, connection strings) live in `.env` files, which are gitignored and never committed.
- pgAdmin server definitions and user restrictions are the primary access-control layer.
- PostgreSQL port is exposed on the host (for external tooling); inter-container traffic stays on the bridge network.

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
