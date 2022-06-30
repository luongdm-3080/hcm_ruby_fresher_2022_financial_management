class Category < ApplicationRecord
  has_many :transactions, dependent: :destroy
  enum category_type: {income: 0, expense: 1}
  CATEGORY_CREATE_ATTRS = %i(name category_type).freeze
  validates :name, presence: true,
            length: {maximum: Settings.digits.length_name_max_25}

  scope :order_by_name, ->{order name: :asc}

  def self.total_category
    Category.count
  end
end
