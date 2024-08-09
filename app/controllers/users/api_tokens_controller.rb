class Users::ApiTokensController < ApplicationController
  def index
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    @new_token = flash[:new_api_token]
  end

  def create
    token = current_user.api_tokens.build(name: params.require(:api_token)[:name])
    if token.save
      # Shown exactly once; only the digest is stored.
      flash[:new_api_token] = token.plain_token
      redirect_to api_tokens_path, notice: "Token “#{token.name}” created. Copy it now — it won't be shown again."
    else
      redirect_to api_tokens_path, alert: token.errors.full_messages.to_sentence
    end
  end

  def destroy
    token = current_user.api_tokens.find(params[:id])
    token.destroy
    redirect_to api_tokens_path, notice: "Token “#{token.name}” revoked.", status: :see_other
  end
end
