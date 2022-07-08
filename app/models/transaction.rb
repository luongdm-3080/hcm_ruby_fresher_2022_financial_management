class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :category
  CREATE_ATTRS = %i(total description category_id
    wallet_id transaction_date).freeze

  validates :total, presence: true, numericality: {only_integer: true}
  validates :description, length: {maximum: Settings.digits.length_text_max_20}
  validates :transaction_date, presence: true

  delegate :name, :category_type, to: :category
  scope :transactions_today, (lambda do |wallet_id, start_day, end_day|
    where wallet_id: wallet_id, transaction_date: start_day..end_day
  end)
  scope :category_type_transaction, (lambda do |category_type|
    Transaction.joins(:category)
    .where categories: {category_type: category_type}
  end)
  scope :latest, ->{order(transaction_date: :desc).limit Settings.latest}
  scope :category_transaction, ->{Transaction.joins(:category)}
end
