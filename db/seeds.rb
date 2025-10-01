# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 创建管理员用户
admin = User.create!(
  email_address: "admin@teddy.com",
  password: "password123",
  password_confirmation: "password123",
  role: :admin,
  first_name: "Admin",
  last_name: "User",
  tel: "+1-555-0100",
  allow_sms_messages: true,
  allow_email_messages: true
)

# 创建普通用户
user = User.create!(
  email_address: "user@teddy.com",
  password: "password123",
  password_confirmation: "password123",
  role: :user,
  first_name: "John",
  middle_initial: "M",
  last_name: "Doe",
  tel: "+1-555-0101",
  allow_sms_messages: true,
  allow_email_messages: true
)

# 创建更多测试用户
user2 = User.create!(
  email_address: "jane@teddy.com",
  password: "password123",
  password_confirmation: "password123",
  role: :user,
  first_name: "Jane",
  last_name: "Smith",
  tel: "+1-555-0102",
  allow_sms_messages: false,
  allow_email_messages: true
)

puts "Created admin: #{admin.full_name} (#{admin.email_address})"
puts "Created user: #{user.full_name} (#{user.email_address})"
puts "Created user: #{user2.full_name} (#{user2.email_address})"
