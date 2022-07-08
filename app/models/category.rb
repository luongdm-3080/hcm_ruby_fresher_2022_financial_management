class Category < ApplicationRecord
  belongs_to :user, optional: true
  has_many :transactions, dependent: :destroy
  enum category_type: {income: 0, expense: 1}
  enum type_name: {personal: 0, available: 1}
  CATEGORY_CREATE_ATTRS = %i(name category_type).freeze
  validates :name, presence: true,
            length: {maximum: Settings.digits.length_name_max_25}

  scope :order_by_name, ->{order name: :asc}

  def self.total_category
    Category.count
  end

  ransacker :sum_money_category do
    query = "(
      SELECT SUM(total)
      FROM transactions
      WHERE transactions.category_id = categories.id
      GROUP BY transactions.category_id
    )"
    Arel.sql(query)
  end

  ransacker :count_transaction do
    query = "(
      SELECT COUNT(*)
      FROM transactions
      WHERE transactions.category_id = categories.id
      GROUP BY transactions.category_id
    )"
    Arel.sql(query)
  end
end
