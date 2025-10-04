# Authentication Concern
# 负责用户认证相关功能：登录、登出、Session 管理
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :check_if_banned
    helper_method :authenticated?, :current_user
  end

  class_methods do
    # 允许未认证访问特定 action
    # 使用方式: allow_unauthenticated_access only: [:index, :show]
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      skip_before_action :check_if_banned, **options
    end
  end

  private
    # 检查用户是否已认证
    def authenticated?
      resume_session.present?
    end

    # 要求用户必须登录
    def require_authentication
      resume_session || request_authentication
    end

    # 恢复 session（从 cookie 中）
    def resume_session
      Current.session ||= find_session_by_cookie
    end

    # 从 cookie 中查找 session
    def find_session_by_cookie
      if cookies.signed[:session_id]
        session = Session.find_by(id: cookies.signed[:session_id])
        # 预加载用户和封禁记录，避免 N+1 查询
        session&.then { |s| Session.includes(user: :bans).find(s.id) }
      end
    end

    # 请求用户登录
    def request_authentication
      # 保存原始请求的 URL，登录后重定向回来
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path, alert: "Please log in to continue."
    end

    # 登录后跳转的 URL
    def after_authentication_url
      # 如果用户还没有完成个人资料设置，引导他们完成
      if current_user && !current_user.profile_completed?
        return edit_profile_path(is_setup: true)
      end
      
      session.delete(:return_to_after_authenticating) || home_index_path
    end

    # 为用户创建新 session
    # @param user [User] 要创建 session 的用户
    # @return [Session] 新创建的 session
    def start_new_session_for(user)
      # 检查用户是否被封禁
      if user.banned?
        return handle_banned_user(user)
      end

      user.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip
      ).tap do |new_session|
        Current.session = new_session
        cookies.signed.permanent[:session_id] = {
          value: new_session.id,
          httponly: true,
          same_site: :lax,
          secure: Rails.env.production? # 生产环境启用 HTTPS only
        }
      end
    end

    # 终止当前 session（登出）
    def terminate_session
      Current.session&.destroy
      cookies.delete(:session_id)
      reset_session # 清除 Rails session
    end

    # 获取当前登录用户
    # @return [User, nil]
    def current_user
      Current.session&.user
    end

    # 检查用户是否被封禁
    def check_if_banned
      return unless authenticated?
      return unless current_user.banned?

      handle_banned_user(current_user)
    end

    # 处理被封禁的用户
    def handle_banned_user(user)
      ban = user.active_ban
      terminate_session

      if ban.permanent?
        redirect_to new_session_path, alert: "Your account has been permanently banned. Reason: #{ban.reason}"
      else
        redirect_to new_session_path, alert: "Your account is temporarily banned until #{ban.expires_at.strftime('%Y-%m-%d %H:%M')}. Reason: #{ban.reason}"
      end
    end
end
