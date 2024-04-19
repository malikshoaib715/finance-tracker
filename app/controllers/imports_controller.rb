class ImportsController < ApplicationController
  include ActionView::Helpers::TextHelper
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
    @import = current_user.imports.find(params[:id]).suggest_mapping
  end

  def update
    @import = current_user.imports.find(params[:id])

    if @import.update(mapping_params.merge(status: "mapped"))
      redirect_to import_path(@import)
    else
      @import.status = "uploaded"
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @import = current_user.imports.find(params[:id])
  end

  def run
    import = current_user.imports.mapped.find(params[:id])
    import.run!
    redirect_to transactions_path, notice: "Imported #{pluralize(import.imported_count, "transaction")}" \
      "#{" (#{import.skipped_count} skipped)" if import.skipped_count.positive?}."
  end

  private

  def mapping_params
    params.require(:import).permit(:date_column, :description_column, :amount_mode, :amount_column,
                                   :debit_column, :credit_column, :date_format)
  end

  def import_params
    params.require(:import).permit(:account_id, :file)
  end
end
