# "If the description contains PATTERN, file it under CATEGORY."
class Rule < ApplicationRecord
  belongs_to :user
  belongs_to :category

  normalizes :pattern, with: ->(pattern) { pattern.squish }

  validates :pattern, presence: true, length: { minimum: 2, maximum: 60 },
            uniqueness: { scope: :user_id, case_sensitive: false }
  validate :category_belongs_to_user

  scope :longest_first, -> { order(Arel.sql("length(pattern) DESC"), :id) }

  def matches?(description)
    description.to_s.downcase.include?(pattern.downcase)
  end

  # The most specific (longest) matching rule's category for +description+ and +kind+.
  def self.category_for(user, description, kind)
    user.rules.includes(:category).longest_first
      .find { |rule| rule.category.kind == kind.to_s && rule.matches?(description) }&.category
  end

  private

  def category_belongs_to_user
    errors.add(:category, "is not one of yours") if category && category.user_id != user_id
  end
end
