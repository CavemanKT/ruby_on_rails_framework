# Authorization System - 角色授权系统

## 📖 概述

Teddy 应用使用基于角色的授权系统 (RBAC - Role-Based Access Control)，支持两种用户角色：

- **User** (普通用户) - 默认角色
- **Admin** (管理员) - 拥有管理权限

## 🔧 实现细节

### 数据库字段

```ruby
# users 表
role: integer, default: 0, null: false
# 0 = user, 1 = admin
```

### User Model

```ruby
class User < ApplicationRecord
  enum :role, { user: 0, admin: 1 }, default: :user
end
```

自动生成的便捷方法：
- `user.user?` - 检查是否为普通用户
- `user.admin?` - 检查是否为管理员
- `user.role` - 返回角色名称字符串 ("user" 或 "admin")

## 🎯 使用方法

### 1. 在 Controller 中限制管理员访问

```ruby
class Admin::ReportsController < ApplicationController
  # 整个 controller 都要求管理员权限
  require_admin
  
  def index
    @reports = Report.pending
  end
end
```

### 2. 限制特定 action

```ruby
class PostsController < ApplicationController
  # 只有 destroy 需要管理员权限
  require_admin only: [:destroy]
  
  def index
    @posts = Post.all
  end
  
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "Post deleted."
  end
end
```

### 3. 在 action 中检查权限

```ruby
class PostsController < ApplicationController
  def destroy
    @post = Post.find(params[:id])
    
    # 管理员可以删除任何帖子，用户只能删除自己的
    if admin? || @post.user == current_user
      @post.destroy
      redirect_to posts_path, notice: "Post deleted successfully."
    else
      redirect_to posts_path, alert: "You cannot delete this post."
    end
  end
end
```

### 4. 在 View 中显示/隐藏功能

```erb
<%# 只对管理员显示删除按钮 %>
<% if admin? %>
  <%= link_to "Delete", post_path(@post), 
              data: { turbo_method: :delete, turbo_confirm: "Are you sure?" },
              class: "text-red-600 hover:text-red-800" %>
<% end %>

<%# 根据角色显示不同内容 %>
<% if current_user.admin? %>
  <div class="admin-panel">
    <%= link_to "Manage Reports", admin_reports_path %>
  </div>
<% end %>
```

### 5. 在路由中组织管理员功能

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # 公开路由
  resources :posts
  
  # 管理员命名空间
  namespace :admin do
    resources :reports
    resources :users
    root to: "dashboard#index"
  end
end
```

## 🔑 可用的 Helper 方法

在 Controller 和 View 中可用：

- `current_user` - 获取当前登录用户
- `admin?` - 检查当前用户是否为管理员
- `authenticated?` - 检查用户是否已登录

## 📝 创建管理员账号

### 通过 Seeds

```ruby
# db/seeds.rb
User.create!(
  email_address: "admin@teddy.com",
  password: "your_secure_password",
  role: :admin
)
```

### 通过 Rails Console

```ruby
# 进入 console
bin/rails console

# 创建新管理员
User.create!(
  email_address: "admin@example.com",
  password: "secure_password",
  role: :admin
)

# 或者将现有用户提升为管理员
user = User.find_by(email_address: "user@example.com")
user.update!(role: :admin)
```

### 通过 Rails Runner

```bash
bin/rails runner "User.create!(email_address: 'admin@example.com', password: 'password', role: :admin)"
```

## 🧪 测试

```ruby
# test/controllers/admin/reports_controller_test.rb
class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  test "admin can access reports" do
    admin = users(:admin)
    sign_in_as(admin)
    
    get admin_reports_path
    assert_response :success
  end
  
  test "regular user cannot access reports" do
    user = users(:regular_user)
    sign_in_as(user)
    
    get admin_reports_path
    assert_redirected_to root_path
    assert_equal "You don't have permission to access this page.", flash[:alert]
  end
end
```

## 🎨 UI 示例 (使用 Flowbite)

### 管理员导航菜单

```erb
<nav class="bg-white border-b border-gray-200">
  <div class="max-w-7xl mx-auto px-4">
    <div class="flex justify-between h-16">
      <!-- 左侧导航 -->
      <div class="flex">
        <%= link_to "Home", root_path, class: "px-3 py-2" %>
        <%= link_to "Posts", posts_path, class: "px-3 py-2" %>
        
        <!-- 管理员专属菜单 -->
        <% if admin? %>
          <div class="relative" data-controller="dropdown">
            <button class="px-3 py-2 text-gray-700 hover:text-gray-900">
              Admin
            </button>
            <div class="hidden absolute bg-white shadow-lg">
              <%= link_to "Reports", admin_reports_path, class: "block px-4 py-2" %>
              <%= link_to "Users", admin_users_path, class: "block px-4 py-2" %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
  </div>
</nav>
```

### 管理员徽章

```erb
<div class="flex items-center space-x-2">
  <%= image_tag current_user.avatar_url, class: "w-8 h-8 rounded-full" %>
  <span><%= current_user.nickname %></span>
  
  <% if current_user.admin? %>
    <span class="px-2 py-1 text-xs font-semibold text-purple-800 bg-purple-100 rounded-full">
      Admin
    </span>
  <% end %>
</div>
```

## 🔒 安全最佳实践

1. **永远在 Controller 中验证权限**，不要只在 View 中隐藏元素
2. **使用 before_action** 保护整个 controller 或特定 action
3. **记录敏感操作**，如管理员删除内容
4. **定期审查管理员账号**
5. **使用强密码**并考虑实施 2FA（未来功能）

## 🚀 未来扩展

可以轻松添加更多角色：

```ruby
# app/models/user.rb
enum :role, { 
  user: 0, 
  admin: 1,
  moderator: 2,  # 内容审核员
  counselor: 3   # 心理咨询师
}, default: :user
```

## 📚 相关文件

- `app/models/user.rb` - User model 和角色定义
- `app/controllers/concerns/authentication.rb` - 认证和授权逻辑
- `app/models/current.rb` - 当前用户上下文
- `db/migrate/XXXXXX_add_role_to_users.rb` - 角色字段迁移
- `test/models/user_test.rb` - 角色功能测试

## 🆘 常见问题

**Q: 如何检查用户的具体角色？**
```ruby
current_user.role # => "user" 或 "admin"
current_user.user? # => true 或 false
current_user.admin? # => true 或 false
```

**Q: 如何在 policy 中使用？**
```ruby
# 如果未来使用 Pundit
class PostPolicy
  def destroy?
    user.admin? || record.user == user
  end
end
```

**Q: 如何批量更新用户角色？**
```ruby
User.where(email_address: admin_emails).update_all(role: 1)
```

---

**文档版本**: v1.0  
**最后更新**: 2025-10-01  
**维护者**: Development Team

