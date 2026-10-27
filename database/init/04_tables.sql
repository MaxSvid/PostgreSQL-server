BEGIN;
CREATE SCHEMA IF NOT EXISTS telegram;

--- Creating the limit for users to track wallets 
CREATE TABLE IF NOT EXISTS telegram.tiers(
    tier TEXT PRIMARY KEY,
    max_wallets integer NOT NULL CHECK (max_wallets > 0)
);
INSERT INTO telegram.tiers (tier, max_wallets)
VALUES ('standard', 5), ('team', 12)
ON CONFLICT (tier) DO NOTHING;

--- Wallet tracker (Telegram bot)
CREATE TABLE IF NOT EXISTS telegram.bot_users(

    id SERIAL PRIMARY KEY,
    user_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    joined TIMESTAMPTZ NOT NULL DEFAULT now()
);

--- Users wallets 
CREATE TABLE IF NOT EXISTS telegram.wallets(
    
    wallet_id SERIAL PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES,
    address,
    label,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_users FOREIGN KEY (user_id) REFERENCES telegram.bot_users(user_id)
);

--- INDEX to improve the speed for queries 
CREATE INDEX IF NOT EXISTS user_wallets_idx 
ON telegram.wallets (wallet_id) WHERE is_active;
