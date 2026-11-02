# "Connect Gmail": read-only access to find receipts. Until the app passes
# Google's verification for restricted scopes it runs in testing mode (up to
# 100 test users added in the Google Cloud console).
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
           scope: "email,https://www.googleapis.com/auth/gmail.readonly",
           access_type: "offline", prompt: "consent", include_granted_scopes: true,
           name: "google"
end
OmniAuth.config.allowed_request_methods = %i[post]
