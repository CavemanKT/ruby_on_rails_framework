class AddUserProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :middle_initial, :string, limit: 1
    add_column :users, :last_name, :string
    add_column :users, :tel, :string
    add_column :users, :allow_sms_messages, :boolean, default: true, null: false
    add_column :users, :allow_email_messages, :boolean, default: true, null: false
    
    # 添加索引以优化搜索
    add_index :users, :tel
    add_index :users, [:first_name, :last_name]
  end
end
