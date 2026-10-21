# Browser clients (the Flutter web build) may call the JSON API from the origins
# listed in CORS_ORIGINS, e.g. "https://app.example.com,http://localhost:3020".
# The API uses bearer tokens, never cookies, so credentials aren't allowed.
origins = ENV.fetch("CORS_ORIGINS", "").split(",").map(&:strip).reject(&:empty?)

if origins.any?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins(*origins)
      resource "/api/*", headers: :any, methods: %i[get post patch delete options], max_age: 600
    end
  end
end
