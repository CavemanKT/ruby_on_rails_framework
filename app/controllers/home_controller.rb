class HomeController < ApplicationController
  def index
    # 加载帖子时间线
    @posts = Post.includes(:user)
                 .visible_to_user(current_user)
                 .recent
                 .limit(20)
  end
end
