class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :kind, null: false, default: "expense"
      t.string :color, null: false, default: "slate"

      t.timestamps
    end

    add_index :categories, [ :user_id, :kind, :name ], unique: true
  end
end
