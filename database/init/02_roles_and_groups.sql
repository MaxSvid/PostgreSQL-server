-- Environment
\getenv pw_senior SENIOR_DEV_PASSWORD
\getenv pw_bot APP_TELEGRAM_BOT_PASSWORD
\getenv pw_web APP_TRACKER_WEB_PASSWORD

-- Creating the 3 Login Accounts
CREATE ROLE usr_telegram_bot WITH LOGIN PASSWORD :'pw_bot';
CREATE ROLE usr_tracker_web WITH LOGIN PASSWORD :'pw_web';
CREATE ROLE usr_senior_dev WITH LOGIN CREATEDB CREATEROLE PASSWORD :'pw_senior';

-- Schemas & Assign Ownership
-- Making the app role the schema owner automatically grants it full control
CREATE SCHEMA IF NOT EXISTS telegram_bot AUTHORIZATION usr_telegram_bot;
CREATE SCHEMA IF NOT EXISTS web_tracker AUTHORIZATION usr_tracker_web;

-- Lockdown Public Schema
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- Give Senior Dev Full Access to Both Apps
-- Adding senior dev to app roles grants full access to everything those roles own
GRANT usr_telegram_bot, usr_tracker_web TO usr_senior_dev;

-- 5. Set Default Search Paths
ALTER ROLE usr_telegram_bot SET search_path TO telegram_bot;
ALTER ROLE usr_tracker_web SET search_path TO web_tracker;
ALTER ROLE usr_senior_dev SET search_path TO telegram_bot, web_tracker, public;