class BreathingSession < ApplicationRecord
  belongs_to :user
  
  # 验证
  validates :duration, numericality: { greater_than_or_equal_to: 0 }
  validates :completed, inclusion: { in: [true, false] }
  validates :calm_points_earned, numericality: { greater_than_or_equal_to: 0 }
  
  # 默认值
  after_initialize :set_defaults, if: :new_record?
  
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
  
  # 计算完成的周期数（从数据库字段读取，如果没有则根据duration计算）
  def cycles_completed
    # 优先使用数据库中存储的值
    return read_attribute(:cycles_completed) if read_attribute(:cycles_completed).present?
    
    # 如果没有存储，则根据duration计算
    return 0 if duration.nil? || duration.zero?
    (duration / TOTAL_PHASE_DURATION.to_f).floor
  end
  
  # 格式化时长显示
  def formatted_duration
    if duration == 0
      "0s"
    elsif duration < 60
      "#{duration}s"
    else
      minutes = duration / 60
      seconds = duration % 60
      if seconds == 0
        "#{minutes}m"
      else
        "#{minutes}m #{seconds}s"
      end
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
  
  # 检查是否完成了足够的周期以获得积分
  def can_earn_points?
    completed? && cycles_completed >= DEFAULT_CYCLES
  end
  
  # 获取实际应该获得的积分
  def actual_points_earned
    can_earn_points? ? calm_points_earned : 0
  end
  
  # 检查积分是否已经发放（通过检查之前是否已完成）
  def points_already_awarded?
    saved_change_to_completed? && saved_change_to_completed.first == true
  end

  # 调试方法 - 显示详细数据
def debug_info
  {
    id: id,
    user_id: user_id,
    duration: duration,
    completed: completed,
    cycles_completed: cycles_completed,
    total_phases_completed: total_phases_completed,
    phases_breakdown: phases_breakdown,
    started_at: started_at,
    finished_at: finished_at,
    calm_points_earned: calm_points_earned,
    can_earn_points: can_earn_points?,
    actual_points_earned: actual_points_earned
  }
end

# 验证数据完整性
def data_complete?
  duration.present? && 
  cycles_completed.present? && 
  total_phases_completed.present? &&
  phases_breakdown.present?
end
  
  private
  
  # 设置默认值
  def set_defaults
    self.duration ||= 0
    self.completed ||= false
    self.calm_points_earned ||= 0  # 初始为0，只有完成5个周期才会设置为10
  end
  
  # 完成练习后给用户添加积分
  def add_calm_points_to_user
    # 只有在真正完成时才给积分
    if completed? && can_earn_points?
      user.add_calm_points!(calm_points_earned, "Completed breathing exercise (#{cycles_completed} cycles)")
    elsif completed? && !can_earn_points?
      Rails.logger.info "User #{user.id} completed only #{cycles_completed} cycles, no points awarded (minimum #{DEFAULT_CYCLES} required)"
    elsif progress_save?
      Rails.logger.info "User #{user.id} saved progress: #{cycles_completed} cycles, #{duration} seconds"
    end
  end
end

def progress_save?
  !completed? && duration.present? && duration > 0
end

def save_type_description
  if completed?
    "Completed exercise"
  elsif progress_save?
    "Progress saved"
  else
    "Session created"
  end
end


# 生成阶段详细数据
def generate_phases_breakdown
  return {} if duration.zero?
  
  breakdown = {
    total_duration: duration,
    cycles_completed: cycles_completed,
    phases_per_cycle: 3,
    total_phases: cycles_completed * 3,
    phase_durations: PHASES.transform_values { |phase| phase[:duration] },
    completion_percentage: (cycles_completed.to_f / DEFAULT_CYCLES * 100).round(1)
  }
  
  breakdown.to_json
end

# 获取练习质量评分
def quality_score
  return 0 unless completed?
  
  base_score = 50
  cycle_bonus = [cycles_completed * 10, 50].min
  completion_bonus = cycles_completed >= DEFAULT_CYCLES ? 20 : 0
  
  base_score + cycle_bonus + completion_bonus
end

# 获取练习效率
def efficiency_rating
  return "N/A" unless completed?
  
  case cycles_completed
  when 0..2
    "Beginner"
  when 3..4
    "Good"
  when 5..7
    "Excellent"
  else
    "Master"
  end
end