class Report < ApplicationRecord
  # 关联
  belongs_to :reporter, class_name: "User"
  belongs_to :reportable, polymorphic: true
  belongs_to :admin, class_name: "User", optional: true

  # 举报原因枚举
  enum :reason, {
    spam: 0,           # 垃圾信息
    harassment: 1,     # 骚扰/欺凌
    self_harm: 2,      # 自残/自杀内容
    hate_speech: 3,    # 仇恨言论
    inappropriate: 4,  # 不当内容
    other: 5           # 其他
  }

  # 状态枚举
  enum :status, {
    pending: 0,      # 待处理
    reviewing: 1,    # 审核中
    resolved: 2,     # 已处理
    dismissed: 3     # 已驳回
  }, default: :pending

  # 验证
  validates :reason, presence: true
  validates :status, presence: true
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :admin_note, length: { maximum: 1000 }, allow_blank: true

  # 作用域
  scope :pending, -> { where(status: :pending) }
  scope :reviewing, -> { where(status: :reviewing) }
  scope :resolved, -> { where(status: :resolved) }
  scope :dismissed, -> { where(status: :dismissed) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_reason, ->(reason) { where(reason: reason) if reason.present? }

  # 实例方法
  def mark_as_reviewing!
    update!(status: :reviewing)
  end

  def resolve!(admin:, note:)
    update!(
      status: :resolved,
      admin: admin,
      admin_note: note,
      resolved_at: Time.current
    )
  end

  def dismiss!(admin:, note:)
    update!(
      status: :dismissed,
      admin: admin,
      admin_note: note,
      resolved_at: Time.current
    )
  end

  # 人性化原因文本
  def reason_text
    I18n.t("report.reasons.#{reason}", default: reason.humanize)
  end

  # 人性化状态文本
  def status_text
    I18n.t("report.statuses.#{status}", default: status.humanize)
  end
end
