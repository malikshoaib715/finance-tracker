class Tagging < ApplicationRecord
  belongs_to :owner_transaction, class_name: "Transaction", foreign_key: :transaction_id, inverse_of: :taggings
  belongs_to :tag
end
