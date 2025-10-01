# Teddy Web Application - User Stories

## 📖 用户故事说明

本文档按照标准 User Story 格式编写:

**格式**: As a [角色], I want to [行动], so that [目的/价值]

**验收标准**: Given [前置条件] When [操作] Then [预期结果]

**优先级**: 
- 🔴 P0 - Critical (MVP 必须)
- 🟠 P1 - High (MVP 重要)
- 🟡 P2 - Medium (可延后)
- 🟢 P3 - Low (Nice to have)

---

## 🔐 Epic 1: 用户认证与个人资料

### US-1.1: 用户注册 🔴 P0
**Story**:  
As a new user, I want to create an account with email and password, so that I can access the Teddy platform.

**Acceptance Criteria**:
- Given I am on the registration page
- When I enter valid email, password, and password confirmation
- Then my account is created
- And I am redirected to the profile setup page
- And I receive a welcome email

**Technical Notes**:
- 使用 Rails 内置认证
- 密码最小长度: 8 字符
- Email 格式验证
- 密码加密存储 (BCrypt)

---

### US-1.2: 用户登录 🔴 P0 ✅
**Story**:  
As a registered user, I want to log in with my email and password, so that I can access my account.

**Acceptance Criteria**:
- Given I am on the login page
- When I enter my correct email and password
- Then I am logged in successfully
- And I am redirected to the home feed
- And I see a success message "Welcome back!"

**Status**: ✅ Implemented

---

### US-1.3: 密码重置 🔴 P0 ✅
**Story**:  
As a user who forgot my password, I want to reset it via email, so that I can regain access to my account.

**Acceptance Criteria**:
- Given I click "Forgot password?"
- When I enter my registered email
- Then I receive a password reset email
- And the email contains a secure reset link
- And the link expires after 2 hours

**Status**: ✅ Implemented

---

### US-1.4: 完善个人资料 🔴 P0
**Story**:  
As a new user, I want to set up my profile with a nickname and bio, so that others can know more about me.

**Acceptance Criteria**:
- Given I just registered
- When I am on the profile setup page
- Then I can enter:
  - Nickname (required, 2-20 characters)
  - Bio (optional, up to 500 characters)
  - Avatar (optional, image upload)
- And I can skip this step (nickname defaults to email prefix)
- And I can edit these later in settings

**Technical Notes**:
- Avatar 使用 Active Storage
- 图片大小限制: 5MB
- 支持格式: JPG, PNG, GIF

---

### US-1.5: 编辑个人资料 🟠 P1
**Story**:  
As a user, I want to edit my profile information, so that I can keep it up to date.

**Acceptance Criteria**:
- Given I am logged in
- When I navigate to Profile > Edit
- Then I can update:
  - Nickname
  - Bio
  - Avatar
  - Email
  - Password
- And changes are saved with a confirmation message
- And changes reflect immediately in the UI

---

### US-1.6: 退出登录 🔴 P0
**Story**:  
As a logged-in user, I want to log out, so that I can secure my account on shared devices.

**Acceptance Criteria**:
- Given I am logged in
- When I click the "Log out" button
- Then my session is destroyed
- And I am redirected to the login page
- And I see a message "You have been logged out successfully"

---

## 💬 Epic 2: 社区发帖与互动

### US-2.1: 发布文字帖子 🔴 P0
**Story**:  
As a user, I want to post my thoughts and feelings, so that I can express myself and receive support.

**Acceptance Criteria**:
- Given I am logged in
- When I click "New Post" button
- Then I see a post creation form with:
  - Text area (required, 10-5000 characters)
  - Tag selector (optional, multi-select)
  - Privacy setting (Public/Circle/Private)
- And I can click "Publish"
- And the post appears in my feed immediately
- And I earn +5 Calm Points

**Technical Notes**:
- 使用 Turbo Frame 实现无刷新发布
- 前端字数统计实时显示
- Auto-save draft 功能

---

### US-2.2: 浏览社区动态 🔴 P0
**Story**:  
As a user, I want to see posts from the community, so that I can connect with others and offer support.

**Acceptance Criteria**:
- Given I am on the home feed
- Then I see a list of posts showing:
  - Author nickname and avatar
  - Post content
  - Tags
  - Posted time (relative, e.g., "2 hours ago")
  - Like count and comment count
- And posts are sorted by newest first (default)
- And I can scroll to load more (infinite scroll)

