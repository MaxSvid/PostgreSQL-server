-- Wallet tracker (Telegram bot)
CREATE TABLE IF NOT EXISTS bot_users(
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    username TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    joined TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS wallets(
    wallet_id SERIAL PRIMARY KEY,
    address,
    label,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    added_at TIMESTAMPTZ NOT NULL DEFAULT now()
);