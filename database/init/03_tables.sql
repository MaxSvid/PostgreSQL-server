-- Wallet tracker (Telegram bot)
CREATE TABLE IF NOT EXISTS bot_users(
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    username TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    joined TIMESTAMPTZ NOT NULL DEFAULT now()
);