**Technical Notes**:
- 分页: 20 posts per page
- 使用 Turbo Frames 实现 infinite scroll
- 预加载用户和标签数据 (避免 N+1)

---

### US-2.3: 点赞帖子 🟠 P1
**Story**:  
As a user, I want to like posts, so that I can show support without commenting.

**Acceptance Criteria**:
- Given I am viewing a post
- When I click the "Like" button
- Then the like count increases by 1
- And the button changes to "Liked" state (filled heart icon)
- And the action happens without page reload
- When I click again, the like is removed

**Technical Notes**:
- 使用 Stimulus controller 处理交互
- AJAX request to POST /posts/:id/like
- Optimistic UI update

---

### US-2.4: 评论帖子 🔴 P0
**Story**:  
As a user, I want to comment on posts, so that I can provide support and start conversations.

**Acceptance Criteria**:
- Given I am viewing a post
- When I click "Comment"
- Then I see a comment input box
- And I can type my comment (10-1000 characters)
- And I click "Submit"
- Then my comment appears below the post
- And the comment count increases
- And the post author receives a notification
- And I earn +3 Calm Points

**Technical Notes**:
- Real-time comment updates via Turbo Streams
- Nested comments (1 level deep only)
- Comment editing within 5 minutes

---

### US-2.5: 使用标签 🟠 P1
**Story**:  
As a user, I want to add tags to my posts, so that others can discover related content.

**Acceptance Criteria**:
- Given I am creating a post
- When I type "#" in the text area
- Then I see tag suggestions (autocomplete)
- And I can select existing tags or create new ones
- And selected tags appear as badges below the text area
- And I can remove tags before publishing
- Then tags are saved with the post
- And tags are clickable in the feed (shows filtered posts)

**Technical Notes**:
- 标签建议: 最常用的 20 个标签
- 标签名称: 2-20 characters, no spaces
- 每个帖子最多 5 个标签

---

### US-2.6: 筛选帖子 🟡 P2
**Story**:  
As a user, I want to filter posts by tags, so that I can find content relevant to my interests.

**Acceptance Criteria**:
- Given I am on the home feed
- When I click on a tag
- Then I see only posts with that tag
- And I see a clear indication of the active filter
- And I can clear the filter to see all posts

**Technical Notes**:
- URL: /feed?tag=anxiety
- 使用 Turbo Frame 切换视图

---

### US-2.7: 搜索帖子 🟡 P2
**Story**:  
As a user, I want to search posts by keywords, so that I can find specific topics or discussions.

**Acceptance Criteria**:
- Given I am on the home feed
- When I enter keywords in the search box
- Then I see posts containing those keywords
- And results are sorted by relevance
- And I see the search term highlighted in results

**Technical Notes**:
- 使用 PostgreSQL full-text search
- 搜索字段: post content, tags, author nickname

---

### US-2.8: 举报不当内容 🟠 P1
**Story**:  
As a user, I want to report inappropriate posts or comments, so that the community stays safe and supportive.

**Acceptance Criteria**:
- Given I see inappropriate content
- When I click "Report"
- Then I see a report form with reason options:
  - Spam
  - Harassment
  - Self-harm content
  - Other (text field)
- And I submit the report
- Then the content is flagged for review
- And I see a confirmation message
- And admins receive a notification

---

## 🧘 Epic 3: 呼吸练习功能

### US-3.1: 开始呼吸练习 🔴 P0
**Story**:  
As a user feeling anxious, I want to start a guided breathing exercise, so that I can calm down.

**Acceptance Criteria**:
- Given I am on the home page
- When I click "Start Breathing Exercise"
- Then I see a fullscreen breathing interface with:
  - Animated circle (expands/contracts)
  - Current phase text ("Breathe In" / "Hold" / "Breathe Out")
  - Timer countdown
  - Current cycle count (e.g., "Cycle 2/5")
- And the animation follows the 4-4-6 pattern:
  - Inhale: 4 seconds (circle expands)
  - Hold: 4 seconds (circle stays large)
  - Exhale: 6 seconds (circle contracts)

**Technical Notes**:
- 使用 Stimulus controller 管理动画
- CSS transitions for smooth animation
- 音效提示 (可选, 用户设置)

---

### US-3.2: 完成呼吸练习 🔴 P0
**Story**:  
As a user, I want to see my progress after completing a breathing exercise, so that I feel accomplished.

