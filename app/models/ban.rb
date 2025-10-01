class Ban < ApplicationRecord
  # 关联
  belongs_to :user
  belongs_to :admin, class_name: "User"

  # 验证
  validates :reason, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :is_active, inclusion: { in: [true, false] }

  # 作用域
  scope :active, -> { where(is_active: true) }
  scope :expired, -> { where("expires_at < ?", Time.current) }
  scope :permanent, -> { where(expires_at: nil) }
  scope :temporary, -> { where.not(expires_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # 回调
  before_save :deactivate_if_expired

  # 类方法
  def self.active_for_user(user)
    where(user: user, is_active: true)
      .where("expires_at IS NULL OR expires_at > ?", Time.current)
      .first
  end

  # 实例方法
  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def permanent?
    expires_at.nil?
  end

  def temporary?
    !permanent?
  end

  def deactivate!
    update!(is_active: false)
  end

  def duration_text
    if permanent?
      "Permanent"
    elsif expires_at
      "Until #{expires_at.strftime('%Y-%m-%d %H:%M')}"
    else
      "Unknown"
    end
  end

  private

  def deactivate_if_expired
    self.is_active = false if expired?
  end
end
