# lib/tasks/data_migration.rake
namespace :data do
    desc "Export SQLite data to JSON files"
    task export: :environment do
      puts "Exporting data from SQLite..."
      
      # 导出用户数据
      users_data = User.all.map do |user|
        {
          id: user.id,
          email_address: user.email_address,
          password_digest: user.password_digest,
          role: user.role,
          first_name: user.first_name,
          middle_initial: user.middle_initial,
          last_name: user.last_name,
          tel: user.tel,
          allow_sms_messages: user.allow_sms_messages,
          allow_email_messages: user.allow_email_messages,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
      
      File.write("tmp/users_export.json", users_data.to_json)
      puts "Exported #{users_data.count} users to tmp/users_export.json"
      
      # 导出会话数据
      sessions_data = Session.all.map do |session|
        {
          id: session.id,
          user_id: session.user_id,
          user_agent: session.user_agent,
          ip_address: session.ip_address,
          created_at: session.created_at,
          updated_at: session.updated_at
        }
      end
      
      File.write("tmp/sessions_export.json", sessions_data.to_json)
      puts "Exported #{sessions_data.count} sessions to tmp/sessions_export.json"
      
      # 导出举报数据
      reports_data = Report.all.map do |report|
        {
          id: report.id,
          reporter_id: report.reporter_id,
          reportable_type: report.reportable_type,
          reportable_id: report.reportable_id,
          reason: report.reason,
          description: report.description,
          status: report.status,
          admin_id: report.admin_id,
          admin_note: report.admin_note,
          resolved_at: report.resolved_at,
          created_at: report.created_at,
          updated_at: report.updated_at
        }
      end
      
      File.write("tmp/reports_export.json", reports_data.to_json)
      puts "Exported #{reports_data.count} reports to tmp/reports_export.json"
      
      # 导出封禁数据
      bans_data = Ban.all.map do |ban|
        {
          id: ban.id,
          user_id: ban.user_id,
          admin_id: ban.admin_id,
          reason: ban.reason,
          expires_at: ban.expires_at,
          is_active: ban.is_active,
          created_at: ban.created_at,
          updated_at: ban.updated_at
        }
      end
      
      File.write("tmp/bans_export.json", bans_data.to_json)
      puts "Exported #{bans_data.count} bans to tmp/bans_export.json"
      
      # 导出管理员操作数据
      admin_actions_data = AdminAction.all.map do |action|
        {
          id: action.id,
          admin_id: action.admin_id,
          action_type: action.action_type,
          target_type: action.target_type,
          target_id: action.target_id,
          details: action.details,
          ip_address: action.ip_address,
          user_agent: action.user_agent,
          created_at: action.created_at,
          updated_at: action.updated_at
        }
      end
      
      File.write("tmp/admin_actions_export.json", admin_actions_data.to_json)
      puts "Exported #{admin_actions_data.count} admin actions to tmp/admin_actions_export.json"
      
      puts "Data export completed!"
    end
    
    desc "Import data to PostgreSQL"
    task import: :environment do
      puts "Importing data to PostgreSQL..."
      
      # 导入用户数据
      if File.exist?("tmp/users_export.json")
        users_data = JSON.parse(File.read("tmp/users_export.json"))
        users_data.each do |user_data|
          User.create!(user_data.except("id"))
        end
        puts "Imported #{users_data.count} users"
      end
      
      # 导入会话数据
      if File.exist?("tmp/sessions_export.json")
        sessions_data = JSON.parse(File.read("tmp/sessions_export.json"))
        sessions_data.each do |session_data|
          Session.create!(session_data.except("id"))
        end
        puts "Imported #{sessions_data.count} sessions"
      end
      
      # 导入举报数据
      if File.exist?("tmp/reports_export.json")
        reports_data = JSON.parse(File.read("tmp/reports_export.json"))
        reports_data.each do |report_data|
          Report.create!(report_data.except("id"))
        end
        puts "Imported #{reports_data.count} reports"
      end
      
      # 导入封禁数据
      if File.exist?("tmp/bans_export.json")
        bans_data = JSON.parse(File.read("tmp/bans_export.json"))
        bans_data.each do |ban_data|
          Ban.create!(ban_data.except("id"))
        end
        puts "Imported #{bans_data.count} bans"
      end
      
      # 导入管理员操作数据
      if File.exist?("tmp/admin_actions_export.json")
        admin_actions_data = JSON.parse(File.read("tmp/admin_actions_export.json"))
        admin_actions_data.each do |action_data|
          AdminAction.create!(action_data.except("id"))
        end
        puts "Imported #{admin_actions_data.count} admin actions"
      end
      
      puts "Data import completed!"
    end
  end