**Acceptance Criteria**:
- Given I completed 5 cycles of breathing
- When the exercise ends
- Then I see a completion screen showing:
  - "Great job!" message
  - Duration completed
  - Calm Points earned (+10)
  - "How do you feel now?" mood selector
- And I can click "Done" to return to home
- And my session is recorded in history

**Technical Notes**:
- 记录到 BreathingSession model
- 更新 User.calm_points
- 创建 CalmPointsLog 记录

---

### US-3.3: 查看练习历史 🟡 P2
**Story**:  
As a user, I want to see my breathing exercise history, so that I can track my progress over time.

**Acceptance Criteria**:
- Given I have completed breathing exercises
- When I go to Profile > Breathing History
- Then I see a list of past sessions showing:
  - Date and time
  - Duration
  - Completion status
  - Mood before/after (if recorded)
- And I see statistics:
  - Total sessions completed
  - Total minutes practiced
  - Current streak (consecutive days)
- And I see a calendar view showing practice days

**Technical Notes**:
- 使用 chartkick gem 展示图表
- 计算连续天数逻辑

---

### US-3.4: 自定义呼吸节奏 🟡 P2
**Story**:  
As an advanced user, I want to customize the breathing rhythm, so that I can match my personal needs.

**Acceptance Criteria**:
- Given I am on the breathing exercise page
- When I click "Customize"
- Then I can adjust:
  - Inhale duration (2-8 seconds)
  - Hold duration (0-8 seconds)
  - Exhale duration (2-10 seconds)
  - Number of cycles (3-10)
- And I see a preview of the rhythm
- And I can save it as a preset

---

## 👥 Epic 4: 支持圈系统

### US-4.1: 添加支持者 🟠 P1
**Story**:  
As a user, I want to add friends to my support circle, so that I can build a network of trusted people.

**Acceptance Criteria**:
- Given I found a user I want to connect with
- When I click "Add to Support Circle"
- Then a friend request is sent
- And the user receives a notification
- And the request appears in their "Pending Requests" list

**Technical Notes**:
- 使用 Friendship model (status: pending)
- 每个用户最多 10 个支持者
- 双向关系

---

### US-4.2: 接受/拒绝好友请求 🟠 P1
**Story**:  
As a user, I want to accept or decline friend requests, so that I can control my support circle.

**Acceptance Criteria**:
- Given I received a friend request
- When I go to Profile > Support Circle
- Then I see pending requests with user info
- And I can click "Accept" or "Decline"
- When I accept:
  - The friendship is established (status: accepted)
  - Both users see each other in their circle
  - Both receive a notification
- When I decline:
  - The request is removed
  - No notification is sent

---

### US-4.3: 查看支持圈 🟠 P1
**Story**:  
As a user, I want to see my support circle members, so that I can easily connect with them.

**Acceptance Criteria**:
- Given I have support circle members
- When I navigate to Support Circle page
- Then I see all members displayed in a circular layout
- And each member shows:
  - Avatar
  - Nickname
  - Online status (online/away/offline)
  - Quick action buttons (Chat/Call/Support Request)
- And I can click on a member to see their profile

**Technical Notes**:
- 使用 Canvas 或 SVG 绘制圆形布局
- 在线状态通过 Action Cable 实时更新
- 圆形算法: angle = 360° / member_count

---

### US-4.4: 一对一聊天 🟡 P2
**Story**:  
As a user, I want to chat privately with my support circle members, so that I can have personal conversations.

**Acceptance Criteria**:
- Given I am viewing a support circle member
- When I click "Chat"
- Then a chat window opens (modal or sidebar)
- And I can type and send messages
- And messages are delivered in real-time
- And I see message history
- And unread messages are indicated with a badge

**Technical Notes**:
- 使用 Action Cable for real-time messaging
- Message model: sender_id, receiver_id, content, read_at
- 消息加密存储
- 限制: 每条消息最多 1000 字符

---

### US-4.5: 发送支持请求 🟡 P2
**Story**:  
As a user in distress, I want to send a quick support request to my circle, so that they know I need help.

**Acceptance Criteria**:
- Given I am feeling overwhelmed
- When I click "Request Support" in Support Circle
- Then a pre-written message is sent to all circle members:
  - "I could use some support right now. Can we talk?"
- And all circle members receive a push notification
- And the request appears prominently in their feed
- And members can respond quickly

**Technical Notes**:
- 优先级推送通知
- 支持请求有效期: 4 小时
- 响应者获得 +15 Calm Points

---

