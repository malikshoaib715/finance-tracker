class CreateMailConnections < ActiveRecord::Migration[7.1]
  def change
    create_table :mail_connections do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :provider, null: false, default: "google"
      t.string :email, null: false
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.datetime :last_synced_at
      t.string :last_error

      t.timestamps
    end
  end
end
