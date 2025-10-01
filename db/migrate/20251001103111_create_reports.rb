class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :reportable, polymorphic: true, null: false
      t.integer :reason, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.references :admin, null: true, foreign_key: { to_table: :users }
      t.text :admin_note
      t.datetime :resolved_at

      t.timestamps
    end
    
    add_index :reports, [:reportable_type, :reportable_id]
    add_index :reports, :status
    add_index :reports, :created_at
  end
end
