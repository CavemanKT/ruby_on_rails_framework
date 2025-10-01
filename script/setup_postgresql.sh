#!/bin/bash
# set -e

# echo "Setting up PostgreSQL for production..."

# # 1. 安装 PostgreSQL
# echo "Installing PostgreSQL..."
# brew install postgresql
# brew services start postgresql

# # 2. 创建用户和数据库
# echo "Creating database user and database..."
# createuser -s teddy1 || echo "User already exists"
# createdb teddy1_production || echo "Database already exists"

# 3. 设置环境变量
echo "Setting environment variables..."
export DB_HOST=localhost
export DB_NAME=teddy1_production
export DB_USERNAME=teddy1
export DB_PASSWORD=asdflkjqwerpoiu

# 4. 安装 gems
echo "Installing gems..."
bundle install

# 5. 创建数据库
echo "Creating Rails database..."
RAILS_ENV=production && rails db:create

# 6. 运行迁移
echo "Running migrations..."
RAILS_ENV=production && rails db:migrate

echo "PostgreSQL setup completed!"