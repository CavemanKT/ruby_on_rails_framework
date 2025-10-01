# 🎯 管理员面板使用指南

## 📍 管理员入口

### URL 路径
```
主入口: http://localhost:3000/admin
或访问: http://localhost:3000/admin/dashboard
```

### 登录方式

1. **访问登录页面**: http://localhost:3000/session/new
2. **使用管理员账号登录**:
   - Email: `admin@teddy.com`
   - Password: `password123`
3. **自动跳转**: 登录后自动跳转到管理员仪表盘

### 测试账号

| 角色 | Email | 密码 | 登录后跳转 |
|------|-------|------|------------|
| 管理员 | admin@teddy.com | password123 | `/admin` (管理员面板) |
| 普通用户 | user@teddy.com | password123 | `/home/index` (用户主页) |
| 普通用户 | jane@teddy.com | password123 | `/home/index` (用户主页) |

---

## 🎨 管理员面板功能

### 1. Dashboard (仪表盘)
**路径**: `/admin`

**功能**:
- ✅ 实时统计数据
  - 总用户数 / 今日新增
  - 待处理举报数 / 总举报数
  - 活跃封禁数
  - 今日管理员操作数
- ✅ 最近的举报列表 (10条)
- ✅ 最近注册的用户 (10条)
- ✅ 活跃封禁列表
- ✅ 最近的管理员操作 (10条)

**卡片数据**:
```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Total Users │  │   Pending   │  │ Active Bans │  │   Actions   │
│     +N      │  │   Reports   │  │             │  │    Today    │
└─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘
```

### 2. Reports (举报管理)
**路径**: `/admin/reports`

**功能**:
- 查看所有举报 (最多50条)
- 按原因筛选
- 按状态筛选
- 查看举报详情
- 处理举报 (resolve/dismiss)

**状态说明**:
- `pending` - 待处理
- `reviewing` - 审核中
- `resolved` - 已处理
- `dismissed` - 已驳回

### 3. Users (用户管理)
**路径**: `/admin/users`

**功能**:
- 查看所有用户 (最多50条)
- 搜索用户 (按邮箱、姓名)
- 按角色筛选
- 查看用户详情
- 封禁/解封用户

**统计数据**:
- 总用户数
- 管理员数量
- 被封禁用户数

### 4. Activity Log (活动日志)
**路径**: `/admin/activity_log`

**功能**:
- 查看所有管理员操作 (最多100条)
- 按管理员筛选
- 按操作类型筛选
- 显示操作详情 (IP地址、时间戳)

---

## 🔧 技术实现

### Controller 层次结构

```
ApplicationController
  ├── Authentication (认证)
  └── Authorization (授权)
      └── Admin::BaseController
          ├── Admin::DashboardController
          ├── Admin::ReportsController
          ├── Admin::UsersController
          └── Admin::ActivityLogController
```

### 权限控制

**Admin::BaseController** 自动:
1. ✅ 要求管理员权限 (`require_admin`)
2. ✅ 使用管理员布局 (`layout "admin"`)
3. ✅ 记录所有操作 (`before_action :log_admin_access`)

### 自动功能

#### 操作日志
所有管理员操作自动记录到 `admin_actions` 表:
```ruby
AdminAction.log_action(
  admin: current_user,
  action_type: "controller#action",
  details: { ... },
  request: request
)
```

记录内容:
- 管理员 ID
- 操作类型
- 目标类型和 ID
- 详细参数 (过滤敏感信息)
- IP 地址
- User Agent
- 时间戳

#### 角色检查
登录后自动检查角色:
```ruby
if user.admin?
  redirect_to admin_root_path  # 管理员 → 管理面板
else
  redirect_to after_authentication_url  # 普通用户 → 主页
end
```

---

## 🎨 UI 特性

### 布局特点

1. **侧边栏导航**
   - Dashboard (仪表盘)
   - Reports (带待处理数量徽章)
   - Users (用户管理)
   - Activity Log (活动日志)

2. **顶部导航栏**
   - Logo 和标题
   - 返回主站按钮
   - 深色模式切换
   - 用户菜单

3. **响应式设计**
   - 移动端: 可折叠侧边栏
   - 桌面端: 固定侧边栏
   - 自适应布局

4. **深色模式支持**
   - 自动跟随系统设置
   - 手动切换
   - 持久化保存

### 颜色主题

| 元素 | 颜色 |
|------|------|
| 主色调 | Purple (管理员专属) |
| 成功 | Green |
| 警告 | Yellow |
| 危险 | Red |
| 信息 | Blue |

