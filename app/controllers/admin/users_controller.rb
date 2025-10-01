# Admin Users Controller
# 管理员用户管理
class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order(created_at: :desc)
                 .limit(50)
    
    # 搜索
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.where(
        "email_address LIKE ? OR first_name LIKE ? OR last_name LIKE ?",
        search_term, search_term, search_term
      )
    end
    
    # 筛选角色
    @users = @users.where(role: params[:role]) if params[:role].present?
    
    # 统计
    @total_users = User.count
    @admins_count = User.admin.count
    @banned_users_count = User.joins(:bans).where(bans: { is_active: true }).distinct.count
  end

  def show
    @user = User.find(params[:id])
    @recent_actions = @user.admin_actions.recent.limit(10) if @user.admin?
    @bans = @user.bans.recent.limit(5)
    @reports_submitted = @user.reports_submitted.recent.limit(5)
    @reports_against = Report.where(reportable: [@user]).recent.limit(5)
  end

  def ban
    @user = User.find(params[:id])
    
    duration = case params[:duration]
               when "1_day" then 1.day
               when "7_days" then 7.days
               when "30_days" then 30.days
               else nil
               end
    
    if @user.ban!(admin: current_user, reason: params[:reason], duration: duration)
      redirect_to admin_user_path(@user), notice: "User banned successfully"
    else
      redirect_to admin_user_path(@user), alert: "Failed to ban user"
    end
  end

  def unban
    @user = User.find(params[:id])
    
    if @user.unban!
      redirect_to admin_user_path(@user), notice: "User unbanned successfully"
    else
      redirect_to admin_user_path(@user), alert: "Failed to unban user"
    end
  end
end

