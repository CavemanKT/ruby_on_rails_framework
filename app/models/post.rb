class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  
  # 可见性枚举
  enum :visibility, { public_post: 0, circle: 1, private_post: 2 }, default: :public_post
  
  # 验证
  validates :content, presence: true, length: { minimum: 10, maximum: 5000 }
  validates :likes_count, numericality: { greater_than_or_equal_to: 0 }
  validates :comments_count, numericality: { greater_than_or_equal_to: 0 }
  
  # 作用域
  scope :public_posts, -> { where(visibility: :public_post) }
  scope :visible_to_user, ->(user) { where(visibility: :public_post).or(where(user: user)) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(likes_count: :desc, comments_count: :desc) }
  
  # 回调
  after_create :add_calm_points_to_user
  
  # 检查帖子是否对指定用户可见
  def visible_to?(user)
    return true if user == self.user # 作者总是能看到自己的帖子
    return true if visibility == 'public_post'
    return false if visibility == 'private_post'
    
    # circle 可见性需要检查用户是否在作者的支持圈中
    # 这里暂时返回 true，稍后实现支持圈功能时会更新
    visibility == 'circle'
  end
  
  # 检查是否可以被点赞
  def can_be_liked_by?(user)
    visible_to?(user) && user != self.user
  end
  
  # 检查是否可以被评论
  def can_be_commented_by?(user)
    visible_to?(user) && user != self.user
  end
  
  # 获取帖子的预览文本
  def preview(length = 150)
    content.length > length ? "#{content[0, length]}..." : content
  end
  
  # 获取帖子中的标签（从内容中提取 #标签）
  def extract_tags
    content.scan(/#(\w+)/).flatten.uniq
  end
  
  private
  
  # 创建帖子后给用户添加积分
  def add_calm_points_to_user
    user.add_calm_points!(5, "Published a post")
  end
end
