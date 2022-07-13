module ApplicationHelper
  include Pagy::Frontend

  def full_title page_title
    base_title = t "base_title"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def load_categories
    current_user.categories.personal.or(Category.available)
  end

  def load_wallets
    current_user.wallets
  end

  def path_to_wallets
    return new_wallet_path if load_wallets.first&.id.nil?

    wallet_transactions_path(load_wallets.first.id)
  end

  def path_to_chart
    return new_wallet_path if load_wallets.first&.id.nil?

    chart_wallet_transactions_path(load_wallets.first.id)
  end

  def category_transactions category
    if category.personal?
      category.transactions
    else
      category.transactions.by_transaction(load_wallets.ids)
    end
  end
end
