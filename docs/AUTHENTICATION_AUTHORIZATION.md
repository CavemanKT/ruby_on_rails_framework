# Authentication & Authorization Guide

## 📋 概述

Teddy 应用使用两个独立的 Concerns 来处理认证和授权：

- **Authentication** (`app/controllers/concerns/authentication.rb`) - 处理用户认证（登录、登出、Session 管理）
- **Authorization** (`app/controllers/concerns/authorization.rb`) - 处理用户授权（权限检查、角色验证）

两者已自动包含在 `ApplicationController` 中，所有 controller 都可以使用。

---

## 🔐 Authentication (认证)

### 核心功能

#### 1. 自动认证检查
默认情况下，所有 controller 都需要用户登录：

```ruby
class PostsController < ApplicationController
  # 所有 action 都需要登录
end
```

#### 2. 允许未认证访问
使用 `allow_unauthenticated_access` 允许特定 action 无需登录：

```ruby
class PostsController < ApplicationController
  allow_unauthenticated_access only: [:index, :show]
  
  def index
    # 任何人都可以访问
  end
  
  def create
    # 需要登录
  end
end
```

#### 3. 自动封禁检查
登录后自动检查用户是否被封禁，封禁用户将被强制登出。

### 可用方法

#### `authenticated?`
检查用户是否已登录：

```ruby
if authenticated?
  # 用户已登录
else
  # 用户未登录
end
```

#### `current_user`
获取当前登录用户：

```ruby
def show
  @post = current_user.posts.find(params[:id])
end
```

#### `start_new_session_for(user)`
为用户创建新 session（登录）：

```ruby
def create
  user = User.authenticate_by(params.permit(:email_address, :password))
  if user
    start_new_session_for(user)
    redirect_to root_path, notice: "Welcome back!"
  else
    redirect_to new_session_path, alert: "Invalid credentials"
  end
end
```

#### `terminate_session`
终止当前 session（登出）：

```ruby
def destroy
  terminate_session
  redirect_to new_session_path, notice: "You have been logged out"
end
```

#### `after_authentication_url`
获取登录后应跳转的 URL（自动处理"登录前的页面"逻辑）：

```ruby
def create
  user = User.authenticate_by(params.permit(:email_address, :password))
  if user
    start_new_session_for(user)
    redirect_to after_authentication_url
  end
end
```

---

## 🛡️ Authorization (授权)

### 核心功能

#### 1. 要求管理员权限
使用 `require_admin` 限制特定 action 只能由管理员访问：

```ruby
class Admin::DashboardController < ApplicationController
  require_admin  # 所有 action 都需要管理员权限
  
  def index
    # 只有管理员能访问
  end
end

class PostsController < ApplicationController
  require_admin only: [:destroy]  # 只有 destroy 需要管理员权限
  
  def destroy
    @post.destroy
    redirect_to posts_path
  end
end
```

#### 2. 要求特定角色
使用 `require_role` 要求特定角色：

```ruby
class ModeratorController < ApplicationController
  require_role :moderator, only: [:review]
end
```

#### 3. 要求资源所有权
使用 `require_ownership` 确保用户只能修改自己的资源：

```ruby
class PostsController < ApplicationController
  require_ownership :post, only: [:edit, :update, :destroy]
  
  def edit
    @post = Post.find(params[:id])
    # 自动检查 current_user 是否为 @post 的所有者
  end
end
```

### 可用方法

#### `admin?`
检查当前用户是否为管理员：

```ruby
<% if admin? %>
  <%= link_to "Delete", post_path(@post), method: :delete %>
<% end %>
```

#### `current_user_is_owner?(resource)`
检查当前用户是否为资源所有者：

```ruby
def show
  @post = Post.find(params[:id])
  if current_user_is_owner?(@post)
    # 用户是帖子作者
  end
end
```

#### `can_manage?(resource)`
检查用户是否可以管理资源（管理员或所有者）：

```ruby
def destroy
  @post = Post.find(params[:id])
  if can_manage?(@post)
    @post.destroy
    redirect_to posts_path
  else
    redirect_to @post, alert: "You can't delete this post"
  end
end
```

#### `authorize(action, resource)`
灵活的授权检查：

```ruby
def show
  @post = Post.find(params[:id])
  unless authorize(:view, @post)
    redirect_to root_path, alert: "You can't view this post"
  end
end
```

支持的 actions:
- `:manage`, `:edit`, `:update`, `:destroy` - 需要所有者或管理员
- `:view`, `:show` - 根据资源可见性判断
- `:create` - 需要登录

#### `authorize!(action, resource)`
强制授权检查（失败时自动重定向）：

```ruby
def destroy
  @post = Post.find(params[:id])
  authorize!(:manage, @post)
  @post.destroy
  redirect_to posts_path
end
```

---

## 📚 使用示例

### 示例 1: 基础 CRUD Controller

```ruby
class PostsController < ApplicationController
  # 允许未登录用户浏览
  allow_unauthenticated_access only: [:index, :show]
  
  # 只有所有者或管理员可以编辑/删除
  require_ownership :post, only: [:edit, :update, :destroy]
  
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
  def index
    @posts = Post.all
  end
  
  def show
    # 检查可见性
    unless authorize(:view, @post)
      redirect_to posts_path, alert: "You can't view this post"
    end
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: "Post created!"
    else
      render :new
    end
  end
  
  def edit
    # require_ownership 已经检查了权限
  end
  
  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated!"
    else
      render :edit
    end
  end
  
  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post deleted!"
  end
  
  private
    def set_post
      @post = Post.find(params[:id])
    end
    
    def post_params
      params.require(:post).permit(:title, :content, :visibility)
    end
end
```

