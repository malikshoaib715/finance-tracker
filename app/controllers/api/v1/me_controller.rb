class Api::V1::MeController < Api::V1::BaseController
  def show
    render json: current_user.slice(:id, :name, :email, :currency, :time_zone, :number_format)
  end
end
