class AddPositionToAccounts < ActiveRecord::Migration[7.1]
  def up
    add_column :accounts, :position, :integer, null: false, default: 0

    # Keep today's alphabetical order as the starting position. Accounts is a
    # small table (a handful of rows per user), so an in-place backfill is fine.
    safety_assured do
      execute <<~SQL
        UPDATE accounts SET position = ranked.position
        FROM (SELECT id, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY lower(name)) AS position FROM accounts) ranked
        WHERE accounts.id = ranked.id
      SQL
    end
  end

  def down
    remove_column :accounts, :position
  end
end
