class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :use_user_time_zone, if: :user_signed_in?

  private

  def use_user_time_zone(&)
    Time.use_zone(current_user.time_zone, &)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :currency, :time_zone ])
  end
end
