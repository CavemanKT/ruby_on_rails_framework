# 🧸 Teddy - Mental Health & Community Support Platform

Teddy 是一个专注于心理健康与情感支持的 Web 应用，致力于为用户提供一个宁静的数字庇护所。

## ✨ 核心功能

- 🔐 **用户认证系统** - 安全的登录、注册、密码重置
- 👨‍💼 **角色授权系统** - User 和 Admin 两种角色
- 🛡️ **管理员面板** - 完整的后台管理系统
- 📊 **统计仪表盘** - 实时数据概览
- 🚫 **用户封禁系统** - 临时/永久封禁管理
- 📢 **举报系统** - 内容审核和处理
- 📝 **操作日志** - 完整的审计追踪

## 🚀 快速开始

### 1. 系统要求
- Ruby 3.3.0+
- Rails 8.0
- Node.js (for asset compilation)

### 2. 安装
```bash
# 克隆项目
git clone <repository-url>
cd teddy1

# 安装依赖
bundle install

# 设置数据库
bin/rails db:setup

# 启动服务器
bin/dev
```

### 3. 访问应用
- **主站**: http://localhost:3000
- **管理员面板**: http://localhost:3000/admin ⭐

## 👥 测试账号

| 角色 | Email | 密码 | 说明 |
|------|-------|------|------|
| 管理员 | admin@teddy.com | password123 | 完整管理权限 |
| 用户 | user@teddy.com | password123 | John M Doe |
| 用户 | jane@teddy.com | password123 | Jane Smith |

## 📍 管理员面板入口

### 主要入口: `/admin`

**访问方式**:
1. 访问 http://localhost:3000/admin
2. 使用管理员账号登录
3. 自动跳转到管理员仪表盘

**功能页面**:
- `/admin` - 仪表盘 (统计概览)
- `/admin/reports` - 举报管理
- `/admin/users` - 用户管理
- `/admin/activity_log` - 活动日志

**特性**:
- ✅ 自动权限检查
- ✅ 美观的 UI (Tailwind + Flowbite)
- ✅ 响应式设计
- ✅ 深色模式支持
- ✅ 自动操作日志记录

## 🛠️ 技术栈

### 后端
- **Ruby on Rails 8** - Web 框架
- **SQLite** (development) / **PostgreSQL** (production)
- **Solid Queue** - 后台任务
- **Solid Cache** - 缓存系统
- **Action Cable** - WebSocket 实时通信

### 前端
- **Tailwind CSS 4.1.13** - CSS 框架
- **Flowbite 3.1.2** - UI 组件库
- **Stimulus.js** - JavaScript 框架
- **Turbo** - SPA-like 页面导航
- **Importmap** - JavaScript 模块管理

### 部署
- **Docker** - 容器化
- **Kamal** - 部署工具
- **Puma** - Web 服务器

## 📚 文档

### 快速开始
- 📖 `ADMIN_QUICK_START.md` - 管理员面板快速开始 ⭐
- 📖 `docs/AUTH_QUICK_REFERENCE.md` - 认证授权快速参考

### 核心系统
- 📖 `docs/AUTHENTICATION_AUTHORIZATION.md` - 认证授权完整指南
- 📖 `docs/ADMIN_PANEL_GUIDE.md` - 管理员面板详细指南
- 📖 `docs/USER_PROFILE_FIELDS.md` - 用户字段文档

### 功能规划
- 📖 `requirements/mvp.md` - MVP 规划文档
- 📖 `requirements/user_stories.md` - 用户故事 (70 stories)
- 📖 `requirements/admin_features.md` - 管理员功能规划

## 🧪 测试

```bash
# 运行所有测试
bin/rails test

# 运行特定测试
bin/rails test test/models/user_test.rb

# 检查代码风格
bin/rubocop

# 安全扫描
bin/brakeman
```

## 📂 项目结构

```
teddy1/
├── app/
│   ├── controllers/
│   │   ├── admin/              # 管理员控制器
│   │   └── concerns/           # 认证授权 Concerns
│   ├── models/                 # 数据模型
│   ├── views/
│   │   ├── admin/              # 管理员视图
│   │   └── layouts/            # 布局文件
│   └── javascript/             # Stimulus controllers
├── config/
│   ├── routes.rb               # 路由配置
│   └── ...
├── db/
│   ├── migrate/                # 数据库迁移
│   └── seeds.rb                # 种子数据
├── docs/                       # 技术文档
├── requirements/               # 需求文档
└── test/                       # 测试文件
```

## 🎯 开发进度

### Phase 1: 基础功能 ✅
- [x] 用户认证系统
- [x] 角色授权系统
- [x] 用户资料字段
- [x] 管理员面板基础

### Phase 2: 社区功能 (进行中)
- [ ] 发帖系统
- [ ] 评论互动
- [ ] 支持圈
- [ ] 积分系统

### Phase 3: 增强功能 (规划中)
- [ ] 呼吸练习
- [ ] 哲学思考
- [ ] 通知系统
- [ ] 统计分析

## 🔗 相关链接

- **Rails Guides**: https://guides.rubyonrails.org/
- **Tailwind CSS**: https://tailwindcss.com/
- **Flowbite**: https://flowbite.com/
- **Stimulus**: https://stimulus.hotwired.dev/

## 📄 License

This project is proprietary software.

---

**版本**: v0.1.0  
**最后更新**: 2025-10-01  
**维护者**: Development Team
