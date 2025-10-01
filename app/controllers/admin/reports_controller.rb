# Admin Reports Controller
# 管理员举报管理
class Admin::ReportsController < Admin::BaseController
  def index
    @reports = Report.includes(:reporter, :reportable, :admin)
                     .recent
                     .limit(50)
    
    # 筛选
    @reports = @reports.by_reason(params[:reason]) if params[:reason].present?
    @reports = @reports.where(status: params[:status]) if params[:status].present?
    
    # 统计
    @pending_count = Report.pending.count
  end

  def show
    @report = Report.includes(:reporter, :reportable, :admin).find(params[:id])
    @report.mark_as_reviewing! if @report.pending?
  end

  def resolve
    @report = Report.find(params[:id])
    
    if @report.resolve!(admin: current_user, note: params[:admin_note])
      redirect_to admin_reports_path, notice: "Report resolved successfully"
    else
      redirect_to admin_report_path(@report), alert: "Failed to resolve report"
    end
  end

  def dismiss
    @report = Report.find(params[:id])
    
    if @report.dismiss!(admin: current_user, note: params[:admin_note])
      redirect_to admin_reports_path, notice: "Report dismissed successfully"
    else
      redirect_to admin_report_path(@report), alert: "Failed to dismiss report"
    end
  end
end

