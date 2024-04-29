class Rules::ApplicationsController < ApplicationController
  def create
    count = Rule.apply_to_uncategorised(current_user)
    redirect_to rules_path, notice: count.zero? ? "No uncategorised transactions matched a rule." :
      "Categorised #{count} #{"transaction".pluralize(count)}."
  end
end
