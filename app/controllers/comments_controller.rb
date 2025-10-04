# 评论管理控制器
class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :set_post
  
  # 显示评论列表
  def index
    @comments = @post.comments.includes(:user).recent.page(params[:page]).per(10)
    
    respond_to do |format|
      format.html
      format.json { render json: @comments }
    end
  end
  
  # 显示单个评论
  def show
  end
  
  # 创建新评论
  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    
    if @comment.save
      respond_to do |format|
        format.html { redirect_to @post, notice: 'Comment added successfully!' }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("new_comment_form", partial: "comments/form", locals: { post: @post, comment: @post.comments.build }),
            turbo_stream.append("comments_list", partial: "comments/comment", locals: { comment: @comment }),
            turbo_stream.replace("comments_count_#{@post.id}", partial: "comments/count", locals: { post: @post })
          ]
        }
        format.json { render json: @comment, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to @post, alert: 'Failed to add comment.' }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("new_comment_form", partial: "comments/form", locals: { post: @post, comment: @comment })
        }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # 显示编辑评论表单
  def edit
    # 只有作者可以编辑自己的评论
    redirect_to @post unless @comment.user == current_user
  end
  
  # 更新评论
  def update
    if @comment.user == current_user && @comment.update(comment_params)
      respond_to do |format|
        format.html { redirect_to @post, notice: 'Comment updated successfully!' }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("comment_#{@comment.id}", partial: "comments/comment", locals: { comment: @comment })
        }
        format.json { render json: @comment }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("comment_#{@comment.id}", partial: "comments/comment", locals: { comment: @comment })
        }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # 删除评论
  def destroy
    if @comment.user == current_user
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to @post, notice: 'Comment deleted successfully!' }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.remove("comment_#{@comment.id}"),
            turbo_stream.replace("comments_count_#{@post.id}", partial: "comments/count", locals: { post: @post })
          ]
        }
        format.json { head :no_content }
      end
    else
      redirect_to @post, alert: 'You can only delete your own comments.'
    end
  end
  
  private
  
  def set_post
    @post = Post.find(params[:post_id])
  end
  
  def set_comment
    @comment = @post.comments.find(params[:id])
  end
  
  def comment_params
    params.require(:comment).permit(:content)
  end
end
