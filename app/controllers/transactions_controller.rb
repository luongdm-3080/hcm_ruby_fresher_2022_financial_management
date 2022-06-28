class TransactionsController < ApplicationController
  before_action :logged_in_user
  before_action :user_correct_wallet, except: %i(create destroy update)
  before_action :load_wallet_transaction, only: %i(show)
  before_action :load_transaction, only: %i(update destroy)

  def index
    @wallet_id = params[:wallet_id]
    @transaction = Transaction.new
    @time_now = Time.zone.now.strftime(Settings.time)
  end

  def create
    @transaction = Transaction.new transaction_params
    if create_update_balance @transaction
      flash[:success] = t ".success"
      redirect_to wallet_transactions_path(@transaction.wallet_id)
    else
      respond_to :js
    end
  end

  def show; end

  def update
    if @transaction.update transaction_params
      respond_to do |format|
        format.js{flash.now[:success] = t ".edit_success_message"}
      end
    else
      respond_to do |format|
        format.js{flash.now[:danger] = t ".edit_failure_message"}
      end
    end
  end

  def destroy
    if @transaction.destroy
      flash[:success] = t ".success_message"
      redirect_to path_to_wallets
    else
      flash[:danger] = t ".failure_message"
      redirect_to @transaction
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(Transaction::CREATE_ATTRS)
  end

  def load_wallet_transaction
    @transaction = Transaction.find_by id: params[:id]
    return if @transaction&.wallet_id == @wallet.id

    flash[:danger] = t "not_found"
    redirect_to new_wallet_path
  end

  def load_transaction
    @transaction = Transaction.find_by id: params[:id]
    return if @transaction

    flash[:danger] = t "not_found"
    redirect_to path_to_wallets
  end

  def user_correct_wallet
    @wallet = Wallet.find_by id: params[:wallet_id]
    return redirect_to new_wallet_path if @wallet.nil?

    user_corrects @wallet.user_id, new_wallet_path
  end

  def create_update_balance transaction
    ActiveRecord::Base.transaction do
      transaction.save!
      wallet = Wallet.find_by id: transaction.wallet_id
      category = Category.find_by id: transaction.category_id
      if category.income?
        wallet.update! balance: wallet.balance + transaction.total
      else
        wallet.update! balance: wallet.balance - transaction.total
      end
    end
  rescue StandardError
    errors.add(:base, I18n.t(".failed_update"))
  end
end
