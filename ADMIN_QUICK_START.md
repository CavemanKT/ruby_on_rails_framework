# 🚀 管理员面板 - 快速开始

## ⚡ 立即访问

### 1. 启动服务器
```bash
bin/dev
```

### 2. 打开浏览器访问
```
http://localhost:3000/admin
```

### 3. 使用管理员账号登录
```
Email: admin@teddy.com
Password: password123
```

### 4. 自动跳转到管理员面板！ ✨

---

## 📍 管理员 URL 路径

| 页面 | URL | 说明 |
|------|-----|------|
| 🏠 仪表盘 | `/admin` | 主入口，统计概览 |
| 📢 举报管理 | `/admin/reports` | 查看和处理举报 |
| 👥 用户管理 | `/admin/users` | 管理所有用户 |
| 📝 活动日志 | `/admin/activity_log` | 查看管理员操作记录 |

---

## 🎯 核心功能

### ✅ 已实现
- 管理员角色系统
- 自动权限检查
- 管理员仪表盘
- 操作日志记录
- 封禁系统
- 举报系统
- 美观的 UI (Tailwind + Flowbite)
- 深色模式支持

### 🔄 占位实现
- Reports 列表视图 (控制器已实现)
- Users 列表视图 (控制器已实现)
- Activity Log 列表视图 (控制器已实现)

---

## 📊 测试账号

| 用户名 | Email | 密码 | 角色 | 登录后跳转 |
|--------|-------|------|------|------------|
| Admin User | admin@teddy.com | password123 | Admin | `/admin` ⭐ |
| John M Doe | user@teddy.com | password123 | User | `/home/index` |
| Jane Smith | jane@teddy.com | password123 | User | `/home/index` |

---

## 🎨 UI 预览

### 侧边栏菜单
```
┌─────────────────┐
│ 🧸 Teddy Admin  │
├─────────────────┤
│ 📊 Dashboard    │
│ 📢 Reports (0)  │
│ 👥 Users        │
│ 📝 Activity Log │
└─────────────────┘
```

### 仪表盘卡片
```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│Total Users  │  │  Pending    │  │Active Bans  │
│     3       │  │ Reports: 0  │  │     0       │
│  +3 today   │  │  0 total    │  │             │
└─────────────┘  └─────────────┘  └─────────────┘
```

---

## 💡 下一步

完整文档请查看:
- 📖 `docs/ADMIN_PANEL_GUIDE.md` - 详细使用指南
- 🔐 `docs/AUTHENTICATION_AUTHORIZATION.md` - 认证授权文档
- 📋 `requirements/admin_features.md` - 功能规划

---

**快速测试**: 访问 http://localhost:3000/admin 立即体验！

