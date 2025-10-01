-- complete_migration.sql
-- 完整的 SQLite 到 PostgreSQL 迁移脚本

-- 开始事务
BEGIN;

-- 创建表结构
\i create_tables.sql

-- 插入数据
\i insert_data.sql

-- 提交事务
COMMIT;

-- 验证数据
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Sessions', COUNT(*) FROM sessions
UNION ALL
SELECT 'Admin Actions', COUNT(*) FROM admin_actions
UNION ALL
SELECT 'Reports', COUNT(*) FROM reports
UNION ALL
SELECT 'Bans', COUNT(*) FROM bans;