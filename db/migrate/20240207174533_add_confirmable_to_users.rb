class AddConfirmableToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :confirmation_token, :string
    add_index :users, :confirmation_token, unique: true
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string

    # Existing users signed up before confirmation existed; treat them as confirmed.
    up_only { execute "UPDATE users SET confirmed_at = NOW()" }
  end
end
