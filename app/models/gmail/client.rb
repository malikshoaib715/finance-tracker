require "net/http"

# Minimal Gmail REST client: refreshes the access token and fetches messages.
# `transport` is anything responding to #call(method, url, headers, body) and
# returning [status, parsed_json]; tests pass a fake.
class Gmail::Client
  API = "https://gmail.googleapis.com/gmail/v1/users/me"
  TOKEN_URL = "https://oauth2.googleapis.com/token"

  class Error < StandardError; end

  def initialize(connection, transport: method(:http))
    @connection = connection
    @transport = transport
  end

  # Ids of messages matching a Gmail search query (all pages, capped).
  def message_ids(query, limit: 500)
    ids, page = [], nil
    loop do
      body = get("#{API}/messages", q: query, maxResults: 100, pageToken: page)
      ids.concat(Array(body["messages"]).map { _1["id"] })
      page = body["nextPageToken"]
      break if page.nil? || ids.size >= limit
    end
    ids.first(limit)
  end

  # A Receipts::Email for one message (headers + plain text).
  def message(id)
    body = get("#{API}/messages/#{id}", format: "full")
    headers = Array(body.dig("payload", "headers")).to_h { [ _1["name"].downcase, _1["value"] ] }
    Receipts::Email.new(
      message_id: id, from: headers["from"].to_s, subject: headers["subject"].to_s,
      date: (Time.zone.parse(headers["date"].to_s) rescue nil) || Time.zone.at(body["internalDate"].to_i / 1000),
      text: text_of(body["payload"] || {})
    )
  end

  private

  def get(url, params = {})
    refresh! if @connection.expired?
    status, json = @transport.call(:get, "#{url}?#{params.compact.to_query}",
                                   { "Authorization" => "Bearer #{@connection.access_token}" }, nil)
    raise Error, "Gmail returned #{status}: #{json&.dig("error", "message")}" unless status == 200

    json
  end

  def refresh!
    raise Error, "Gmail access was revoked; please reconnect" if @connection.refresh_token.blank?

    status, json = @transport.call(:post, TOKEN_URL, { "Content-Type" => "application/x-www-form-urlencoded" }, {
      client_id: ENV["GOOGLE_CLIENT_ID"], client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      refresh_token: @connection.refresh_token, grant_type: "refresh_token"
    }.to_query)
    raise Error, "Gmail access was revoked; please reconnect" unless status == 200

    @connection.update!(access_token: json["access_token"], expires_at: json["expires_in"].to_i.seconds.from_now)
  end

  # Prefer text/plain parts; fall back to stripped HTML.
  def text_of(part)
    parts = [ part, *Array(part["parts"]).flat_map { flatten(_1) } ]
    plain = parts.find { _1["mimeType"] == "text/plain" && _1.dig("body", "data") }
    return decode(plain.dig("body", "data")) if plain

    html = parts.find { _1["mimeType"] == "text/html" && _1.dig("body", "data") }
    html ? ActionController::Base.helpers.strip_tags(decode(html.dig("body", "data"))) : ""
  end

  def flatten(part) = [ part, *Array(part["parts"]).flat_map { flatten(_1) } ]

  def decode(data) = Base64.urlsafe_decode64(data).force_encoding("UTF-8").scrub

  def http(method, url, headers, body)
    uri = URI(url)
    request = (method == :post ? Net::HTTP::Post : Net::HTTP::Get).new(uri, headers)
    request.body = body if body
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 20) { _1.request(request) }
    [ response.code.to_i, (JSON.parse(response.body) rescue nil) ]
  end
end
