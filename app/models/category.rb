class Category < ApplicationRecord
  COLORS = %w[slate red orange amber lime emerald teal sky indigo violet pink].freeze

  DEFAULTS = {
    expense: [
      [ "Groceries", "lime" ], [ "Rent", "indigo" ], [ "Utilities", "amber" ], [ "Transport", "sky" ],
      [ "Eating out", "orange" ], [ "Health", "red" ], [ "Shopping", "pink" ], [ "Education", "violet" ],
      [ "Mobile & internet", "teal" ], [ "Other", "slate" ]
    ],
    income: [
      [ "Salary", "emerald" ], [ "Freelance", "teal" ], [ "Profit & returns", "lime" ], [ "Other income", "slate" ]
    ]
  }.freeze

  belongs_to :user

  enum :kind, { expense: "expense", income: "income" }, default: :expense, validate: true

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 40 },
            uniqueness: { scope: [ :user_id, :kind ], case_sensitive: false }
  validates :color, inclusion: { in: COLORS }

  scope :alphabetical, -> { order(:name) }

  def self.create_defaults_for(user)
    DEFAULTS.each do |kind, categories|
      categories.each do |name, color|
        user.categories.find_or_create_by!(kind: kind, name: name) { |c| c.color = color }
      end
    end
  end
end
