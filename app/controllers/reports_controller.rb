# 用户举报控制器
class ReportsController < ApplicationController
  before_action :set_reportable, only: [:new, :create]
  
  # 显示举报表单
  def new
    @report = Report.new(reportable: @reportable)
  end
  
  # 创建举报
  def create
    @report = Report.new(report_params)
    @report.reporter = current_user
    @report.reportable = @reportable
    
    if @report.save
      respond_to do |format|
        format.html { 
          redirect_back(fallback_location: root_path, notice: 'Report submitted successfully. Thank you for helping keep our community safe.') 
        }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("report_modal", partial: "reports/success")
        }
        format.json { render json: { success: true, message: 'Report submitted successfully' } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("report_modal", partial: "reports/form", locals: { report: @report, reportable: @reportable })
        }
        format.json { render json: { success: false, errors: @report.errors }, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def set_reportable
    if params[:post_id]
      @reportable = Post.find(params[:post_id])
    elsif params[:comment_id]
      @reportable = Comment.find(params[:comment_id])
    else
      redirect_to root_path, alert: 'Invalid content to report.'
    end
  end
  
  def report_params
    params.require(:report).permit(:reason, :description)
  end
end
