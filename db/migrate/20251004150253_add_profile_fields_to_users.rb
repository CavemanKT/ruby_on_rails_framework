class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :nickname, :string
    add_column :users, :avatar_url, :string
    add_column :users, :bio, :text
    add_column :users, :calm_points, :integer
  end
end
