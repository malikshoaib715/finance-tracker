class Reports::YearsController < ApplicationController
  def show
    year = params[:year].to_i
    year = Date.current.year unless year.between?(2000, Date.current.year)
    @review = Reports::YearReview.new(current_user, year: year)
  end
end
