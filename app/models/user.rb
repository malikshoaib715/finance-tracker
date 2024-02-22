class User < ApplicationRecord
  CURRENCIES = %w[PKR USD EUR GBP AED SAR].freeze

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Transactions first: accounts refuse to be destroyed while they still have any.
  has_many :transactions, dependent: :delete_all
  has_many :accounts, dependent: :destroy
  has_many :categories, dependent: :destroy

  after_create_commit -> { Category.create_defaults_for(self) }

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 80 }
  validates :currency, inclusion: { in: CURRENCIES }
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  def first_name
    name.split.first
  end

  def initials
    name.split.first(2).map(&:first).join.upcase
  end
end
