class CreateGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, foreign_key: { on_delete: :nullify }
      t.string :name, null: false
      t.bigint :target_cents, null: false
      t.bigint :saved_cents, null: false, default: 0
      t.date :target_on

      t.timestamps
    end

    add_check_constraint :goals, "target_cents > 0", name: "goals_target_positive"
  end
end