### US-4.6: 移除支持者 🟡 P2
**Story**:  
As a user, I want to remove someone from my support circle, so that I can manage my connections.

**Acceptance Criteria**:
- Given I have a support circle member
- When I click "Remove from Circle"
- Then I see a confirmation dialog
- And if I confirm:
  - The friendship is removed
  - We can no longer see each other's private posts
  - Existing chats are archived (not deleted)
  - No notification is sent

---

## 🎯 Epic 5: Calm Points 积分系统

### US-5.1: 获得积分 🟠 P1
**Story**:  
As a user, I want to earn Calm Points for positive actions, so that I feel rewarded for my engagement.

**Acceptance Criteria**:
- Given I perform various actions
- Then I earn points:
  - Complete breathing exercise: +10 points
  - Publish a post: +5 points
  - Comment on a post: +3 points
  - Receive a "Helpful" mark on my comment: +15 points
  - Daily login: +2 points
  - Complete a philosophy reflection: +8 points
- And I see a toast notification showing points earned
- And my total points update immediately

**Technical Notes**:
- 每个动作创建 CalmPointsLog 记录
- 原子更新 User.calm_points (避免竞态条件)
- 防止刷分: 每日上限 100 points

---

### US-5.2: 查看积分历史 🟡 P2
**Story**:  
As a user, I want to see how I earned my points, so that I can understand the system.

**Acceptance Criteria**:
- Given I have earned points
- When I go to Profile > Calm Points
- Then I see a log of all point activities:
  - Timestamp
  - Action description
  - Points earned
  - Running total
- And I can filter by date range
- And I see a summary:
  - Total points all-time
  - Points earned this week
  - Ranking (top X%)

---

### US-5.3: 积分排行榜 🟡 P2
**Story**:  
As a user, I want to see who has the most points, so that I can feel motivated to engage more.

**Acceptance Criteria**:
- Given I navigate to Leaderboard
- Then I see top 100 users ranked by Calm Points
- And each entry shows:
  - Rank
  - Avatar and nickname
  - Total points
  - Badge (if any)
- And I see my own ranking highlighted
- And rankings update daily

**Technical Notes**:
- 缓存排行榜 (更新频率: 1小时)
- 隐私选项: 用户可选择不出现在排行榜

---

### US-5.4: 成就徽章 🟢 P3
**Story**:  
As a user, I want to earn badges for milestones, so that I can showcase my achievements.

**Acceptance Criteria**:
- Given I reach certain milestones
- Then I earn badges:
  - First Breath (complete 1st breathing exercise)
  - Mindful Week (7-day login streak)
  - Supportive Friend (help 10 people)
  - Philosopher (share 5 reflections)
  - Community Leader (100+ Calm Points)
- And badges appear on my profile
- And I receive a congratulatory notification

---

## 🤔 Epic 6: 哲学思考模块

### US-6.1: 查看每日哲学问题 🟡 P2
**Story**:  
As a user, I want to see a daily philosophical question, so that I can engage in deep thinking.

**Acceptance Criteria**:
- Given I visit the Philosophy page
- Then I see today's philosophical question (e.g., "What does it mean to live a good life?")
- And I see a brief context or quote
- And I see how many people have reflected on it today
- And questions change daily at midnight

**Technical Notes**:
- 预设 365 个问题
- 随机或顺序展示
- 缓存当日问题

---

### US-6.2: 记录哲学思考 🟡 P2
**Story**:  
As a user, I want to write my thoughts on the philosophical question, so that I can reflect deeply.

**Acceptance Criteria**:
- Given I see today's question
- When I click "Reflect"
- Then I see a writing interface with:
  - The question at the top
  - Large text area (100-2000 characters)
  - "Keep private" / "Share anonymously" / "Share with name" options
- And I can save my reflection
- And I earn +8 Calm Points

**Technical Notes**:
- 自动保存草稿 (每 30 秒)
- PhilosophyReflection model
- Markdown 支持

---

### US-6.3: 浏览他人的思考 🟡 P2
**Story**:  
As a user, I want to read others' reflections, so that I can gain different perspectives.

**Acceptance Criteria**:
- Given I saved my own reflection
- Then I can see others' shared reflections for the same question
- And reflections show:
  - Author (or "Anonymous")
  - Reflection content
  - Posted time
  - "Insightful" reactions count
- And I can mark reflections as "Insightful"
- And reflections are sorted by "Most Insightful" or "Recent"

---