### 示例 2: 管理员 Controller

```ruby
class Admin::ReportsController < ApplicationController
  # 所有 action 都需要管理员权限
  require_admin
  
  def index
    @reports = Report.pending.recent
  end
  
  def show
    @report = Report.find(params[:id])
  end
  
  def resolve
    @report = Report.find(params[:id])
    @report.resolve!(
      admin: current_user,
      note: params[:admin_note]
    )
    redirect_to admin_reports_path, notice: "Report resolved"
  end
end
```

### 示例 3: 在 View 中使用

```erb
<!-- 显示管理员专属链接 -->
<% if admin? %>
  <%= link_to "Admin Dashboard", admin_root_path, class: "nav-link" %>
<% end %>

<!-- 显示所有者专属按钮 -->
<% if current_user_is_owner?(@post) %>
  <%= link_to "Edit", edit_post_path(@post) %>
  <%= link_to "Delete", post_path(@post), method: :delete %>
<% end %>

<!-- 显示管理或所有者按钮 -->
<% if can_manage?(@post) %>
  <%= link_to "Manage", manage_post_path(@post) %>
<% end %>

<!-- 条件渲染 -->
<% if authenticated? %>
  <p>Welcome, <%= current_user.full_name %>!</p>
<% else %>
  <%= link_to "Sign In", new_session_path %>
<% end %>
```

---

## 🔒 安全特性

### 1. 封禁用户自动登出
用户被封禁后：
- 下次请求时自动检测并强制登出
- 显示封禁原因和到期时间
- 无法创建新 session

### 2. Session 安全
- Cookie 使用 `httponly` 标志（防止 XSS）
- 生产环境启用 `secure` 标志（HTTPS only）
- `same_site: :lax` 防止 CSRF

### 3. N+1 查询优化
```ruby
# 自动预加载用户和封禁记录
session&.then { |s| Session.includes(user: :bans).find(s.id) }
```

### 4. 记录原始请求 URL
登录后自动返回用户尝试访问的页面：
```ruby
session[:return_to_after_authenticating] = request.url
```

### 5. 多格式响应
`handle_unauthorized` 方法支持：
- HTML (重定向)
- JSON (返回错误)
- Turbo Stream (局部更新)

---

## 🧪 测试示例

### Authentication 测试

```ruby
# test/controllers/posts_controller_test.rb
class PostsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication for create" do
    post posts_path, params: { post: { title: "Test" } }
    assert_redirected_to new_session_path
  end
  
  test "allows unauthenticated access to index" do
    get posts_path
    assert_response :success
  end
  
  test "creates post when authenticated" do
    sign_in_as(users(:john))
    assert_difference "Post.count" do
      post posts_path, params: { post: { title: "Test", content: "Content" } }
    end
  end
end
```

### Authorization 测试

```ruby
class PostsControllerTest < ActionDispatch::IntegrationTest
  test "user can edit own post" do
    user = users(:john)
    post = posts(:johns_post)
    sign_in_as(user)
    
    get edit_post_path(post)
    assert_response :success
  end
  
  test "user cannot edit others post" do
    user = users(:john)
    post = posts(:janes_post)
    sign_in_as(user)
    
    get edit_post_path(post)
    assert_redirected_to root_path
  end
  
  test "admin can edit any post" do
    admin = users(:admin)
    post = posts(:johns_post)
    sign_in_as(admin)
    
    get edit_post_path(post)
    assert_response :success
  end
end
```

### 测试辅助方法

```ruby
# test/test_helper.rb
def sign_in_as(user)
  post session_path, params: { 
    email_address: user.email_address, 
    password: "password123" 
  }
end
```

---

## 🎯 最佳实践

### 1. 优先使用声明式授权
```ruby
# 推荐
class PostsController < ApplicationController
  require_ownership :post, only: [:edit, :update]
end

# 不推荐（手动检查）
class PostsController < ApplicationController
  def edit
    @post = Post.find(params[:id])
    unless current_user_is_owner?(@post)
      redirect_to root_path
    end
  end
end
```

### 2. 分离认证和授权逻辑
- Authentication concern: 处理"你是谁"
- Authorization concern: 处理"你能做什么"

### 3. 使用 `can_manage?` 简化逻辑
```ruby
# 推荐
if can_manage?(@post)
  @post.destroy
end

# 不推荐
if admin? || current_user_is_owner?(@post)
  @post.destroy
end
```

### 4. 在 View 中隐藏 UI + 在 Controller 中强制检查
```erb
<!-- View: 隐藏按钮 -->
<% if can_manage?(@post) %>
  <%= link_to "Delete", post_path(@post), method: :delete %>
<% end %>
```

```ruby
# Controller: 强制检查
def destroy
  @post = Post.find(params[:id])
  authorize!(:manage, @post)
  @post.destroy
end
```

---

## 📖 相关文档

- `docs/AUTHORIZATION.md` - 角色系统详细文档
- `docs/AUTHORIZATION_QUICK_START.md` - 快速开始指南
- `requirements/admin_features.md` - 管理员功能规划

---

## 🔄 更新记录

- **v1.0** (2025-10-01): 初始版本，Authentication 和 Authorization 分离
  - 添加封禁用户检查
  - 优化 N+1 查询
  - 增强安全性（secure cookie, session 清理）
  - 添加灵活的授权方法
  - 支持多格式响应

---

**文档版本**: v1.0  
**最后更新**: 2025-10-01  
**维护者**: Development Team

