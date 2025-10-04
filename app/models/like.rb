class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  
  # 验证
  validates :user_id, uniqueness: { scope: [:likeable_type, :likeable_id], message: "has already liked this content" }
  
  # 作用域
  scope :for_user, ->(user) { where(user: user) }
  scope :for_likeable, ->(likeable) { where(likeable: likeable) }
end
