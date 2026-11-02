# Keys for Active Record encryption (mail connection tokens). Production reads
# them from the environment; development and test use fixed throwaway keys.
Rails.application.configure do
  keys = if Rails.env.local?
    { primary_key: "dev-primary-key-not-secret-000000", deterministic_key: "dev-deterministic-key-not-secret0",
      key_derivation_salt: "dev-key-derivation-salt-not-secret" }
  else
    { primary_key: ENV["AR_ENCRYPTION_PRIMARY_KEY"], deterministic_key: ENV["AR_ENCRYPTION_DETERMINISTIC_KEY"],
      key_derivation_salt: ENV["AR_ENCRYPTION_KEY_DERIVATION_SALT"] }
  end
  config.active_record.encryption.primary_key = keys[:primary_key]
  config.active_record.encryption.deterministic_key = keys[:deterministic_key]
  config.active_record.encryption.key_derivation_salt = keys[:key_derivation_salt]
end
