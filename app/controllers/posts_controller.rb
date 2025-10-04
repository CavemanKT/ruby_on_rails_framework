# 帖子管理控制器
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :like]
  
  # 显示帖子列表（首页时间线）
  def index
    @posts = Post.includes(:user)
                 .visible_to_user(current_user)
                 .recent
                 # 分页方法 page 不可用，改用 limit/offset 实现分页
                 .offset(((params[:page].to_i > 0 ? params[:page].to_i : 1) - 1) * 20)
                 .limit(20)
    
    # 如果是 AJAX 请求，只渲染帖子列表
    if request.xhr?
      render partial: 'posts/post_list', locals: { posts: @posts }
    end
  end
  
  # 显示单个帖子详情
  def show
    @comments = @post.comments.includes(:user).recent.limit(10)
  end
  
  # 显示创建帖子表单
  def new
    @post = current_user.posts.build
  end
  
  # 创建新帖子
  def create
    @post = current_user.posts.build(post_params)
    
    if @post.save
      # 处理帖子中的标签
      process_tags(@post)
      
      respond_to do |format|
        format.html { redirect_to home_index_path, notice: 'Post created successfully!' }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("new_post_form", partial: "posts/form", locals: { post: current_user.posts.build })
        }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("new_post_form", partial: "posts/form", locals: { post: @post })
        }
      end
    end
  end
  
  # 显示编辑帖子表单
  def edit
    # 只有作者可以编辑自己的帖子
    redirect_to @post unless @post.user == current_user
  end
  
  # 更新帖子
  def update
    if @post.user == current_user && @post.update(post_params)
      # 重新处理标签
      process_tags(@post)
      
      redirect_to @post, notice: 'Post updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  # 删除帖子
  def destroy
    if @post.user == current_user
      @post.destroy
      redirect_to home_index_path, notice: 'Post deleted successfully!'
    else
      redirect_to @post, alert: 'You can only delete your own posts.'
    end
  end
  
  # 点赞/取消点赞帖子
  def like
    if @post.can_be_liked_by?(current_user)
      result = @post.toggle_like(current_user)
      
      respond_to do |format|
        format.json { render json: result }
        format.html { redirect_back(fallback_location: root_path) }
      end
    else
      respond_to do |format|
        format.json { render json: { error: "Cannot like this post" }, status: :forbidden }
        format.html { redirect_back(fallback_location: root_path, alert: "Cannot like this post") }
      end
    end
  end
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
  
  def post_params
    params.require(:post).permit(:content, :visibility)
  end
  
  # 处理帖子中的标签
  def process_tags(post)
    # 从帖子内容中提取标签
    tags = post.extract_tags
    
    # 这里暂时只是记录，稍后实现 Tag 模型时会完善
    Rails.logger.info "Post #{post.id} has tags: #{tags.join(', ')}"
  end
end
