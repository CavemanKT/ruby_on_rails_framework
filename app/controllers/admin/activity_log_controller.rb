# Admin Activity Log Controller
# 管理员操作日志
class Admin::ActivityLogController < Admin::BaseController
  def index
    @actions = AdminAction.includes(:admin)
                          .recent
                          .limit(100)
    
    # 筛选
    @actions = @actions.by_admin(params[:admin_id]) if params[:admin_id].present?
    @actions = @actions.by_action_type(params[:action_type]) if params[:action_type].present?
    
    # 管理员列表（用于筛选）
    @admins = User.admin.order(:email_address)
  end
end

