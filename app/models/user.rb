class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_many :wallets, dependent: :destroy
  has_many :categories, dependent: :destroy
  enum role: {user: 0, admin: 1}

  validates :name, presence: true,
            length: {maximum: Settings.digits.length_name_max_25}

  scope :order_by_name, ->{order name: :asc}
  delegate :total_category, to: :categories
  delegate :total_wallet, :sum_balance, to: :wallets
  before_save :downcase_email

  private

  def downcase_email
    email.downcase!
  end
end
