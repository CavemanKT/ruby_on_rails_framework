class Current < ActiveSupport::CurrentAttributes
  attribute :session
  
  # 便捷方法访问当前用户
  def user
    session&.user
  end
end
