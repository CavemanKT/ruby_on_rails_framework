class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.integer :visibility
      t.integer :likes_count
      t.integer :comments_count

      t.timestamps
    end
  end
end
