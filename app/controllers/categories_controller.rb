class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_category, only: %i(update destroy)
  authorize_resource
  Pagy::DEFAULT[:items] = Settings.default_page

  def index
    @search = load_categories.ransack(params[:search])
    @pagy, @categories = pagy @search.result
    respond_to do |format|
      format.html
      format.js
    end
    store_location
    @category = Category.new
  end

  def create
    @category = current_user.categories.build category_params
    if @category.save
      flash[:success] = t ".success"
      redirect_back_or categories_path
    else
      respond_to :js
    end
  end

  def update
    ActiveRecord::Base.transaction do
      if @category.transactions.present?
        update_wallet
      else
        @category.update! category_params
      end
      respond_to do |format|
        format.js{flash.now[:success] = t ".edit_success_message"}
      end
    end
  rescue StandardError
    respond_to do |format|
      format.js{flash.now[:danger] = t ".edit_failure_message"}
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      update_wallet_category_old if @category.transactions.present?
      @category.destroy!
      flash[:success] = t ".success_message"
      redirect_back_or categories_path
    end
  rescue StandardError
    flash[:danger] = t ".failure_message"
    redirect_back_or categories_path
  end

  private

  def update_wallet
    update_wallet_category_old
    @category.update! category_params
    update_wallet_category_new
  end

  def category_params
    params.require(:category).permit(Category::CATEGORY_CREATE_ATTRS)
  end

  def load_category
    @category = Category.find_by id: params[:id]
    return if @category

    flash[:danger] = t ".not_found"
    redirect_to categories_path
  end

  def update_wallet_category_old
    if @category.income?
      update_balance_subtract
    else
      update_balance_add
    end
  end

  def update_wallet_category_new
    if @category.income?
      update_balance_add
    else
      update_balance_subtract
    end
  end

  def update_balance_add
    current_user.wallets.each do |wallet|
      total = @category.transactions.by_transaction(wallet.id).sum(:total)
      wallet.update! balance: wallet.balance + total
    end
  end

  def update_balance_subtract
    current_user.wallets.each do |wallet|
      total = @category.transactions.by_transaction(wallet.id).sum(:total)
      wallet.update! balance: wallet.balance - total
    end
  end
end
