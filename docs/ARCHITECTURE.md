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

Sourcers

1. https://dev.to/saiful7778/setting-up-postgresql-with-docker-compose-for-development-and-production-45j8

2. https://medium.com/@mecreate/postgresql-for-devops-production-setup-and-operations-2630f41ce779

3. https://distr.sh/blog/docker-compose-mount-config-files/

4. https://www.youtube.com/watch?v=FpBYgYyU-SE

5. https://www.netdata.cloud/guides/pgbouncer/pgbouncer-transaction-vs-session-pooling/



Grafana 
https://blog.devgenius.io/how-to-setup-grafana-with-postgresql-database-using-docker-compose-a-step-by-step-guide-e5a9cce90ba3


- **Image** = a read-only template (e.g. `postgres:18`). **Container** = a running instance of an image. **Volume** = storage that outlives containers.
- **Docker Compose** describes several containers, their settings, networks and volumes in one YAML file, so the whole server starts with one command.
- On Windows, Docker runs inside a small Linux VM (WSL2). That's why containers are Linux even on your laptop, and why the VPS behaves the same.