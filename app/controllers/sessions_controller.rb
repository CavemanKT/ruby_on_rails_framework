class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      
      # 管理员自动跳转到管理员面板
      if user.admin?
        redirect_to admin_root_path, notice: "Welcome to Admin Panel, #{user.full_name}!"
      else
        redirect_to after_authentication_url, notice: "Welcome back, #{user.full_name}!"
      end
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
