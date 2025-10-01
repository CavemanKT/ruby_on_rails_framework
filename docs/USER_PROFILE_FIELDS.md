# User Profile Fields - 用户资料字段

## 📋 新增字段说明

### 个人信息字段

| 字段名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `first_name` | string | 否 | 名字 | "John" |
| `middle_initial` | string(1) | 否 | 中间名首字母（限1字符） | "M" |
| `last_name` | string | 否 | 姓氏 | "Doe" |
| `tel` | string | 否 | 电话号码 | "+1-555-0100" |

### 通知偏好设置

| 字段名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `allow_sms_messages` | boolean | `true` | 是否允许接收短信通知 |
| `allow_email_messages` | boolean | `true` | 是否允许接收邮件通知 |

## 🔧 验证规则

### first_name / last_name
- 可选字段
- 最大长度: 50 字符

### middle_initial
- 可选字段
- 严格限制: 1 字符
- 用于存储中间名的首字母（如 "M" for "Michael"）

### tel
- 可选字段
- 最大长度: 20 字符
- 格式验证: 允许 `+`、数字、空格、`-`、`.`、`()`
- 有效示例:
  - `+1-555-0100`
  - `(555) 123-4567`
  - `555.123.4567`
  - `+1 555 123 4567`

### allow_sms_messages / allow_email_messages
- 必填字段（boolean）
- 默认值: `true`
- 用于用户通知偏好设置

## 🎯 便捷方法

### `full_name`
返回用户的完整姓名。

**规则**:
- 如果有姓名字段，则拼接 `first_name` + `middle_initial` + `last_name`
- 如果没有任何姓名字段，则返回邮箱前缀

**示例**:
```ruby
user = User.create!(
  email_address: "john@example.com",
  first_name: "John",
  middle_initial: "M",
  last_name: "Doe"
)
user.full_name  # => "John M Doe"

user2 = User.create!(email_address: "jane@example.com")
user2.full_name  # => "jane"
```

### `display_name`
返回用户的显示名称（当前等同于 `full_name`）。

### `formatted_tel`
返回格式化的电话号码（移除所有非数字和非+号字符）。

**示例**:
```ruby
user.tel = "+1 (555) 123-4567"
user.formatted_tel  # => "+15551234567"
```

### `sms_enabled?`
检查用户是否启用短信通知。

**条件**: 
- `allow_sms_messages` 为 `true`
- 且 `tel` 字段不为空

**示例**:
```ruby
user.allow_sms_messages = true
user.tel = "+1-555-0100"
user.sms_enabled?  # => true

user2.allow_sms_messages = true
user2.tel = nil
user2.sms_enabled?  # => false
```

### `email_enabled?`
检查用户是否启用邮件通知。

**条件**:
- `allow_email_messages` 为 `true`
- 且 `email_address` 不为空

## 💾 数据库索引

为优化查询性能，已添加以下索引:
- `users.tel` - 单列索引
- `users(first_name, last_name)` - 复合索引

## 🧪 测试示例

### 创建带完整资料的用户
```ruby
user = User.create!(
  email_address: "john@teddy.com",
  password: "password123",
  first_name: "John",
  middle_initial: "M",
  last_name: "Doe",
  tel: "+1-555-0100",
  allow_sms_messages: true,
  allow_email_messages: true
)

puts user.full_name        # => "John M Doe"
puts user.sms_enabled?     # => true
puts user.email_enabled?   # => true
```

### 创建最小资料用户
```ruby
user = User.create!(
  email_address: "minimal@teddy.com",
  password: "password123"
)

puts user.full_name        # => "minimal"
puts user.sms_enabled?     # => false (没有电话号码)
puts user.email_enabled?   # => true (默认允许邮件)
```

### 更新通知偏好
```ruby
user = User.find_by(email_address: "john@teddy.com")

# 禁用短信通知
user.update!(allow_sms_messages: false)
puts user.sms_enabled?  # => false

# 禁用邮件通知
user.update!(allow_email_messages: false)
puts user.email_enabled?  # => false
```

## 🎨 UI 使用示例

### 在视图中显示用户姓名
```erb
<div class="user-profile">
  <h2><%= current_user.full_name %></h2>
  <p><%= current_user.email_address %></p>
  
  <% if current_user.tel.present? %>
    <p>Phone: <%= current_user.tel %></p>
  <% end %>
</div>
```

### 通知偏好设置表单
```erb
<%= form_with model: @user, url: profile_path do |f| %>
  <div class="form-group">
    <%= f.label :first_name, "First Name" %>
    <%= f.text_field :first_name, class: "form-control" %>
  </div>
  
  <div class="form-group">
    <%= f.label :middle_initial, "Middle Initial" %>
    <%= f.text_field :middle_initial, maxlength: 1, class: "form-control" %>
  </div>
  
  <div class="form-group">
    <%= f.label :last_name, "Last Name" %>
    <%= f.text_field :last_name, class: "form-control" %>
  </div>
  
  <div class="form-group">
    <%= f.label :tel, "Phone Number" %>
    <%= f.text_field :tel, placeholder: "+1-555-0100", class: "form-control" %>
  </div>
  
  <div class="form-check">
    <%= f.check_box :allow_sms_messages, class: "form-check-input" %>
    <%= f.label :allow_sms_messages, "Allow SMS notifications", class: "form-check-label" %>
  </div>
  
  <div class="form-check">
    <%= f.check_box :allow_email_messages, class: "form-check-input" %>
    <%= f.label :allow_email_messages, "Allow email notifications", class: "form-check-label" %>
  </div>
  
  <%= f.submit "Update Profile", class: "btn btn-primary" %>
<% end %>
```

## 🔍 查询示例

### 查找允许短信通知的用户
```ruby
users_with_sms = User.where(allow_sms_messages: true).where.not(tel: nil)
```

### 查找允许邮件通知的用户
```ruby
users_with_email = User.where(allow_email_messages: true)
```

### 按姓名搜索
```ruby
User.where("first_name LIKE ? OR last_name LIKE ?", "%John%", "%John%")
```

## 📊 数据迁移记录

**迁移文件**: `db/migrate/20251001115145_add_user_profile_fields_to_users.rb`

**执行日期**: 2025-10-01

**影响**: 
- 为 `users` 表添加 6 个新字段
- 添加 2 个索引用于优化查询
- 现有用户数据不受影响（所有字段可选或有默认值）

---

**文档版本**: v1.0  
**最后更新**: 2025-10-01  
**维护者**: Development Team

