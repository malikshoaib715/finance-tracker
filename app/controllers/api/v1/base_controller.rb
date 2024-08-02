# JSON API for the mobile app and scripts. Authenticates with
# `Authorization: Bearer <token>`; no cookies, sessions or CSRF.
class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate!
  around_action :use_user_time_zone

  rescue_from ActiveRecord::RecordNotFound, with: -> { render_error(:not_found, "Not found") }
  rescue_from ActionController::ParameterMissing, with: ->(e) { render_error(:bad_request, e.message) }

  private

  attr_reader :current_user

  def authenticate!
    api_token = authenticate_with_http_token { |token, _| ApiToken.authenticate(token) }
    return render_error(:unauthorized, "Missing or invalid API token") unless api_token

    @current_user = api_token.user
  end

  def use_user_time_zone(&)
    current_user ? Time.use_zone(current_user.time_zone, &) : yield
  end

  def render_error(status, message, details: nil)
    render json: { error: { message:, details: }.compact }, status:
  end

  def render_invalid(record)
    render_error(:unprocessable_entity, record.errors.full_messages.to_sentence, details: record.errors.to_hash)
  end
end
