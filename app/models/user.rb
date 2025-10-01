class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # 管理员相关关联
  has_many :reports_submitted, class_name: "Report", foreign_key: "reporter_id", dependent: :destroy
  has_many :reports_handled, class_name: "Report", foreign_key: "admin_id", dependent: :nullify
  has_many :bans, dependent: :destroy
  has_many :bans_issued, class_name: "Ban", foreign_key: "admin_id", dependent: :nullify
  has_many :admin_actions, foreign_key: "admin_id", dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # 验证
  validates :first_name, length: { maximum: 50 }, allow_blank: true
  validates :middle_initial, length: { maximum: 1 }, allow_blank: true
  validates :last_name, length: { maximum: 50 }, allow_blank: true
  validates :tel, format: { with: /\A[+]?[\d\s\-().]+\z/, message: "must be a valid phone number" }, allow_blank: true, length: { maximum: 20 }
  validates :allow_sms_messages, inclusion: { in: [true, false] }
  validates :allow_email_messages, inclusion: { in: [true, false] }

  # 角色定义
  enum :role, { user: 0, admin: 1 }, default: :user

  # 生成密码重置令牌（15分钟有效期）
  def password_reset_token
    signed_id expires_in: 15.minutes, purpose: :password_reset
  end

  # 根据令牌查找用户
  def self.find_by_password_reset_token!(token)
    find_signed! token, purpose: :password_reset
  end

  # 检查用户是否被封禁
  def banned?
    active_ban.present?
  end

  # 获取活跃的封禁记录
  def active_ban
    Ban.active_for_user(self)
  end

  # 封禁用户
  def ban!(admin:, reason:, duration: nil)
    expires_at = duration ? duration.from_now : nil
    bans.create!(
      admin: admin,
      reason: reason,
      expires_at: expires_at,
      is_active: true
    )
  end

  # 解封用户
  def unban!
    active_ban&.deactivate!
  end

  # 获取完整姓名
  def full_name
    parts = [first_name, middle_initial, last_name].compact.reject(&:blank?)
    parts.any? ? parts.join(" ") : email_address.split("@").first
  end

  # 获取显示名称（优先使用姓名，否则使用邮箱前缀）
  def display_name
    full_name
  end

  # 格式化电话号码
  def formatted_tel
    return nil if tel.blank?
    # 简单格式化，可根据需要调整
    tel.gsub(/[^\d+]/, "")
  end

  # 检查是否允许发送短信
  def sms_enabled?
    allow_sms_messages && tel.present?
  end

  # 检查是否允许发送邮件
  def email_enabled?
    allow_email_messages && email_address.present?
  end
end