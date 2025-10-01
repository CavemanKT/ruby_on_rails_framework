# Teddy Web Application - MVP 规划文档

## 📋 项目概述

**Teddy** 是一个专注于心理健康与情感支持的 Web 应用,致力于为用户提供一个宁静的数字庇护所。通过社区支持、呼吸练习、哲学思考等功能,帮助用户管理情绪、建立支持网络、促进自我成长。

### 核心价值主张
- 🧘 **情绪管理**: 提供科学的呼吸练习工具帮助用户平静心情
- 💬 **社区支持**: 安全的空间分享想法与情感,获得他人理解与支持
- 🤔 **哲学思考**: 通过深度思考促进自我反思与个人成长
- 👥 **支持网络**: 建立亲密的支持圈,随时获得关心与帮助
- 🎯 **正向激励**: 通过 Calm Points 系统鼓励积极行为

---

## 🎯 MVP 核心功能范围

### Phase 1: 基础功能 (Week 1-2)
**目标**: 建立核心用户系统与基础交互功能

#### 1.1 用户认证系统 ✅
- [x] 用户注册与登录
- [x] 密码重置功能
- [x] Session 管理
- [x] 角色授权系统 (User/Admin)
- [x] 用户资料字段 (姓名、电话、通知偏好)
- [ ] 个人资料完善页面 (头像上传、简介编辑)