### US-6.4: 查看我的反思历史 🟡 P2
**Story**:  
As a user, I want to review my past reflections, so that I can see my growth over time.

**Acceptance Criteria**:
- Given I have written reflections
- When I go to Profile > My Reflections
- Then I see a list of all my reflections with:
  - Question
  - My response (preview)
  - Date written
  - Privacy status
- And I can click to see full reflection
- And I can edit or delete private reflections
- And I can change privacy settings of past reflections

---

## 🔔 Epic 7: 通知系统

### US-7.1: 接收应用内通知 🟡 P2
**Story**:  
As a user, I want to receive notifications for important events, so that I stay engaged.

**Acceptance Criteria**:
- Given various events occur
- Then I see notifications for:
  - New comment on my post
  - Someone liked my post
  - Friend request received
  - Friend request accepted
  - Support request from circle member
  - New message in chat
- And I see a notification badge (unread count)
- And I can click to see notification details
- And I can mark as read or delete

**Technical Notes**:
- Notification model: recipient_id, actor_id, type, content, read_at
- 实时推送通过 Action Cable
- 最多保留 30 天

---

### US-7.2: 通知偏好设置 🟢 P3
**Story**:  
As a user, I want to customize which notifications I receive, so that I'm not overwhelmed.

**Acceptance Criteria**:
- Given I go to Settings > Notifications
- Then I can toggle on/off for each notification type:
  - Comments on my posts
  - Likes on my posts
  - Friend requests
  - Support requests
  - Daily reminders
  - Weekly summary
- And I can set quiet hours (no notifications during this time)
- And changes save automatically

---

### US-7.3: 每日提醒 🟢 P3
**Story**:  
As a user, I want to receive daily reminders to practice self-care, so that I build healthy habits.

**Acceptance Criteria**:
- Given I enabled daily reminders
- Then I receive a notification at my chosen time (e.g., 9 AM)
- And the reminder suggests an activity:
  - "Time for your breathing exercise"
  - "Reflect on today's philosophy question"
  - "Check in with your support circle"
- And I can snooze for 1 hour
- And I can disable from the notification itself

**Technical Notes**:
- 使用 Solid Queue 调度任务
- 用户时区处理 (ActiveSupport::TimeZone)

---

## 📊 Epic 8: 统计与洞察

### US-8.1: 个人统计面板 🟡 P2
**Story**:  
As a user, I want to see my activity statistics, so that I can track my progress.

**Acceptance Criteria**:
- Given I go to Profile > Stats
- Then I see cards showing:
  - Total Calm Points
  - Breathing sessions completed
  - Posts published
  - Comments given
  - Reflections written
  - Current login streak
- And I see charts:
  - Weekly activity heatmap
  - Points earned over time (line chart)
  - Most used tags (pie chart)

**Technical Notes**:
- 使用 Chartkick + Chart.js
- 数据缓存优化

---

### US-8.2: 情绪趋势追踪 🟢 P3
**Story**:  
As a user, I want to see how my mood changes over time, so that I can understand patterns.

**Acceptance Criteria**:
- Given I have recorded moods after breathing exercises
- When I view my mood trends
- Then I see a graph showing mood ratings over time
- And I can see correlations:
  - Days I practiced breathing
  - Days I engaged with community
  - Days I wrote reflections
- And I see insights (e.g., "Your mood improves after breathing exercises")

---

## ⚙️ Epic 9: 设置与个性化

### US-9.1: 主题切换 🟡 P2
**Story**:  
As a user, I want to switch between light and dark mode, so that I can use the app comfortably in different environments.

**Acceptance Criteria**:
- Given I go to Settings > Appearance
- Then I can choose:
  - Light mode
  - Dark mode
  - Auto (follows system preference)
- And the theme changes immediately
- And my preference is saved

**Technical Notes**:
- Tailwind dark mode class: `dark`
- JavaScript: `document.documentElement.classList.toggle('dark')`
- 存储在 User preferences (JSON column)

---

### US-9.2: 自定义主题颜色 🟢 P3
**Story**:  
As a user, I want to choose my preferred color theme, so that the app feels personal.

**Acceptance Criteria**:
- Given I go to Settings > Appearance > Theme Color
- Then I can choose from:
  - Calming Blue (default)
  - Gentle Green
  - Soft Lavender
  - Warm Peach
- And primary colors update throughout the app
- And my choice is saved

**Technical Notes**:
- CSS variables for theming
- 使用 Tailwind config 预设颜色

---

