# Teddy Web Application - Admin Features 管理员功能

## 📋 管理员功能概述

管理员系统旨在帮助管理员维护社区安全、处理用户举报、监控平台健康度，确保 Teddy 成为一个安全、支持性的心理健康社区。

---

## 🎯 核心管理功能

### 1. 内容审核系统
- 处理用户举报
- 查看被举报的内容
- 对不当内容进行处理（删除/警告/封禁）
- 查看举报历史记录

### 2. 用户管理系统
- 查看用户列表
- 查看用户详细信息
- 用户角色管理（升级/降级）
- 用户封禁/解封
- 查看用户活动记录

### 3. 内容管理系统
- 查看所有帖子
- 删除违规帖子
- 编辑/删除评论
- 批量内容管理

### 4. 数据统计与监控
- 用户增长趋势
- 内容发布统计
- 举报处理情况
- 系统健康度监控

---

## 📊 数据模型设计

### Report (举报记录)
```ruby
# 举报模型
- reporter_id: references (举报人)
- reportable_type: string (被举报内容类型: Post/Comment)
- reportable_id: integer (被举报内容ID)
- reason: enum (举报原因)
- description: text (详细描述)
- status: enum (pending/reviewing/resolved/dismissed)
- admin_id: references (处理管理员)
- admin_note: text (管理员备注)
- resolved_at: datetime (处理时间)
- created_at: datetime
- updated_at: datetime
```

**举报原因枚举值：**
- `spam` - 垃圾信息
- `harassment` - 骚扰/欺凌
- `self_harm` - 自残/自杀内容
- `hate_speech` - 仇恨言论
- `inappropriate` - 不当内容
- `other` - 其他

**状态枚举值：**
- `pending` - 待处理
- `reviewing` - 审核中
- `resolved` - 已处理
- `dismissed` - 已驳回

### AdminAction (管理员操作记录)
```ruby
# 管理员操作日志
- admin_id: references
- action_type: string (操作类型)
- target_type: string (目标类型: User/Post/Comment/Report)
- target_id: integer (目标ID)
- details: json (操作详情)
- created_at: datetime
```

### Ban (封禁记录)
```ruby
# 用户封禁记录
- user_id: references (被封禁用户)
- admin_id: references (执行封禁的管理员)
- reason: text
- expires_at: datetime (null = 永久封禁)
- is_active: boolean
- created_at: datetime
- updated_at: datetime
```

---

## 🎨 UI/UX 设计

### 管理员导航布局

```
+--------------------------------------------------+
| [Teddy Logo]  Home  Community  [Admin Menu ▼]  |
+--------------------------------------------------+
                        |
                        v
              +------------------+
              | Dashboard        |
              | Reports (5 🔴)   |
              | Users            |
              | Content          |
              | Analytics        |
              | Activity Log     |
              +------------------+
```

### 举报处理工作流

```
用户举报内容
    ↓
生成举报记录 (status: pending)
    ↓
管理员收到通知
    ↓
管理员审核 (status: reviewing)
    ↓
  ↙   ↘
确认违规    无违规
  ↓         ↓
采取行动   驳回举报
  ↓         ↓
记录操作   记录原因
  ↓         ↓
(status: resolved/dismissed)
    ↓
通知举报人处理结果
```

---

## 🔧 技术实现要点

### 1. 权限控制
```ruby
# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  require_admin  # 确保只有管理员能访问
  layout 'admin' # 使用管理员专用布局
  
  before_action :log_admin_action
  
  private
    def log_admin_action
      AdminAction.create!(
        admin: current_user,
        action_type: "#{controller_name}##{action_name}",
        target_type: params[:controller],
        target_id: params[:id],
        details: {
          params: params.to_unsafe_h.except(:password, :password_confirmation),
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        }
      )
    end
end
```

### 2. 举报处理流程
```ruby
# app/services/report_processor.rb
class ReportProcessor
  def initialize(report, admin)
    @report = report
    @admin = admin
  end
  
  def resolve(action:, note:)
    ActiveRecord::Base.transaction do
      @report.update!(
        status: :resolved,
        admin: @admin,
        admin_note: note,
        resolved_at: Time.current
      )
      
      case action
      when :delete_content
        delete_reported_content
      when :warn_user
        warn_user
      when :ban_user
        ban_user
      end
      
      notify_reporter
    end
  end
end
```

### 3. 实时通知系统
```ruby
# 当有新举报时,通知所有在线管理员
ActionCable.server.broadcast(
  "admin_notifications",
  {
    type: "new_report",
    report_id: report.id,
    count: Report.pending.count
  }
)
```

