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

  # Loads a user's rules once and matches many descriptions against them.
  class Matcher
    def initialize(user)
      @rules = user.rules.includes(:category).longest_first.to_a
    end

    # The most specific (longest) matching rule's category for +description+ and +kind+.
    def category_for(description, kind)
      @rules.find { |rule| rule.category.kind == kind.to_s && rule.matches?(description) }&.category
    end
  end

  def self.category_for(user, description, kind)
    Matcher.new(user).category_for(description, kind)
  end

  # Categorise the user's existing uncategorised transactions. Returns how many changed.
  def self.apply_to_uncategorised(user)
    matcher = Matcher.new(user)
    user.transactions.where(category_id: nil).find_each.count do |transaction|
      category = matcher.category_for(transaction.description, transaction.kind)
      category && transaction.update_columns(category_id: category.id, updated_at: Time.current)
    end
  end

  private

  def category_belongs_to_user
    errors.add(:category, "is not one of yours") if category && category.user_id != user_id
  end
end
