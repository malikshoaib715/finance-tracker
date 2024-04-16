class ImportsController < ApplicationController
  def index
    @imports = current_user.imports.includes(:account).recent_first
  end

  def new
    @import = current_user.imports.build(account: current_user.accounts.active.alphabetical.first)
    @accounts = current_user.accounts.active.alphabetical
  end

  def create
    @import = current_user.imports.build(import_params)

    if @import.save
      redirect_to edit_import_path(@import)
    else
      @accounts = current_user.accounts.active.alphabetical
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @import = current_user.imports.find(params[:id])
  end

  private

  def import_params
    params.require(:import).permit(:account_id, :file)
  end
end
