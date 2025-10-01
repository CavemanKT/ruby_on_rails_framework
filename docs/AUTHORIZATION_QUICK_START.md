# 🚀 Authorization Quick Start - 角色授权快速开始

## 测试账号

已创建以下测试账号：

| 角色 | Email | 密码 |
|------|-------|------|
| 管理员 | admin@teddy.com | password123 |
| 普通用户 | user@teddy.com | password123 |

## 最常用的 3 个用法

### 1️⃣ 在 Controller 中要求管理员权限

```ruby
class Admin::DashboardController < ApplicationController
  require_admin  # 整个 controller 需要管理员权限
  
  def index
    # 只有管理员能访问这里
  end
end
```

### 2️⃣ 在 View 中根据角色显示内容

```erb
<% if admin? %>
  <%= link_to "Delete", post_path(@post), data: { turbo_method: :delete } %>
<% end %>
```

### 3️⃣ 在 Action 中检查权限

```ruby
def destroy
  @post = Post.find(params[:id])
  
  if admin? || @post.user == current_user
    @post.destroy
    redirect_to posts_path, notice: "Deleted!"
  else
    redirect_to posts_path, alert: "Permission denied."
  end
end
```

## 可用的 Helper 方法

在 Controller 和 View 中都可以使用：

```ruby
current_user       # 当前登录的用户对象
current_user.admin? # 检查是否为管理员
admin?             # 等同于 current_user&.admin?
authenticated?     # 检查是否已登录
```

## 创建新管理员

```bash
# 方法 1: 使用 Rails console
bin/rails console
User.create!(email_address: "new_admin@example.com", password: "password", role: :admin)

# 方法 2: 将现有用户升级为管理员
user = User.find_by(email_address: "user@example.com")
user.update!(role: :admin)
```

## 测试权限

启动服务器并测试：

```bash
bin/dev

# 访问 http://localhost:3000
# 使用 admin@teddy.com / password123 登录测试管理员功能
# 使用 user@teddy.com / password123 登录测试普通用户功能
```

## 下一步

阅读完整文档：`docs/AUTHORIZATION.md`

