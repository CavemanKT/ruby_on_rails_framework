class RegistrationsController < ApplicationController
    allow_unauthenticated_access only: %i[ new create ]
    rate_limit to: 5, within: 5.minutes, only: :create, with: -> { redirect_to new_registration_url, alert: "Too many attempts. Please try again later." }
  
    def new
      @user = User.new
    end
  
    def create
      @user = User.new(user_params)
      
      if @user.save
        # 自动登录新用户
        start_new_session_for @user
        
        # 根据角色跳转
        if @user.admin?
          redirect_to admin_root_path, notice: "Welcome to Admin Panel, #{@user.full_name}!"
        else
          redirect_to after_authentication_url, notice: "Welcome to Teddy, #{@user.full_name}!"
        end
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    private
  
    def user_params
      params.require(:user).permit(
        :email_address, :password, :password_confirmation,
        :first_name, :middle_initial, :last_name, :tel,
        :allow_sms_messages, :allow_email_messages
      )
    end
  end