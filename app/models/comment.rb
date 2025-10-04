class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  
  # 验证
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }
  
  # 作用域
  scope :recent, -> { order(created_at: :desc) }
  
  # 回调
  after_create :add_calm_points_to_user
  after_create :increment_post_comments_count
  after_destroy :decrement_post_comments_count
  
  private
  
  # 创建评论后给用户添加积分
  def add_calm_points_to_user
    user.add_calm_points!(3, "Commented on a post")
  end
  
  # 增加帖子的评论计数
  def increment_post_comments_count
    post.increment!(:comments_count)
  end
  
  # 减少帖子的评论计数
  def decrement_post_comments_count
    post.decrement!(:comments_count)
  end
end