---

## 📊 API 路由

### 路由列表

```ruby
# Dashboard
GET    /admin                    # 仪表盘

# Reports
GET    /admin/reports            # 举报列表
GET    /admin/reports/:id        # 举报详情
POST   /admin/reports/:id/resolve # 处理举报
POST   /admin/reports/:id/dismiss # 驳回举报

# Users
GET    /admin/users              # 用户列表
GET    /admin/users/:id          # 用户详情
POST   /admin/users/:id/ban      # 封禁用户
POST   /admin/users/:id/unban    # 解封用户

# Activity Log
GET    /admin/activity_log       # 活动日志
```

### 使用示例

#### 查看仪表盘
```bash
curl http://localhost:3000/admin
```

#### 处理举报
```bash
curl -X POST http://localhost:3000/admin/reports/1/resolve \
  -d "admin_note=Resolved: Content removed"
```

#### 封禁用户
```bash
curl -X POST http://localhost:3000/admin/users/2/ban \
  -d "reason=Violated community guidelines" \
  -d "duration=7_days"
```

---

## 🔒 安全特性

### 1. 权限验证
- ✅ 所有管理员路由需要登录
- ✅ 所有操作需要管理员权限
- ✅ 自动检查封禁状态

### 2. 操作审计
- ✅ 所有管理员操作自动记录
- ✅ 记录 IP 地址和 User Agent
- ✅ 敏感参数自动过滤

### 3. Session 安全
- ✅ HttpOnly Cookie
- ✅ Same-Site: Lax
- ✅ Secure (生产环境)
- ✅ 自动过期管理

---

## 🚀 快速开始

### 1. 启动服务器
```bash
cd /Users/ralap9/code/mvp/teddy_ruby_on_rail_2/teddy1
bin/dev
```

### 2. 访问管理员面板
```
浏览器打开: http://localhost:3000/admin
```

### 3. 登录
```
Email: admin@teddy.com
Password: password123
```

### 4. 探索功能
- 查看仪表盘统计
- 浏览举报列表
- 管理用户
- 查看活动日志

---

## 📱 截图预览

### Dashboard (仪表盘)
```
┌─────────────────────────────────────────────────────┐
│  Admin Panel > Dashboard        [Back] [Theme] [@]  │
├─────────────────────────────────────────────────────┤
│  Welcome back, Admin User!                          │
│                                                      │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐        │
│  │Total Users│ │  Pending  │ │Active Bans│        │
│  │    3      │ │ Reports: 0│ │     0     │        │
│  └───────────┘ └───────────┘ └───────────┘        │
│                                                      │
│  Recent Reports          Recent Users               │
│  ┌─────────────────┐    ┌─────────────────┐       │
│  │ No reports yet  │    │ • Admin User    │       │
│  └─────────────────┘    │ • John M Doe    │       │
│                         │ • Jane Smith    │       │
│                         └─────────────────┘       │
└─────────────────────────────────────────────────────┘
```

---

## 🔗 相关文档

- `docs/AUTHENTICATION_AUTHORIZATION.md` - 认证授权完整指南
- `docs/AUTH_QUICK_REFERENCE.md` - 认证授权快速参考
- `requirements/admin_features.md` - 管理员功能详细规划
- `docs/AUTHORIZATION.md` - 角色授权系统

---

## 🆘 常见问题

### Q: 如何访问管理员面板?
**A**: 
1. 访问 http://localhost:3000/session/new
2. 使用管理员账号登录 (admin@teddy.com / password123)
3. 自动跳转到 /admin

### Q: 普通用户能否访问管理员面板?
**A**: 不能。所有 `/admin/*` 路由都需要管理员权限。普通用户访问会被重定向到首页并显示错误消息。

### Q: 如何创建新的管理员?
**A**: 
```bash
# 使用 Rails console
bin/rails console
User.create!(
  email_address: "new_admin@example.com",
  password: "password",
  role: :admin,
  first_name: "New",
  last_name: "Admin"
)
```

### Q: 管理员操作会被记录吗?
**A**: 是的。所有管理员操作都会自动记录到 `admin_actions` 表，包括 IP 地址和时间戳。可以在 Activity Log 页面查看。

### Q: 如何查看所有路由?
**A**: 
```bash
bin/rails routes | grep admin
```

---

**文档版本**: v1.0  
**最后更新**: 2025-10-01  
**维护者**: Development Team

