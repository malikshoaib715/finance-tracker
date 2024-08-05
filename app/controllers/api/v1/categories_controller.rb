class Api::V1::CategoriesController < Api::V1::BaseController
  def index
    categories = current_user.categories.alphabetical
    render json: { categories: categories.map { |c| c.slice(:id, :name, :kind, :color, :updated_at) } }
  end
end
