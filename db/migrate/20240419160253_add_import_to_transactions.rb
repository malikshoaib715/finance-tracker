class AddImportToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :transactions, :import, foreign_key: { on_delete: :nullify }
  end
end
