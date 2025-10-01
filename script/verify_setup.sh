#!/bin/bash
set -e

echo "Verifying PostgreSQL setup..."

# 等待服务启动
echo "Waiting for services to be ready..."
sleep 30

# 检查容器状态
echo "Checking container status..."
docker-compose ps

# 检查 PostgreSQL 日志
echo "Checking PostgreSQL logs..."
docker-compose logs db | tail -20

# 测试数据库连接
echo "Testing database connection..."
if docker-compose exec db psql -U teddy1 -d teddy1_production -c "SELECT version();" >/dev/null 2>&1; then
  echo "✅ Database connection successful!"
else
  echo "❌ Database connection failed!"
  echo "Checking users..."
  docker-compose exec db psql -U postgres -c "\du"
  echo "Checking databases..."
  docker-compose exec db psql -U postgres -c "\l"
fi

# 测试应用连接
echo "Testing application connection..."
if docker-compose exec web bin/rails runner "puts 'Rails connected to DB'" >/dev/null 2>&1; then
  echo "✅ Application connection successful!"
else
  echo "❌ Application connection failed!"
fi

echo "Setup verification completed!"