#### 1.2 社区发帖系统
- [ ] 发布文字帖子
- [ ] 浏览社区动态 (时间线)
- [ ] 点赞与收藏
- [ ] 评论功能
- [ ] 标签系统 (#焦虑 #成长 #感恩等)
- [ ] 隐私设置 (公开/仅支持圈可见/私密)
- [ ] 举报不当内容功能

#### 1.3 呼吸练习功能
- [ ] 4-4-6 呼吸法引导
- [ ] 可视化呼吸动画 (使用 Stimulus.js)
- [ ] 练习计时器
- [ ] 完成记录与统计

---

### Phase 2: 社交与激励 (Week 3-4)
**目标**: 增强社交互动与用户参与度

#### 2.1 支持圈系统
- [ ] 添加好友/支持者
- [ ] 好友列表管理
- [ ] 在线状态显示
- [ ] 一对一聊天 (使用 Action Cable)
- [ ] 支持请求功能 (快速求助)

#### 2.2 Calm Points 积分系统
- [ ] 积分规则定义
  - 完成呼吸练习: +10 points
  - 发布帖子: +5 points
  - 给予评论支持: +3 points
  - 帮助他人 (被采纳回复): +15 points
  - 每日登录: +2 points
- [ ] 积分排行榜
- [ ] 成就徽章系统
- [ ] 个人积分历史

#### 2.3 哲学思考模块
- [ ] 每日哲学问题推送
- [ ] 思考记录提交
- [ ] 思考分享 (可选匿名)
- [ ] 精选思考展示

---

### Phase 3: 优化与增强 (Week 5-6)
**目标**: 提升用户体验与系统稳定性

#### 3.1 个性化体验
- [ ] 主题切换 (浅色/深色模式)
- [ ] 自定义主题颜色
- [ ] 通知系统
  - 新评论通知
  - 支持圈活动通知
  - 每日提醒设置
- [ ] 个人统计面板
  - 呼吸练习次数
  - 发帖数量
  - 获得的支持数

#### 3.2 内容发现
- [ ] 热门帖子推荐
- [ ] 标签筛选与搜索
- [ ] 用户推荐 (可能的支持者)

#### 3.3 管理员功能 ✨
- [ ] 管理员仪表盘
  - 实时统计数据
  - 待处理举报数量
  - 用户增长趋势
- [ ] 内容审核系统
  - 查看举报列表
  - 审核举报内容
  - 处理举报 (删除/警告/封禁/驳回)
  - 批量处理举报
- [ ] 用户管理
  - 查看用户列表与搜索
  - 用户详情与活动历史
  - 封禁/解封用户
  - 角色管理 (升级/降级)
- [ ] 审计日志
  - 记录所有管理员操作
  - 查看活动日志
  - 导出日志

#### 3.4 性能优化
- [ ] 数据库查询优化 (N+1 问题)
- [ ] 图片上传与处理 (Active Storage)
- [ ] 缓存策略 (Fragment Caching)
- [ ] 后台任务处理 (Active Job)

---

## 🛠️ 技术栈

### 后端
- **Framework**: Ruby on Rails 8
- **Database**: 
  - Development/Test: SQLite
  - Production: PostgreSQL
- **Authentication**: Rails 内置认证 (已实现)
- **Real-time**: Action Cable (WebSocket)
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache

### 前端
- **CSS Framework**: Tailwind CSS 4.1.13
- **Component Library**: Flowbite 3.1.2
- **JavaScript**: 
  - Stimulus.js (Hotwire)
  - Turbo (页面导航)
- **Asset Pipeline**: Propshaft + Importmap

### 部署
- **Container**: Docker
- **Deployment**: Kamal
- **Web Server**: Puma

---

## 📊 数据模型设计

### 核心模型

#### User (已存在)
```ruby
# 用户基础信息
- email_address: string (已实现)
- password_digest: string (已实现)
- role: integer (已实现, default: 0) # 0: user, 1: admin

# 个人资料字段 (已实现)
- first_name: string
- middle_initial: string(1)
- last_name: string
- tel: string
- allow_sms_messages: boolean (default: true)
- allow_email_messages: boolean (default: true)

# 待实现字段
- nickname: string
- avatar_url: string
- bio: text
- calm_points: integer (default: 0)

- created_at: datetime
- updated_at: datetime
```

#### Post (新增)
```ruby
# 社区帖子
- user_id: references
- content: text
- visibility: enum [:public, :circle, :private]
- likes_count: integer (default: 0)
- comments_count: integer (default: 0)
- created_at: datetime
- updated_at: datetime
```

#### Comment (新增)
```ruby
# 评论
- post_id: references
- user_id: references
- content: text
- created_at: datetime
- updated_at: datetime
```

#### Tag (新增)
```ruby
# 标签
- name: string (unique)
- usage_count: integer (default: 0)
- created_at: datetime
- updated_at: datetime
```

#### PostTag (新增)
```ruby
# 帖子标签关联
- post_id: references
- tag_id: references
```

#### BreathingSession (新增)
```ruby
# 呼吸练习记录
- user_id: references
- duration: integer (秒数)
- completed: boolean
- calm_points_earned: integer
- created_at: datetime
```

#### Friendship (新增)
```ruby
# 支持圈关系
- user_id: references
- friend_id: references
- status: enum [:pending, :accepted, :blocked]
- created_at: datetime
- updated_at: datetime
```

#### PhilosophyReflection (新增)
```ruby
# 哲学思考
- user_id: references
- prompt: string (思考问题)
- content: text (思考内容)
- is_anonymous: boolean
- is_shared: boolean
- created_at: datetime
- updated_at: datetime
```

#### CalmPointsLog (新增)
```ruby
# 积分记录
- user_id: references
- action: string (动作类型)
- points: integer (积分变化)
- description: string
- created_at: datetime
```

### 管理员相关模型

#### Report (新增)
```ruby
# 举报记录
- reporter_id: references (举报人)
- reportable_type: string (polymorphic: Post/Comment)
- reportable_id: integer
- reason: enum [:spam, :harassment, :self_harm, :hate_speech, :inappropriate, :other]
- description: text
- status: enum [:pending, :reviewing, :resolved, :dismissed]
- admin_id: references (处理管理员)
- admin_note: text (管理员备注)
- resolved_at: datetime
- created_at: datetime
- updated_at: datetime
```

#### Ban (新增)
```ruby
# 用户封禁记录
- user_id: references (被封禁用户)
- admin_id: references (执行封禁的管理员)
- reason: text
- expires_at: datetime (null = 永久封禁)
- is_active: boolean (default: true)
- created_at: datetime
- updated_at: datetime
```

#### AdminAction (新增)
```ruby
# 管理员操作日志
- admin_id: references
- action_type: string (操作类型)
- target_type: string (目标类型)
- target_id: integer (目标ID)
- details: json (操作详情)
- ip_address: string
- user_agent: string
- created_at: datetime
```

---

## 🎨 UI/UX 设计原则

### 色彩心理学应用
- **主色调**: 柔和蓝色系 (#AEC6CF) - 平静、信任
- **辅助色**: 温柔绿色 (#B2D8B2) - 自然、成长
- **强调色**: 淡紫色 (#C3B1E1) - 冥想、创造力

### 响应式设计
- 移动优先 (Mobile-first)
- 断点: sm (640px), md (768px), lg (1024px), xl (1280px)
- 使用 Tailwind 响应式 utilities

### 可访问性 (A11y)
- 语义化 HTML
- ARIA 标签完善
- 键盘导航支持
- 高对比度模式
- 文字大小可调节

### 交互设计
- 微动画增强反馈 (使用 Stimulus)
- 加载状态明确显示 (Turbo Frame)
- 表单验证实时反馈
- 错误提示清晰友好

---

## 🧪 测试策略

### 单元测试
- Model 验证测试 (test/models/)
- Model 关联测试
- Model 方法测试

### 功能测试
- Controller 请求测试 (test/controllers/)
- 路由测试
- 权限测试

### 集成测试
- 用户注册/登录流程 (test/integration/)
- 发帖与评论流程
- 支持圈互动流程

### 系统测试
- 使用 Capybara 进行 E2E 测试
- 关键用户路径测试

---

## 📈 成功指标 (KPIs)

### 用户参与度
- 日活跃用户数 (DAU)
- 周活跃用户数 (WAU)
- 用户留存率 (Day 1, Day 7, Day 30)

### 功能使用
- 呼吸练习完成率
- 平均每用户发帖数
- 评论参与率
- 支持圈平均规模

### 用户满意度
- Net Promoter Score (NPS)
- 用户反馈收集
- 功能使用满意度调查

---

## 🚀 部署计划

### 开发环境 (Development)
- 本地开发: `bin/dev`
- 数据库: SQLite
- 实时日志: `tail -f log/development.log`

### 测试环境 (Staging)
- 使用 Kamal 部署到测试服务器
- 数据库: PostgreSQL
- 模拟生产环境配置

### 生产环境 (Production)
- 使用 Kamal 容器化部署
- 数据库: PostgreSQL (Cloud)
- CDN: Cloudflare
- 监控: Rails 内置健康检查 + 第三方工具

---

## ⚠️ 风险与挑战

### 技术风险
1. **实时聊天性能**: Action Cable 在高并发下的性能表现
   - 缓解: 实施消息队列、限制同时在线用户数
   
2. **图片上传处理**: 大量图片上传可能影响服务器性能
   - 缓解: 使用 Active Storage + 云存储 (S3)
   
3. **数据库扩展性**: 用户增长后的查询性能
   - 缓解: 及早优化索引、考虑读写分离

### 产品风险
1. **内容安全**: 不当内容的监管与处理
   - 缓解: 实施举报机制、关键词过滤、人工审核
   
2. **用户隐私**: 心理健康数据的敏感性
   - 缓解: 严格权限控制、数据加密、隐私政策明确
   
3. **用户留存**: 如何持续吸引用户使用
   - 缓解: 游戏化设计、社区建设、定期新功能

---

## 📅 时间线

### Week 1-2: Foundation
- ✅ 项目初始化
- ✅ 用户认证系统
- ✅ 角色授权系统
- [ ] 个人资料完善
- [ ] 社区发帖基础功能
- [ ] 举报提交功能

### Week 3-4: Community
- [ ] 评论与互动
- [ ] 支持圈系统
- [ ] 积分系统实现
- [ ] 管理员内容审核系统

### Week 5-6: Enhancement
- [ ] 呼吸练习功能
- [ ] 哲学思考模块
- [ ] 通知系统
- [ ] 管理员用户管理

### Week 7-8: Polish & Deploy
- [ ] UI/UX 优化
- [ ] 性能优化
- [ ] 管理员仪表盘与统计
- [ ] 测试完善
- [ ] 生产环境部署

---

## 📝 后续迭代方向

### V2.0 功能规划
- 小组/社区功能
- 专业心理咨询师对接
- 情绪日记与追踪
- AI 情感分析与建议
- 音频/视频冥想引导
- 线下活动组织

### 技术优化
- GraphQL API
- 移动端 App (React Native / Flutter)
- 微服务架构改造
- AI/ML 个性化推荐

---

## 🔗 相关资源

### 官方文档
- Rails Guides: https://guides.rubyonrails.org/
- Tailwind CSS: https://tailwindcss.com/
- Flowbite: https://flowbite.com/
- Stimulus: https://stimulus.hotwired.dev/

### 设计参考
- Material Design: https://material.io/
- 心理健康 App 案例研究

### 开发工具
- RuboCop: 代码风格检查
- Brakeman: 安全漏洞扫描
- Bullet: N+1 查询检测

---

## 📋 相关文档

### 核心系统文档
- `docs/AUTHENTICATION_AUTHORIZATION.md` - 认证授权完整指南 ⭐
- `docs/AUTH_QUICK_REFERENCE.md` - 认证授权快速参考
- `docs/AUTHORIZATION.md` - 角色授权系统文档
- `docs/AUTHORIZATION_QUICK_START.md` - 授权系统快速开始
- `docs/USER_PROFILE_FIELDS.md` - 用户资料字段文档

### 功能规划文档
- `requirements/admin_features.md` - 管理员功能详细规划

---

**文档版本**: v1.1  
**最后更新**: 2025-10-01  
**更新内容**: 添加角色授权系统和管理员功能模块  
**维护者**: Development Team


