# Mobile sign-in: exchanges email + password for a device token. Goes through
# Devise's checks (confirmed, not locked) and counts failed attempts toward the lock.
class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authenticate!, only: :create

  def create
    user = User.find_for_authentication(email: params.require(:email).to_s.downcase.strip)

    if user&.valid_for_authentication? { user.valid_password?(params.require(:password).to_s) } && user.active_for_authentication?
      token = user.api_tokens.create!(name: params[:device_name].presence || "Mobile app")
      render json: { token: token.plain_token, user: user.slice(:id, :name, :email, :currency) }, status: :created
    elsif user&.access_locked?
      render_error(:unauthorized, "Your account is locked. Check your email to unlock it.")
    else
      render_error(:unauthorized, "Invalid email or password")
    end
  end

  # Signs this device out by revoking the token it used.
  def destroy
    ApiToken.find_by(token_digest: ApiToken.digest(request.authorization.to_s.delete_prefix("Bearer ")))&.destroy
    head :no_content
  end
end
