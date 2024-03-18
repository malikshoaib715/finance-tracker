class Tag < ApplicationRecord
  belongs_to :user
  has_many :taggings, dependent: :delete_all
  has_many :transactions, through: :taggings

  normalizes :name, with: ->(name) { name.squish.downcase.delete_prefix("#") }

  validates :name, presence: true, length: { maximum: 30 },
            uniqueness: { scope: :user_id, case_sensitive: false }

  scope :alphabetical, -> { order(:name) }
end