---

## 🎯 管理员功能 User Stories

### Epic 11: 管理员 - 内容审核

#### US-11.1: 查看举报列表 🔴 P0
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
- And pending reports are highlighted
- And I see the total count of pending reports

**Technical Notes**:
- 使用 Turbo Frames 实现无刷新切换
- 分页: 20 reports per page
- 实时更新 (Action Cable)

---

#### US-11.2: 审核举报内容 🔴 P0
**Story**:  
As an admin, I want to review reported content in detail, so that I can make informed decisions.

**Acceptance Criteria**:
- Given I click on a report
- Then I see a detailed view showing:
  - Full reported content (post/comment)
  - Reporter information
  - Reason and description
  - Content author information
  - Author's history (past violations)
  - Report submission time
- And I can view the content in context (surrounding comments, post thread)
- And I can see if the same content has been reported by others
- And the report status changes to "reviewing"

---

#### US-11.3: 处理举报 🔴 P0
**Story**:  
As an admin, I want to take action on reports, so that I can maintain community safety.

**Acceptance Criteria**:
- Given I am reviewing a report
- Then I can choose from these actions:
  - Delete content
  - Delete content and warn user
  - Delete content and ban user (temporary/permanent)
  - Dismiss report (no violation)
- And I must provide a reason/note
- And I click "Confirm Action"
- Then the action is executed
- And the report status changes to "resolved" or "dismissed"
- And the reporter receives a notification
- And the action is logged
- And I see a success message

**Technical Notes**:
- 使用确认对话框防止误操作
- 记录详细的操作日志
- 异步通知相关用户

---

#### US-11.4: 批量处理举报 🟡 P2
**Story**:  
As an admin, I want to process multiple reports at once, so that I can work more efficiently.

**Acceptance Criteria**:
- Given I am on the reports list
- When I select multiple reports
- Then I can apply bulk actions:
  - Mark as resolved
  - Mark as dismissed
  - Assign to another admin
- And I see a confirmation dialog
- And all selected reports are updated
- And I see a success message with count

---

### Epic 12: 管理员 - 用户管理

#### US-12.1: 查看用户列表 🟠 P1
**Story**:  
As an admin, I want to view all users, so that I can manage the community.

**Acceptance Criteria**:
- Given I navigate to Admin > Users
- Then I see a table with:
  - Avatar and nickname
  - Email
  - Role (user/admin)
  - Registration date
  - Last login
  - Status (active/banned)
  - Total posts
  - Violation count
- And I can search by email/nickname
- And I can filter by role/status
- And I can sort by any column

---

#### US-12.2: 查看用户详情 🟠 P1
**Story**:  
As an admin, I want to view detailed user information, so that I can understand their activity.

**Acceptance Criteria**:
- Given I click on a user
- Then I see:
  - Profile information
  - Account statistics (posts, comments, calm points)
  - Recent activity timeline
  - Violation history
  - Reports against this user
  - Reports submitted by this user
  - Ban history (if any)
- And I can take actions:
  - Edit role
  - Ban user
  - Unban user
  - View all posts
  - View all comments

---

#### US-12.3: 封禁用户 🔴 P0
**Story**:  
As an admin, I want to ban users who violate rules, so that I can protect the community.

**Acceptance Criteria**:
- Given I am viewing a user's profile
- When I click "Ban User"
- Then I see a form with:
  - Reason (required)
  - Duration options:
    - 1 day
    - 7 days
    - 30 days
    - Permanent
  - Additional notes
- And I submit the form
- Then the user is banned
- And they cannot log in
- And they receive an email notification
- And the ban is recorded
- And I see a success message

**Technical Notes**:
- 检查 `before_action :check_if_banned`
- 封禁期间保留用户数据
- 可以提前解封

---

#### US-12.4: 管理员权限管理 🟡 P2
**Story**:  
As a super admin, I want to promote/demote admins, so that I can manage the admin team.

**Acceptance Criteria**:
- Given I am a super admin (first admin)
- When I view a user's profile
- Then I can see "Change Role" option
- And I can select: User / Admin
- And I confirm the change
- Then the user's role is updated
- And they receive a notification
- And the change is logged

---

### Epic 13: 管理员 - 仪表盘与统计

#### US-13.1: 管理员仪表盘 🟠 P1
**Story**:  
As an admin, I want to see an overview dashboard, so that I can monitor platform health.

