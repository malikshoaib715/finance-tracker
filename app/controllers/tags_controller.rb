class TagsController < ApplicationController
  before_action :set_tag, only: %i[ update destroy ]

  def index
    @tags = current_user.tags.left_joins(:taggings).group(:id).select("tags.*, COUNT(taggings.id) AS usage_count").alphabetical
  end

  def update
    result = @tag.rename_or_merge(params.require(:tag)[:name])

    if result == true
      redirect_to tags_path, notice: "Renamed to ##{@tag.name}."
    elsif result.is_a?(Tag)
      redirect_to tags_path, notice: "Merged into ##{result.name}."
    else
      redirect_to tags_path, alert: @tag.errors.full_messages.to_sentence
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_path, notice: "Tag ##{@tag.name} removed.", status: :see_other
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  end
end
