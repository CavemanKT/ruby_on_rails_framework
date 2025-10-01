-- init-db.sql
-- PostgreSQL 初始化脚本

-- 创建用户（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'teddy1') THEN
        CREATE USER teddy1 WITH PASSWORD 'asdflkjqwerpoiu';
    END IF;
END
$$;

-- 创建数据库（如果不存在）
SELECT 'CREATE DATABASE teddy1_production'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'teddy1_production')\gexec

-- 授权
GRANT ALL PRIVILEGES ON DATABASE teddy1_production TO teddy1;
ALTER USER teddy1 CREATEDB;
