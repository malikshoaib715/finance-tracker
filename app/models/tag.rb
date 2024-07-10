class Tag < ApplicationRecord
  belongs_to :user
  has_many :taggings, dependent: :delete_all
  has_many :transactions, through: :taggings

  normalizes :name, with: ->(name) { name.squish.downcase.delete_prefix("#") }

  validates :name, presence: true, length: { maximum: 30 },
            uniqueness: { scope: :user_id, case_sensitive: false }

  scope :alphabetical, -> { order(:name) }

  # Renaming onto an existing tag merges the two: taggings move over, this one goes.
  def rename_or_merge(new_name)
    target = user.tags.where.not(id: id).find_by(name: self.class.normalize_value_for(:name, new_name))
    return update(name: new_name) unless target

    transaction do
      taggings.where(transaction_id: target.taggings.select(:transaction_id)).delete_all
      taggings.update_all(tag_id: target.id)
      destroy!
    end
    target
  end
end
