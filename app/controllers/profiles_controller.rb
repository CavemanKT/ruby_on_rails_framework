# 个人资料管理控制器
class ProfilesController < ApplicationController
  before_action :set_user

  # 显示个人资料设置页面
  def edit
    # 如果用户还没有完成个人资料设置，引导他们完成
    @is_setup = !@user.profile_completed?
  end

  # 更新个人资料
  def update
    if @user.update(profile_params)
      if @user.previous_changes.key?("nickname") || @user.previous_changes.key?("bio")
        flash[:notice] = "Profile updated successfully!"
      else
        flash[:notice] = "Profile updated successfully!"
      end
      
      # 如果是首次设置个人资料，给予积分奖励
      if params[:is_setup] == "true" && !@user.profile_completed?
        @user.add_calm_points!(5, "Profile setup completed")
        flash[:notice] += " You earned 5 Calm Points for completing your profile!"
      end
      
      redirect_to after_profile_update_path
    else
      @is_setup = params[:is_setup] == "true"
      render :edit, status: :unprocessable_entity
    end
  end

  # 显示个人资料页面
  def show
    # 显示用户的公开个人资料信息
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:nickname, :bio, :avatar_url, :first_name, :last_name, :middle_initial, :tel)
  end

  def after_profile_update_path
    # 如果是从设置流程来的，跳转到首页；否则回到个人资料页面
    if params[:is_setup] == "true"
      home_index_path
    else
      profile_path
    end
  end
end
