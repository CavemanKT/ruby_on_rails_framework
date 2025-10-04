class BreathingSession < ApplicationRecord
  belongs_to :user
  
  # 验证
  validates :duration, numericality: { greater_than_or_equal_to: 0 }
  validates :completed, inclusion: { in: [true, false] }
  validates :calm_points_earned, numericality: { greater_than_or_equal_to: 0 }
  
  # 作用域
  scope :completed, -> { where(completed: true) }
  scope :recent, -> { order(created_at: :desc) }
  
  # 回调
  after_update :add_calm_points_to_user, if: :saved_change_to_completed?
  
  # 呼吸阶段枚举
  PHASES = {
    inhale: { duration: 4, label: "Breathe In", color: "blue" },
    hold: { duration: 4, label: "Hold", color: "green" },
    exhale: { duration: 6, label: "Breathe Out", color: "purple" }
  }.freeze
  
  # 默认练习配置
  DEFAULT_CYCLES = 5
  TOTAL_PHASE_DURATION = PHASES.values.sum { |phase| phase[:duration] }
  
  # 计算总练习时长（秒）
  def total_duration
    cycles_completed * TOTAL_PHASE_DURATION
  end
  
  # 计算完成的周期数
  def cycles_completed
    return 0 if duration.zero?
    duration / TOTAL_PHASE_DURATION
  end
  
  # 格式化时长显示
  def formatted_duration
    minutes = duration / 60
    seconds = duration % 60
    if minutes > 0
      "#{minutes}m #{seconds}s"
    else
      "#{seconds}s"
    end
  end
  
  # 获取当前呼吸阶段
  def current_phase(elapsed_time)
    phase_time = elapsed_time % TOTAL_PHASE_DURATION
    
    if phase_time < PHASES[:inhale][:duration]
      :inhale
    elsif phase_time < PHASES[:inhale][:duration] + PHASES[:hold][:duration]
      :hold
    else
      :exhale
    end
  end
  
  # 获取当前周期数
  def current_cycle(elapsed_time)
    (elapsed_time / TOTAL_PHASE_DURATION).floor + 1
  end
  
  private
  
  # 完成练习后给用户添加积分
  def add_calm_points_to_user
    user.add_calm_points!(calm_points_earned, "Completed breathing exercise")
  end
end
