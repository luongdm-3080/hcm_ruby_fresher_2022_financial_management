class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_transaction, only: %i(update destroy)
  before_action :user_correct_wallet, only: %i(index chart_analysis)
  before_action :load_transaction_of_wallet, only: :show
  before_action :time_start_day, :time_end_day, only: %i(index chart_analysis)
  authorize_resource

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

  def chart_analysis
    @wallet_id = params[:wallet_id]
    @date_of_transactions = data_of_transactions
  end

  private

  def transaction_params
    params.require(:transaction).permit(Transaction::CREATE_ATTRS)
  end

  def data_of_transactions
    Transaction.transactions_today(@wallet_id, @start_day, @end_day)
  end

  def load_transaction_of_wallet
    @transaction = Transaction.find_by id: params[:id]
    return if @transaction&.wallet_id == params[:wallet_id].to_i

    flash[:danger] = t "not_found"
    redirect_to new_wallet_path
  end

  def load_transaction
    @transaction = Transaction.find_by id: params[:id]
    @wallet_id = @transaction.wallet_id
    return if @transaction

    flash[:danger] = t "not_found"
    redirect_to path_to_wallets
  end

  def user_correct_wallet
    @wallet = Wallet.find_by id: params[:wallet_id] || @wallet_id
    return redirect_to new_wallet_path if @wallet.nil?

    return if current_user? @wallet.user_id

    flash[:danger] = t ".unauthorization"
    redirect_to new_wallet_path
  end

  def time_start_day
    if params[:start_day].blank?
      return @start_day = Time.zone.now.beginning_of_day
    end

    @start_day = params[:start_day]
  end

  def time_end_day
    return @end_day = Time.zone.now.end_of_day if params[:end_day].blank?

    @end_day = params[:end_day]
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
