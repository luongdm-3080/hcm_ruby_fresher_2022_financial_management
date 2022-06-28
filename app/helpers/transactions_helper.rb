module TransactionsHelper
  def total_of_transactions status, day = Time.zone.today.all_day
    Transaction.transactions_today(@wallet_id, day).status_transaction(status)
  end

  def total_damage income_total, expense_total
    income_total - expense_total
  end

  def transactions_today_get category, day = Time.zone.today.all_day
    category.transactions.transactions_today(@wallet_id, day)
  end
end
