class User < ApplicationRecord
  CURRENCIES = %w[PKR USD EUR GBP AED SAR].freeze

  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable

  # Transactions first: accounts refuse to be destroyed while they still have any.
  has_many :imports, dependent: :delete_all
  has_many :recurring_transactions, dependent: :delete_all
  has_many :transactions, dependent: :delete_all
  has_many :transfers, dependent: :delete_all
  has_many :accounts, dependent: :destroy
  belongs_to :default_account, class_name: "Account", optional: true
  has_many :categories, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :rules, dependent: :delete_all
  has_many :goals, dependent: :delete_all
  has_many :exchange_rates, dependent: :delete_all
  has_many :api_tokens, dependent: :delete_all
  has_many :deletions, dependent: :delete_all
  has_many :budgets, dependent: :delete_all

  after_create_commit -> { Category.create_defaults_for(self) }

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 80 }
  validates :currency, inclusion: { in: CURRENCIES }
  enum :number_format, { international: "international", south_asian: "south_asian" },
       default: :international, validate: true, prefix: :numbers

  validate :default_account_is_own, if: :default_account_id?

  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  # Changes whenever anything that feeds the reports changes: used as a cache
  # key so charts are only recomputed after new activity.
  def finance_cache_version
    [ transactions, transfers, accounts, budgets, exchange_rates ].map do |relation|
      relation.reorder(nil).pick(Arel.sql("COUNT(*), MAX(updated_at)"))
    end.flatten.join("-")
  end

  def first_name
    name.split.first
  end

  def initials
    name.split.first(2).map(&:first).join.upcase
  end

  # The account forms should start with: the chosen default, else the first one.
  def preferred_account(accounts = self.accounts.active.ordered)
    accounts.find { |account| account.id == default_account_id } || accounts.first
  end

  private

  def default_account_is_own
    errors.add(:default_account, "is not one of yours") unless accounts.exists?(default_account_id)
  end
end
