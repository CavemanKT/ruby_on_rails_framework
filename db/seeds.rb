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
admin = User.find_or_create_by!(email_address: "admin@teddy.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :admin
  u.first_name = "Admin"
  u.last_name = "User"
  u.nickname = "admin"
  u.bio = "Community administrator helping to keep Teddy a safe and supportive space."
  u.tel = "+1-555-0100"
  u.allow_sms_messages = true
  u.allow_email_messages = true
  u.calm_points = 100
end

# 创建普通用户
user = User.find_or_create_by!(email_address: "user@teddy.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :user
  u.first_name = "John"
  u.middle_initial = "M"
  u.last_name = "Doe"
  u.nickname = "john_doe"
  u.bio = "Mental health advocate and mindfulness enthusiast. Here to support others on their journey."
  u.tel = "+1-555-0101"
  u.allow_sms_messages = true
  u.allow_email_messages = true
  u.calm_points = 50
end

# 创建更多测试用户
user2 = User.find_or_create_by!(email_address: "jane@teddy.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :user
  u.first_name = "Jane"
  u.last_name = "Smith"
  u.nickname = "jane_smith"
  u.bio = "Yoga instructor and meditation teacher. Sharing wisdom and connecting with like-minded souls."
  u.tel = "+1-555-0102"
  u.allow_sms_messages = false
  u.allow_email_messages = true
  u.calm_points = 75
end

puts "Created admin: #{admin.full_name} (#{admin.email_address})"
puts "Created user: #{user.full_name} (#{user.email_address})"
puts "Created user: #{user2.full_name} (#{user2.email_address})"

# 创建示例帖子
sample_posts = [
  {
    user: user,
    content: "Feeling grateful today for the small moments of peace I found during my morning meditation. Sometimes it's the quiet moments that remind us of what truly matters. #gratitude #mindfulness #peace",
    visibility: :public_post
  },
  {
    user: user2,
    content: "Just completed my first 5-minute breathing exercise! The 4-4-6 technique really helped me center myself before an important meeting. Highly recommend trying it if you're feeling anxious. #breathing #anxiety #wellness",
    visibility: :public_post
  },
  {
    user: admin,
    content: "Welcome to the Teddy community! This is a safe space for sharing, supporting, and growing together. Remember to be kind, respectful, and supportive of one another. #community #welcome #support",
    visibility: :public_post
  },
  {
    user: user,
    content: "Having a tough day today, but I'm reminded that it's okay to not be okay. Taking it one breath at a time and reaching out to my support network. Thank you for being here. #support #mentalhealth #struggle",
    visibility: :circle
  }
]

sample_posts.each do |post_data|
  post = Post.find_or_create_by!(content: post_data[:content], user: post_data[:user]) do |p|
    p.visibility = post_data[:visibility]
    p.likes_count = rand(0..10)
    p.comments_count = rand(0..5)
  end
  puts "Created post: #{post.content[0..50]}..."
end

# 创建示例评论
sample_comments = [
  {
    post: Post.first,
    user: user2,
    content: "Thank you for sharing this. Your words really resonate with me today. Gratitude practice has been such a game-changer for my mental health."
  },
  {
    post: Post.second,
    user: admin,
    content: "Congratulations on trying the breathing exercise! It's amazing how such simple techniques can have such profound effects. Keep up the great work!"
  }
]

sample_comments.each do |comment_data|
  comment = Comment.find_or_create_by!(content: comment_data[:content], post: comment_data[:post], user: comment_data[:user])
  puts "Created comment: #{comment.content[0..50]}..."
end

# 创建示例呼吸练习记录
breathing_sessions = [
  {
    user: user,
    duration: 70, # 5 cycles * 14 seconds per cycle
    completed: true,
    calm_points_earned: 10
  },
  {
    user: user2,
    duration: 140, # 10 cycles
    completed: true,
    calm_points_earned: 10
  }
]

breathing_sessions.each do |session_data|
  session = BreathingSession.find_or_create_by!(
    user: session_data[:user],
    duration: session_data[:duration],
    created_at: rand(1..30).days.ago
  ) do |s|
    s.completed = session_data[:completed]
    s.calm_points_earned = session_data[:calm_points_earned]
  end
  puts "Created breathing session: #{session.duration}s for #{session.user.nickname}"
end

puts "\n🎉 Seed data created successfully!"
puts "You can now log in with:"
puts "- Admin: admin@teddy.com / password123"
puts "- User: user@teddy.com / password123"
puts "- User: jane@teddy.com / password123"
