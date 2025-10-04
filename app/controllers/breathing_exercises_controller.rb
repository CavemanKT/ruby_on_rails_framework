# 呼吸练习控制器
class BreathingExercisesController < ApplicationController
  before_action :set_session, only: [:show, :update]
  
  # 显示呼吸练习页面
  def new
    @session = current_user.breathing_sessions.build
  end
  
  # 开始呼吸练习
  def create
    Rails.logger.info "Creating new breathing session for user #{current_user.id}"
    
    # 确保每次都创建新记录，不检查现有记录
    @session = current_user.breathing_sessions.build(
      duration: 0,
      completed: false,
      calm_points_earned: 0  # 初始为0，只有完成5个周期才会获得10积分
    )
    
    Rails.logger.info "Session built: #{@session.inspect}"
    Rails.logger.info "User has #{current_user.breathing_sessions.count} existing sessions"
    
    if @session.save
      Rails.logger.info "Session saved successfully: ID=#{@session.id}"
      Rails.logger.info "User now has #{current_user.breathing_sessions.count} total sessions"
      redirect_to breathing_exercise_path(@session)
    else
      Rails.logger.error "Failed to save session: #{@session.errors.full_messages}"
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
    
    # 检查是否是进度保存还是完成保存
    is_progress_save = params[:is_progress_save] == true || params[:is_progress_save] == "true"
    is_completion = params[:is_completion] == true || params[:is_completion] == "true"
    
    # 获取传入的周期数（如果有的话）
    incoming_cycles = params[:cycles_completed].to_i
    
    # 准备更新参数
    update_params = breathing_exercise_params.merge(
      completed: is_completion || (!is_progress_save && incoming_cycles >= 5),
      calm_points_earned: (incoming_cycles >= 5 ? 10 : 0)  # 只有完成5个周期才设置为10
    )
    
    Rails.logger.info "Updating session #{@session.id} with params: #{update_params.inspect}"
    Rails.logger.info "is_progress_save: #{is_progress_save}, is_completion: #{is_completion}, incoming_cycles: #{incoming_cycles}"
    
    if @session.update(update_params)
      # 重新加载以确保获取最新的数据
      @session.reload
      
      # 积分会通过模型的回调自动添加，这里只需要记录日志
      actual_points = @session.actual_points_earned
      
      Rails.logger.info "Session updated successfully: cycles=#{@session.cycles_completed}, points=#{actual_points}, completed=#{@session.completed}"
      
      respond_to do |format|
        format.json { render json: { 
          success: true, 
          calm_points: actual_points,
          total_points: current_user.calm_points,
          cycles_completed: @session.cycles_completed,
          can_earn_points: @session.can_earn_points?,
          is_progress_save: is_progress_save,
          is_completion: is_completion
        } }
        format.html { redirect_to completed_breathing_exercise_path(@session) }
      end
    else
      Rails.logger.error "Failed to update session: #{@session.errors.full_messages}"
      respond_to do |format|
        format.json { render json: @session.errors, status: :unprocessable_entity }
        format.html { redirect_to @session, alert: 'Failed to save exercise progress.' }
      end
    end
  end
  
  
  # 查看练习历史
  def history
    # 显示当前用户的所有练习记录（包括未完成的）
    user_sessions = current_user.breathing_sessions.recent
    
    @sessions = user_sessions.limit(50)
    @total_sessions = user_sessions.count
    @completed_sessions = user_sessions.completed.count
    @total_duration = user_sessions.sum(:duration)
    @total_points = user_sessions.completed.sum { |session| session.actual_points_earned }
    
    # 调试信息（生产环境中可以移除）
    Rails.logger.info "Breathing history for user #{current_user.id}: #{@total_sessions} total sessions, #{@completed_sessions} completed"
  end
  
  private
  
  def set_session
    @session = current_user.breathing_sessions.find(params[:id])
  end
  
  def breathing_exercise_params
    params.permit(:duration, :cycles_completed, :total_phases_completed, 
                  :phases_breakdown, :started_at, :finished_at)
  end


  def debug
    @session = current_user.breathing_sessions.find(params[:id])
    render json: {
      session: @session.debug_info,
      user: {
        id: current_user.id,
        calm_points: current_user.calm_points
      }
    }
  end
end


