# 🚀 Authentication & Authorization Quick Reference

## 🔐 Authentication (认证)

### Controller 类方法

| 方法 | 用途 | 示例 |
|------|------|------|
| `allow_unauthenticated_access` | 允许未登录访问 | `allow_unauthenticated_access only: [:index]` |

### 实例方法

| 方法 | 返回值 | 用途 |
|------|--------|------|
| `authenticated?` | Boolean | 检查是否已登录 |
| `current_user` | User/nil | 获取当前用户 |
| `start_new_session_for(user)` | Session | 创建登录 session |
| `terminate_session` | void | 登出 |
| `after_authentication_url` | String | 登录后跳转 URL |

---

## 🛡️ Authorization (授权)

### Controller 类方法

| 方法 | 用途 | 示例 |
|------|------|------|
| `require_admin` | 要求管理员权限 | `require_admin only: [:destroy]` |
| `require_role` | 要求特定角色 | `require_role :moderator, only: [:review]` |
| `require_ownership` | 要求资源所有权 | `require_ownership :post, only: [:edit]` |

### 实例方法

| 方法 | 返回值 | 用途 |
|------|--------|------|
| `admin?` | Boolean | 是否为管理员 |
| `current_user_is_owner?(resource)` | Boolean | 是否为资源所有者 |
| `can_manage?(resource)` | Boolean | 是否可以管理（管理员或所有者） |
| `authorize(action, resource)` | Boolean | 检查权限 |
| `authorize!(action, resource)` | void | 强制权限检查（失败重定向） |

---

## 📋 常用模式

### 1. 公开浏览 + 登录操作
```ruby
class PostsController < ApplicationController
  allow_unauthenticated_access only: [:index, :show]
end
```

### 2. 管理员专用
```ruby
class Admin::DashboardController < ApplicationController
  require_admin
end
```

### 3. 所有者或管理员可编辑
```ruby
class PostsController < ApplicationController
  require_ownership :post, only: [:edit, :update, :destroy]
end
```

### 4. View 中条件显示
```erb
<% if admin? %>
  <%= link_to "Delete", admin_path %>
<% end %>

<% if current_user_is_owner?(@post) %>
  <%= link_to "Edit", edit_post_path(@post) %>
<% end %>

<% if can_manage?(@post) %>
  <%= link_to "Manage", manage_post_path(@post) %>
<% end %>
```

---

## 🎯 快速决策树

**需要登录？**
- ✅ 默认所有 action 需要登录
- ❌ 使用 `allow_unauthenticated_access`

**需要特定角色？**
- 管理员 → `require_admin`
- 其他角色 → `require_role :role_name`

**需要资源所有权？**
- 编辑/删除自己的资源 → `require_ownership :resource_name`
- 管理员也能操作 → 自动支持（`can_manage?` 检查）

**复杂权限逻辑？**
- 使用 `authorize(action, resource)` 或 `authorize!(action, resource)`

---

## 🔒 安全要点

✅ **默认需要登录** - 除非明确声明 `allow_unauthenticated_access`  
✅ **自动检查封禁** - 被封禁用户自动登出  
✅ **Session 安全** - httponly, secure (生产), same_site  
✅ **View + Controller 双重检查** - 隐藏 UI + 强制权限  

---

**完整文档**: `docs/AUTHENTICATION_AUTHORIZATION.md`

