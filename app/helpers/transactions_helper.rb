module TransactionsHelper
  def category_type_of_transactions category_type
    change = Transaction.transactions_today(@wallet_id, @start_day, @end_day)
    change.category_type_transaction(category_type).soon
  end

  def total_damage income_total, expense_total
    income_total - expense_total
  end

  def transactions_by_date category
    category.transactions.transactions_today(@wallet_id, @start_day, @end_day).soon
  end
end
