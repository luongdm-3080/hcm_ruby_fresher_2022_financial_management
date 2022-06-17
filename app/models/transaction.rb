class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :user
  belongs_to :category

  validates :total, presence: true, numericality: {only_integer: true}
  validates :text, length: {maximum: Settings.digits.length_text_max_20}
end
