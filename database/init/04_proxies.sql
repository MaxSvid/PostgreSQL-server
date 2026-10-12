CREATE TABLE IF NOT EXISTS proxies (
    proxy_id        SERIAL PRIMARY KEY,
    protocol        TEXT NOT NULL DEFAULT 'http'
                    CHECK (protocol IN ('http', 'https', 'socks5')),
    host            TEXT NOT NULL,
    port            INTEGER NOT NULL CHECK (port BETWEEN 1 AND 65535),
    username        TEXT,
    password        TEXT,            -- plain text by owner decision (see design Risks)
    status          TEXT NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'failing', 'banned', 'expired', 'disabled')),
    fail_count      INTEGER NOT NULL DEFAULT 0,
    last_error      TEXT,
    last_checked_at TIMESTAMPTZ,
    last_used_at    TIMESTAMPTZ,
    expires_at      TIMESTAMPTZ,
    added_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE NULLS NOT DISTINCT (host, port, username)
);