class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :category
  CREATE_ATTRS = %i(total text category_id wallet_id transaction_date).freeze

  validates :total, presence: true, numericality: {only_integer: true}
  validates :description, length: {maximum: Settings.digits.length_text_max_20}
  validates :transaction_date, presence: true

  delegate :name, :category_type, to: :category
  scope :transactions_today, (lambda do |wallet_id, day|
    where wallet_id: wallet_id, transaction_date: day
  end)
  scope :status_transaction, (lambda do |status|
    Transaction.joins(:category).where categories: {category_type: status}
  end)
  scope :latest_transaction, ->{order(created_at: :desc).limit Settings.latest}
end
