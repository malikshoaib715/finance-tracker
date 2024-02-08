class User < ApplicationRecord
  CURRENCIES = %w[PKR USD EUR GBP AED SAR].freeze

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

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
