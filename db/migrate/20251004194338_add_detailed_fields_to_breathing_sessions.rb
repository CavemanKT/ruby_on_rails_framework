class AddDetailedFieldsToBreathingSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :breathing_sessions, :cycles_completed, :integer
    add_column :breathing_sessions, :total_phases_completed, :integer
    add_column :breathing_sessions, :phases_breakdown, :text
    add_column :breathing_sessions, :started_at, :datetime
    add_column :breathing_sessions, :finished_at, :datetime
  end
end
