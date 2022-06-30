class Wallet < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  WALLET_CREATE_ATTRS = %i(name balance).freeze

  validates :name, presence: true,
            length: {maximum: Settings.digits.length_name_max_25}
  validates :balance, presence: true, numericality: {only_integer: true}

  scope :newest, ->{order created_at: :desc}
  class << self
    def total_wallet
      Wallet.count
    end

    def sum_balance
      Wallet.sum(:balance)
    end
  end
end
