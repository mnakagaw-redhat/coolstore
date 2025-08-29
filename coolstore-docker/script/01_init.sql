ALTER SYSTEM SET wal_level = logical;

-- 共通ロール作成
CREATE ROLE coolstore_role;

-- DB作成
CREATE DATABASE coolstore;

-- exampledbへ切り替え
\c coolstore

-- スキーマ作成
CREATE SCHEMA coolstore;

-- ロールの作成
CREATE ROLE quarkus WITH LOGIN PASSWORD 'quarkus';

-- 権限追加
GRANT CONNECT ON DATABASE coolstore TO coolstore_role;
GRANT ALL PRIVILEGES ON DATABASE coolstore TO coolstore_role;
GRANT ALL PRIVILEGES ON SCHEMA coolstore TO coolstore_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA coolstore TO coolstore_role;

GRANT coolstore_role TO quarkus;
ALTER ROLE quarkus SET search_path TO coolstore;