### US-9.3: 辅助功能设置 🟡 P2
**Story**:  
As a user with accessibility needs, I want to adjust the interface, so that I can use the app comfortably.

**Acceptance Criteria**:
- Given I go to Settings > Accessibility
- Then I can:
  - Increase font size (Small/Medium/Large/X-Large)
  - Enable high contrast mode
  - Reduce motion (disable animations)
  - Enable screen reader optimizations
- And changes apply immediately

**Technical Notes**:
- 使用 CSS rem units for font scaling
- 遵循 WCAG 2.1 AA 标准

---

## 🛡️ Epic 10: 安全与隐私

### US-10.1: 隐私设置 🟠 P1
**Story**:  
As a user, I want to control who can see my content, so that I feel safe sharing.

**Acceptance Criteria**:
- Given I go to Settings > Privacy
- Then I can set:
  - Profile visibility (Public / Friends Only / Private)
  - Who can send me friend requests (Everyone / Mutual Friends / No One)
  - Who can see my Calm Points (Everyone / Friends / Only Me)
  - Who can message me (Everyone / Friends / No One)
- And changes save successfully

---

### US-10.2: 屏蔽用户 🟡 P2
**Story**:  
As a user, I want to block users who make me uncomfortable, so that I can maintain a positive experience.

**Acceptance Criteria**:
- Given I am viewing a user's profile or post
- When I click "Block User"
- Then I see a confirmation dialog
- And if I confirm:
  - I no longer see their posts or comments
  - They cannot see my posts or profile
  - They cannot message me
  - They are removed from my support circle (if applicable)
- And I can view and unblock from Settings > Blocked Users

---

### US-10.3: 导出个人数据 🟢 P3
**Story**:  
As a user, I want to export all my data, so that I have a copy for my records.

**Acceptance Criteria**:
- Given I go to Settings > Data & Privacy
- When I click "Export My Data"
- Then I receive an email with a download link
- And the export includes:
  - Profile information
  - All posts and comments
  - Breathing session history
  - Philosophy reflections
  - Messages
- And the data is in JSON format
- And the link expires after 7 days

---

### US-10.4: 删除账户 🟢 P3
**Story**:  
As a user, I want to delete my account, so that I can remove my data if I stop using the service.

**Acceptance Criteria**:
- Given I go to Settings > Data & Privacy
- When I click "Delete Account"
- Then I see a warning with consequences:
  - All data will be permanently deleted
  - This action cannot be undone
- And I must type my password to confirm
- And I must check "I understand"
- And if I confirm:
  - My account is deleted
  - My posts are anonymized (author becomes "Deleted User")
  - My messages are deleted
  - I am logged out
  - I receive a confirmation email

---

## 👨‍💼 Epic 11: 管理员 - 内容审核

### US-11.1: 查看举报列表 🔴 P0
**Story**:  
As an admin, I want to see all user reports, so that I can review and take appropriate action.

**Acceptance Criteria**:
- Given I am logged in as admin
- When I navigate to Admin > Reports
- Then I see a list of all reports with:
  - Reporter name
  - Reported content preview
  - Report reason
  - Status (pending/reviewing/resolved)
  - Submission time
- And I can filter by status
- And I can sort by date/priority
- And pending reports are highlighted with badge count
- And I see the total count of pending reports

**Technical Notes**:
- 使用 Turbo Frames 实现无刷新切换
- 分页: 20 reports per page
- 实时更新 pending count (Action Cable)

---

### US-11.2: 审核举报内容 🔴 P0
**Story**:  
As an admin, I want to review reported content in detail, so that I can make informed decisions.

**Acceptance Criteria**:
- Given I click on a report in the list
- Then I see a detailed view showing:
  - Full reported content (post/comment text)
  - Reporter information and submission time
  - Reason and detailed description
  - Content author information
  - Author's violation history (if any)
- And I can view the content in its original context
- And I can see if the same content has been reported by multiple users
- And the report status automatically changes to "reviewing"

**Technical Notes**:
- 使用 polymorphic association (reportable)
- 预加载相关数据避免 N+1 查询
- 显示原始内容的上下文（父帖子、周围评论）

---

### US-11.3: 处理举报 🔴 P0
**Story**:  
As an admin, I want to take action on reports, so that I can maintain community safety.

**Acceptance Criteria**:
- Given I am reviewing a report
- Then I see action options:
  - Delete content only
  - Delete content and warn user
  - Delete content and ban user (temporary/permanent)
  - Dismiss report (no violation found)
