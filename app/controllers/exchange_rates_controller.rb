class ExchangeRatesController < ApplicationController
  def index
    @rates = current_user.exchange_rates.order(:currency)
    @missing = current_user.accounts.active.distinct.pluck(:currency) - [ current_user.currency ] - @rates.map(&:currency)
    @rate = current_user.exchange_rates.build(currency: @missing.first)
  end

  def create
    @rate = current_user.exchange_rates.find_or_initialize_by(currency: rate_params[:currency])
    @rate.rate = rate_params[:rate]

    if @rate.save
      redirect_to exchange_rates_path, notice: "1 #{@rate.currency} = #{@rate.rate.to_s("F")} #{current_user.currency}."
    else
      redirect_to exchange_rates_path, alert: @rate.errors.full_messages.to_sentence
    end
  end

  def destroy
    current_user.exchange_rates.find(params[:id]).destroy
    redirect_to exchange_rates_path, notice: "Rate removed.", status: :see_other
  end

  private

  def rate_params
    params.require(:exchange_rate).permit(:currency, :rate)
  end
end
