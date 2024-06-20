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
  has_many :categories, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :rules, dependent: :delete_all
  has_many :goals, dependent: :delete_all
  has_many :exchange_rates, dependent: :delete_all
  has_many :budgets, dependent: :delete_all

  after_create_commit -> { Category.create_defaults_for(self) }

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 80 }
  validates :currency, inclusion: { in: CURRENCIES }
  enum :number_format, { international: "international", south_asian: "south_asian" },
       default: :international, validate: true, prefix: :numbers

  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  def first_name
    name.split.first
  end

  def initials
    name.split.first(2).map(&:first).join.upcase
  end
end