- And I must provide an admin note (reason)
- And I click "Confirm Action"
- Then the selected action is executed
- And the report status changes to "resolved" or "dismissed"
- And the reporter receives a notification
- And the action is logged in admin activity log
- And I see a success message

**Technical Notes**:
- 使用 Service Object 处理复杂逻辑
- 使用 transaction 确保数据一致性
- 记录详细的 AdminAction
- 异步发送通知

---

### US-11.4: 批量处理举报 🟡 P2
**Story**:  
As an admin, I want to process multiple reports at once, so that I can work more efficiently.

**Acceptance Criteria**:
- Given I am on the reports list
- When I select multiple reports (checkbox)
- Then I can apply bulk actions:
  - Mark all as resolved
  - Mark all as dismissed
  - Assign to another admin
- And I see a confirmation dialog with count
- And all selected reports are updated
- And I see a success message "X reports updated"

---

## 👥 Epic 12: 管理员 - 用户管理

### US-12.1: 查看用户列表 🟠 P1
**Story**:  
As an admin, I want to view all users, so that I can manage the community effectively.

**Acceptance Criteria**:
- Given I navigate to Admin > Users
- Then I see a paginated table showing:
  - Avatar and nickname
  - Email address
  - Role (user/admin) with badge
  - Registration date
  - Last login time
  - Status (active/banned)
  - Total posts count
  - Violation count
  - Quick action buttons
- And I can search by email or nickname
- And I can filter by role (all/user/admin) and status (all/active/banned)
- And I can sort by any column

**Technical Notes**:
- 使用 pagy gem 分页
- 实现搜索功能使用 PostgreSQL ILIKE
- 添加索引优化查询

---

### US-12.2: 查看用户详情 🟠 P1
**Story**:  
As an admin, I want to view detailed user information, so that I can understand their activity pattern.

**Acceptance Criteria**:
- Given I click on a user from the list
- Then I see a detailed profile page with sections:
  - **Profile**: Avatar, nickname, email, bio, registration date
  - **Statistics**: Total posts, comments, calm points, login streak
  - **Recent Activity**: Timeline of recent posts and comments
  - **Violation History**: List of past violations and warnings
  - **Reports**: Reports against this user and by this user
  - **Ban History**: Past bans (if any)
- And I see action buttons:
  - Change Role
  - Ban User / Unban User
  - View All Posts
  - View All Comments
  - Send Message

---

### US-12.3: 封禁用户 🔴 P0
**Story**:  
As an admin, I want to ban users who violate community rules, so that I can protect other users.

**Acceptance Criteria**:
- Given I am viewing a user's profile or processing a report
- When I click "Ban User"
- Then I see a ban form with:
  - Reason (required text field)
  - Duration options:
    - 1 day
    - 7 days
    - 30 days
    - Permanent
  - Additional notes (optional)
  - "Notify user" checkbox (checked by default)
- And I submit the form
- Then the user is banned
- And they cannot log in (redirect to banned page)
- And they receive an email notification
- And the ban is recorded with admin info
- And I see a success message

**Technical Notes**:
- Ban model: user_id, admin_id, reason, expires_at, is_active
- `before_action :check_if_banned` in Authentication concern
- 封禁期间保留用户数据
- 可以提前解封

---

### US-12.4: 解封用户 🟠 P1
**Story**:  
As an admin, I want to unban users who have been rehabilitated, so that they can return to the community.

**Acceptance Criteria**:
- Given I am viewing a banned user's profile
- When I click "Unban User"
- Then I see a confirmation dialog with:
  - Current ban reason
  - Ban duration
  - Option to add unban note
- And I confirm
- Then the user is unbanned
- And they can log in again
- And they receive an email notification
- And the action is logged

---

### US-12.5: 管理员权限管理 🟡 P2
**Story**:  
As a super admin, I want to promote/demote users to/from admin role, so that I can manage the admin team.

**Acceptance Criteria**:
- Given I am logged in as admin
- When I view a user's profile
- Then I see "Change Role" button
- And I click it
- Then I see role options: User / Admin
- And I select a new role
- And I confirm the change
- Then the user's role is updated
- And they receive a notification email
- And the change is logged in admin activity log
- And role change takes effect immediately

**Technical Notes**:
- 未来可考虑添加 "super_admin" 角色
- 不能降级自己
- 至少保留一个管理员

---

## 📊 Epic 13: 管理员 - 仪表盘与统计

