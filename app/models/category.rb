class Category < ApplicationRecord
  has_many :transactions, dependent: :destroy
  enum category_type: {income: 0, expense: 1}
  validates :name, presence: true,
            length: {maximum: Settings.digits.length_name_max_25}
end
