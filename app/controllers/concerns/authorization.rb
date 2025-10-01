# Authorization Concern
# 负责用户授权相关功能：权限检查、角色验证、资源所有权检查
module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :admin?, :current_user_is_owner?
  end

  class_methods do
    # 要求管理员权限
    # 使用方式: require_admin only: [:destroy, :ban]
    def require_admin(**options)
      before_action :ensure_admin, **options
    end

    # 要求用户角色
    # 使用方式: require_role :admin, only: [:index]
    def require_role(role, **options)
      before_action -> { ensure_role(role) }, **options
    end

    # 要求资源所有权
    # 使用方式: require_ownership :post, only: [:edit, :update, :destroy]
    def require_ownership(resource_name, **options)
      before_action -> { ensure_ownership(resource_name) }, **options
    end
  end

  private
    # 检查当前用户是否为管理员
    # @return [Boolean]
    def admin?
      current_user&.admin?
    end

    # 检查当前用户是否为指定角色
    # @param role [Symbol] 角色名称
    # @return [Boolean]
    def has_role?(role)
      current_user&.public_send("#{role}?")
    end

    # 检查当前用户是否为资源的所有者
    # @param resource [ActiveRecord::Base] 要检查的资源
    # @return [Boolean]
    def current_user_is_owner?(resource)
      return false unless current_user
      return false unless resource.respond_to?(:user_id) || resource.respond_to?(:user)

      if resource.respond_to?(:user_id)
        resource.user_id == current_user.id
      elsif resource.respond_to?(:user)
        resource.user == current_user
      end
    end

    # 检查当前用户是否可以管理资源（管理员或所有者）
    # @param resource [ActiveRecord::Base] 要检查的资源
    # @return [Boolean]
    def can_manage?(resource)
      admin? || current_user_is_owner?(resource)
    end

    # 确保用户为管理员，否则拒绝访问
    def ensure_admin
      unless admin?
        handle_unauthorized("You don't have permission to access this page.")
      end
    end

    # 确保用户具有指定角色
    # @param role [Symbol] 角色名称
    def ensure_role(role)
      unless has_role?(role)
        handle_unauthorized("You need #{role} role to access this page.")
      end
    end

    # 确保用户为资源所有者或管理员
    # @param resource_name [Symbol] 实例变量名称（如 :@post）
    def ensure_ownership(resource_name)
      resource = instance_variable_get("@#{resource_name}")
      
      unless can_manage?(resource)
        handle_unauthorized("You don't have permission to modify this resource.")
      end
    end

    # 处理未授权访问
    # @param message [String] 错误消息
    def handle_unauthorized(message = "Access denied.")
      respond_to do |format|
        format.html do
          redirect_to root_path, alert: message
        end
        format.json do
          render json: { error: message }, status: :forbidden
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash",
            partial: "shared/flash",
            locals: { alert: message }
          ), status: :forbidden
        end
      end
    end

    # 授权检查 - 灵活的授权方法
    # @param action [Symbol] 动作名称 (如 :edit, :destroy)
    # @param resource [ActiveRecord::Base] 要检查的资源
    # @return [Boolean]
    def authorize(action, resource)
      case action
      when :manage, :edit, :update, :destroy
        can_manage?(resource)
      when :view, :show
        can_view?(resource)
      when :create
        authenticated?
      else
        false
      end
    end

    # 检查用户是否可以查看资源
    # @param resource [ActiveRecord::Base] 要检查的资源
    # @return [Boolean]
    def can_view?(resource)
      return true if admin?
      return true if current_user_is_owner?(resource)

      # 如果资源有 visibility 字段，检查可见性
      if resource.respond_to?(:visibility)
        case resource.visibility
        when "public"
          true
        when "circle"
          # TODO: 实现支持圈逻辑
          false
        when "private"
          current_user_is_owner?(resource)
        else
          false
        end
      else
        true # 默认公开可见
      end
    end

    # 确保用户有权限执行操作，否则抛出异常或重定向
    # @param action [Symbol] 动作名称
    # @param resource [ActiveRecord::Base] 资源
    def authorize!(action, resource)
      unless authorize(action, resource)
        handle_unauthorized("You don't have permission to #{action} this resource.")
      end
    end
end

