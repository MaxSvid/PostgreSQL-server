CREATE SCHEMA tracking;

-- Lock down from everyone by default
REVOKE ALL ON SCHEMA tracking FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- TABLES

CREATE TABLE tracking.projects (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    status      VARCHAR(20) DEFAULT 'active'
                CHECK (status IN ('active', 'paused', 'archived')),
    created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tracking.project_databases (
    id              SERIAL PRIMARY KEY,
    project_id      INTEGER REFERENCES tracking.projects(id)
                    ON DELETE CASCADE,
    container_name  VARCHAR(100) NOT NULL,
    database_name   VARCHAR(100) NOT NULL,
    port            INTEGER DEFAULT 5432,
    notes           TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tracking.project_credentials (
    id          SERIAL PRIMARY KEY,
    project_id  INTEGER REFERENCES tracking.projects(id)
                ON DELETE CASCADE,
    username    VARCHAR(100) NOT NULL,
    role        VARCHAR(20) DEFAULT 'dev'
                CHECK (role IN ('admin', 'dev', 'readonly')),
    notes       TEXT,
    created_at  TIMESTAMP DEFAULT NOW()
);