class CreateBans < ActiveRecord::Migration[8.0]
  def change
    create_table :bans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.text :reason, null: false
      t.datetime :expires_at
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
    
    add_index :bans, [:user_id, :is_active]
    add_index :bans, :expires_at
  end
end