### US-13.1: 管理员仪表盘 🟠 P1
**Story**:  
As an admin, I want to see an overview dashboard, so that I can monitor platform health at a glance.

**Acceptance Criteria**:
- Given I navigate to Admin > Dashboard
- Then I see summary cards:
  - 🔔 Pending reports count (red badge if > 0)
  - 👥 Total users / New users today
  - 📝 Total posts today
  - 💬 Total comments today
  - 🟢 Active users online now
  - 🚫 Banned users count
- And I see "Recent Activity" section:
  - Latest 10 reports
  - Latest 10 admin actions
  - Latest 10 user registrations
- And I see quick action buttons:
  - View All Reports
  - View All Users
  - View Activity Log
- And stats update automatically every 30 seconds

**Technical Notes**:
- 使用 Redis 缓存统计数据 (TTL: 30s)
- Action Cable 实时推送新举报
- Chartkick 展示图表

---

### US-13.2: 统计报表 🟡 P2
**Story**:  
As an admin, I want to view statistics and analytics, so that I can understand platform trends.

**Acceptance Criteria**:
- Given I navigate to Admin > Analytics
- Then I see date range selector (default: last 30 days)
- And I see charts:
  - User growth over time (line chart)
  - Daily post activity (bar chart)
  - Report trends by reason (stacked bar chart)
  - Most active users (top 10 table)
  - Most reported users (top 10 table)
  - Content moderation stats (pie chart)
- And I can select custom date range
- And I can export data as CSV
- And charts are interactive (click to drill down)

**Technical Notes**:
- 使用 Chartkick + Chart.js
- 数据预计算并缓存
- 导出使用 CSV gem

---

### US-13.3: 活动日志 🟡 P2
**Story**:  
As an admin, I want to view all administrative actions, so that I can audit admin activities and ensure accountability.

**Acceptance Criteria**:
- Given I navigate to Admin > Activity Log
- Then I see a chronological list of all admin actions:
  - Timestamp (with timezone)
  - Admin name and avatar
  - Action type (color-coded)
  - Target (user/post/comment/report with link)
  - Details summary
  - IP address
- And I can filter by:
  - Admin (dropdown)
  - Action type (dropdown)
  - Date range
- And I can search by keyword
- And I can export filtered results as CSV
- And I see pagination (50 per page)

**Technical Notes**:
- AdminAction model 记录所有操作
- JSON 字段存储详细信息
- 索引 admin_id, action_type, created_at

---

## 🔍 User Story Summary

### By Priority
- **🔴 P0 (Critical)**: 20 stories - MVP 核心功能 (+5)
- **🟠 P1 (High)**: 17 stories - MVP 重要功能 (+5)
- **🟡 P2 (Medium)**: 25 stories - 后续迭代 (+5)
- **🟢 P3 (Low)**: 8 stories - 增值功能

### By Epic
1. **用户认证与个人资料**: 6 stories
2. **社区发帖与互动**: 8 stories
3. **呼吸练习功能**: 4 stories
4. **支持圈系统**: 6 stories
5. **Calm Points 积分系统**: 4 stories
6. **哲学思考模块**: 4 stories
7. **通知系统**: 3 stories
8. **统计与洞察**: 2 stories
9. **设置与个性化**: 3 stories
10. **安全与隐私**: 4 stories
11. **管理员 - 内容审核**: 4 stories ✨
12. **管理员 - 用户管理**: 5 stories ✨
13. **管理员 - 仪表盘与统计**: 3 stories ✨

**Total**: 70 user stories (+15 admin stories)

---

## 📝 使用说明

### 在 Cursor Composer 中使用
1. 将本文档导入 Composer 作为上下文
2. 引用特定 User Story: `@user_stories.md#US-2.1`
3. 批量实现: "Implement all P0 user stories in Epic 2"
4. 生成实现计划: "Create implementation plan for US-4.3"

### Story 命名约定
- **US-X.Y**: User Story - Epic编号.Story编号
- 例如: US-2.1 = Epic 2 (社区发帖) 的第 1 个 Story

### 更新记录
- **v1.1** (2025-10-01): 添加管理员功能 Epic (11-13), 新增 15 个用户故事
- **v1.0** (2025-10-01): 初始版本,包含 55 个用户故事
- 后续版本将根据用户反馈和开发进度更新

---

**文档版本**: v1.1  
**最后更新**: 2025-10-01  
**维护者**: Product Team


