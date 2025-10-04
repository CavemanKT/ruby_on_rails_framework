class CreateBreathingSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :breathing_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :duration
      t.boolean :completed
      t.integer :calm_points_earned

      t.timestamps
    end
  end
end
