# 呼吸练习控制器
class BreathingExercisesController < ApplicationController
  before_action :set_session, only: [:show, :update]
  
  # 显示呼吸练习页面
  def new
    @session = current_user.breathing_sessions.build
  end
  
  # 开始呼吸练习
  def create
    @session = current_user.breathing_sessions.build(
      duration: 0,
      completed: false,
      calm_points_earned: 10
    )
    
    if @session.save
      redirect_to breathing_exercise_path(@session)
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # 显示呼吸练习界面
  def show
    # 如果练习已完成，重定向到完成页面
    if @session.completed?
      redirect_to completed_breathing_exercise_path(@session)
    end
  end
  
  # 更新呼吸练习状态
  def update
    if @session.update(breathing_exercise_params)
      respond_to do |format|
        format.json { render json: @session }
        format.html { redirect_to @session }
      end
    else
      respond_to do |format|
        format.json { render json: @session.errors, status: :unprocessable_entity }
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end
  
  # 完成练习页面
  def completed
    @session = current_user.breathing_sessions.find(params[:id])
    
    unless @session.completed?
      redirect_to breathing_exercise_path(@session)
    end
  end
  
  # 完成练习
  def finish
    @session = current_user.breathing_sessions.find(params[:id])
    
    if @session.update(completed: true, duration: params[:duration])
      # 确保用户获得积分
      current_user.add_calm_points!(@session.calm_points_earned, "Completed breathing exercise")
      
      respond_to do |format|
        format.json { render json: { 
          success: true, 
          calm_points: @session.calm_points_earned,
          total_points: current_user.calm_points
        } }
        format.html { redirect_to completed_breathing_exercise_path(@session) }
      end
    else
      respond_to do |format|
        format.json { render json: @session.errors, status: :unprocessable_entity }
        format.html { redirect_to @session, alert: 'Failed to complete exercise.' }
      end
    end
  end
  
  # 查看练习历史
  def history
    @sessions = current_user.breathing_sessions.completed.recent.limit(50)
    @total_sessions = current_user.breathing_sessions.completed.count
    @total_duration = current_user.breathing_sessions.completed.sum(:duration)
    @total_points = current_user.breathing_sessions.completed.sum(:calm_points_earned)
  end
  
  private
  
  def set_session
    @session = current_user.breathing_sessions.find(params[:id])
  end
  
  def breathing_exercise_params
    params.require(:breathing_session).permit(:duration, :completed)
  end
end
