class Categories::MergesController < ApplicationController
  def create
    category = current_user.categories.find(params[:category_id])
    target = current_user.categories.where(kind: category.kind).find(params[:target_id])

    category.merge_into(target)
    redirect_to category_path(target), notice: "#{category.name} was merged into #{target.name}."
  end
end
