class AdminAction < ApplicationRecord
  # 关联
  belongs_to :admin, class_name: "User"

  # 验证
  validates :action_type, presence: true

  # 作用域
  scope :recent, -> { order(created_at: :desc) }
  scope :by_admin, ->(admin_id) { where(admin_id: admin_id) if admin_id.present? }
  scope :by_action_type, ->(type) { where(action_type: type) if type.present? }
  scope :by_date_range, ->(start_date, end_date) {
    where(created_at: start_date..end_date) if start_date.present? && end_date.present?
  }

  # 类方法
  def self.log_action(admin:, action_type:, target: nil, details: {}, request: nil)
    create!(
      admin: admin,
      action_type: action_type,
      target_type: target&.class&.name,
      target_id: target&.id,
      details: details,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end

  # 实例方法
  def target
    target_type.constantize.find_by(id: target_id) if target_type.present? && target_id.present?
  rescue NameError
    nil
  end

  def action_description
    case action_type
    when /report/i
      "Report action"
    when /ban/i
      "Ban action"
    when /user/i
      "User management"
    else
      action_type.humanize
    end
  end
end