**Acceptance Criteria**:
- Given I navigate to Admin > Dashboard
- Then I see:
  - Pending reports count (highlighted if > 0)
  - Total users / New users today
  - Total posts today
  - Total comments today
  - Active users online
  - Recent admin actions
  - Quick action buttons
- And all stats are updated in real-time
- And I can click on any stat to see details

---

#### US-13.2: 统计报表 🟡 P2
**Story**:  
As an admin, I want to view statistics and analytics, so that I can understand platform trends.

**Acceptance Criteria**:
- Given I navigate to Admin > Analytics
- Then I see charts showing:
  - User growth (line chart)
  - Post activity (bar chart)
  - Report trends (line chart)
  - Most reported content types (pie chart)
  - Top violators (table)
- And I can select date range
- And I can export data as CSV

---

#### US-13.3: 活动日志 🟡 P2
**Story**:  
As an admin, I want to view all admin actions, so that I can audit administrative activities.

**Acceptance Criteria**:
- Given I navigate to Admin > Activity Log
- Then I see a chronological list of all admin actions:
  - Timestamp
  - Admin name
  - Action type
  - Target (user/post/report)
  - Details
- And I can filter by admin/action type/date
- And I can search by keyword
- And I can export logs

---

## 🎨 页面设计参考

### 举报列表页面
```
+------------------------------------------------------------+
| Admin Panel > Reports                        [+ Filters ▼] |
+------------------------------------------------------------+
| [Pending (5)] [Reviewing (2)] [Resolved] [Dismissed]       |
+------------------------------------------------------------+
|  ID  | Reporter | Content      | Reason     | Date | Action|
|------|----------|--------------|------------|------|-------|
| 🔴#1 | Alice    | "Bad post.." | Harassment | 2h   | [View]|
| 🔴#2 | Bob      | "Comment.."  | Spam       | 5h   | [View]|
+------------------------------------------------------------+
```

### 举报详情页面
```
+------------------------------------------------------------+
| Report #123 - Pending                        Status: 🔴    |
+------------------------------------------------------------+
| Reporter: Alice (@alice)                Reported: 2h ago   |
| Reason: Harassment                                         |
| Description: "This user is constantly harassing me..."     |
+------------------------------------------------------------+
| 📄 Reported Content (Post #456)                            |
|                                                            |
| Author: @baduser (3 previous violations)                   |
| Posted: 5 hours ago                                        |
|                                                            |
| "This is the inappropriate content that was posted..."     |
|                                                            |
| [View Full Context]                                        |
+------------------------------------------------------------+
| Similar Reports: 2 other users also reported this content |
+------------------------------------------------------------+
| Take Action:                                               |
| [ ] Delete content only                                    |
| [ ] Delete + Warn user                                     |
| [ ] Delete + Ban user (temp/permanent)                     |
| [ ] Dismiss (no violation)                                 |
|                                                            |
| Admin Note: [_________________________________]             |
|                                                            |
| [Cancel] [Confirm Action]                                  |
+------------------------------------------------------------+
```

---

## 🔐 安全考虑

1. **权限验证**: 每个管理员操作都需要验证权限
2. **操作日志**: 所有管理员操作必须记录
3. **双重确认**: 敏感操作（封禁、删除）需要二次确认
4. **审计追踪**: 保留完整的操作历史记录
5. **防止滥用**: 监控管理员异常操作模式

---

## 📋 实现优先级

### Phase 1 - 核心功能 (Week 1) 🔴
- [x] 角色系统实现
- [ ] Report 模型与迁移
- [ ] 举报提交功能
- [ ] 举报列表页面
- [ ] 举报详情与处理

### Phase 2 - 用户管理 (Week 2) 🟠
- [ ] 用户列表页面
- [ ] 用户详情页面
- [ ] 用户封禁功能
- [ ] Ban 模型与迁移

### Phase 3 - 仪表盘 (Week 3) 🟡
- [ ] 管理员仪表盘
- [ ] 统计图表
- [ ] 活动日志
- [ ] AdminAction 模型

### Phase 4 - 优化 (Week 4) 🟢
- [ ] 实时通知
- [ ] 批量操作
- [ ] 导出功能
- [ ] 高级筛选

---

## 📚 相关技术文档

- `docs/AUTHORIZATION.md` - 角色授权系统
- `docs/ADMIN_API.md` - 管理员 API 文档
- `docs/REPORT_WORKFLOW.md` - 举报处理流程

---

**文档版本**: v1.0  
**最后更新**: 2025-10-01  
**维护者**: Development Team

