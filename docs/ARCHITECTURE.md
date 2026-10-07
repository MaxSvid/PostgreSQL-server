# Architecture

## Containers

```
                         127.0.0.1 only (SSH tunnel from outside)
                                   |
        +--------------------------------------------------+
        |                 alpha1_vps_network                |
        |                                                    |
        |   +----------+     +-----------+     +---------+   |
in ----->---|pgbouncer |---->| postgres  |<----| pgadmin |   |
        |   +----------+     +-----------+     +---------+   |
        |     (pooling)      (data + roles)   (per-user UI)  |
        +--------------------------------------------------+
```

## Access

Postgres and pgAdmin publish ports on the VPS's `127.0.0.1` only. Everyone (owner and team) reaches pgAdmin through an SSH tunnel:

```bash
ssh -N -L 5050:127.0.0.1:<PGADMIN_PORT> <user>@<vps>   # then open http://localhost:5050
```

In pgAdmin, register the server as host `postgres`, port `5432` (the Docker network name, not the published port). The owner connects as `POSTGRES_USER`; team members connect with their own role.

Recommended sshd restriction for each team member's VPS account (`/etc/ssh/sshd_config`, applied by hand):

```
Match User <member>
    AllowTcpForwarding local
    PermitOpen 127.0.0.1:<PGADMIN_PORT>
    PermitTTY no
    X11Forwarding no
    ForceCommand /usr/sbin/nologin
```

### Projects and roles

One schema per project inside `POSTGRES_DB`, each with three NOLOGIN group roles: `<p>_owner` (owns the schema), `<p>_rw` and `<p>_ro`. Access is granted only through membership. Helpers from `database/init/02_project_admin.sql`, superuser only:

```sql
SELECT admin.create_project('wallet_tracker');
SELECT admin.grant_access('alice', 'wallet_tracker', 'rw');   -- level: owner | rw | ro
SELECT admin.revoke_access('alice', 'wallet_tracker');
```

DDL and migrations must run after `SET ROLE <p>_owner`. Tables created under any other role are not covered by the `rw`/`ro` default privileges.

### Onboarding a team member

1. VPS: create their SSH account with the `Match User` block above.
2. pgAdmin (owner): *Users* → add an account with role **User**, not Administrator.
3. pgAdmin (owner): *Login/Group Roles* → create their Postgres login role with a password.
4. Query Tool (owner): `SELECT admin.grant_access('<role>', '<project>', '<level>');`
5. Team member: tunnel in, sign in, set a master password, register server `postgres:5432` with their own role.

Sourcers

1. https://dev.to/saiful7778/setting-up-postgresql-with-docker-compose-for-development-and-production-45j8

2. https://distr.sh/blog/docker-compose-mount-config-files/

3. 
