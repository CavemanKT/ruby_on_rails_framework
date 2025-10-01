# Admin Dashboard Controller
# 管理员仪表盘 - 显示系统概览和统计数据
class Admin::DashboardController < Admin::BaseController
  def index
    # 统计数据
    @stats = {
      total_users: User.count,
      new_users_today: User.where("created_at >= ?", Time.current.beginning_of_day).count,
      total_reports: Report.count,
      pending_reports: Report.pending.count,
      active_bans: Ban.active.count,
      admin_actions_today: AdminAction.where("created_at >= ?", Time.current.beginning_of_day).count
    }
    
    # 最近的举报
    @recent_reports = Report.includes(:reporter, :reportable, :admin)
                            .recent
                            .limit(10)
    
    # 最近的管理员操作
    @recent_actions = AdminAction.includes(:admin)
                                  .recent
                                  .limit(10)
    
    # 最近注册的用户
    @recent_users = User.order(created_at: :desc).limit(10)
    
    # 活跃封禁
    @active_bans = Ban.includes(:user, :admin)
                      .active
                      .recent
                      .limit(5)
  end
end

