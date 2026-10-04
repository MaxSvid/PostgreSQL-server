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

2. 
