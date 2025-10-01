# Admin Base Controller
# 所有管理员 controller 的基类，提供共享功能和权限控制
class Admin::BaseController < ApplicationController
  # 要求管理员权限
  require_admin
  
  # 使用管理员专用布局
  layout "admin"
  
  # 记录所有管理员操作
  before_action :log_admin_access
  
  private
    # 记录管理员访问日志
    def log_admin_access
      AdminAction.log_action(
        admin: current_user,
        action_type: "#{controller_name}##{action_name}",
        details: {
          controller: controller_name,
          action: action_name,
          params: filtered_params
        },
        request: request
      )
    end
    
    # 过滤敏感参数
    def filtered_params
      params.to_unsafe_h.except(:password, :password_confirmation, :token)
    end
end

