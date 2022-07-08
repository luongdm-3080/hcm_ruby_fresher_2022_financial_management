class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_transaction, :transaction_old, only: %i(update destroy)
  before_action :load_wallet, only: %i(index chart_analysis)
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
    if create_update_balance
      flash[:success] = t ".success"
      redirect_to wallet_transactions_path(@transaction.wallet_id)
    else
      respond_to do |format|
        format.js{flash.now[:danger] = t ".failure_message"}
      end
    end
  end

  def show; end

  def update
    return unless update_transaction

    respond_to do |format|
      format.js{flash.now[:success] = t ".edit_success_message"}
    end
  end

  def destroy
    return unless delete_transaction

    flash[:success] = t ".success_message"
    redirect_to path_to_wallets
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
    return if @transaction

    flash[:danger] = t "not_found"
    redirect_to path_to_wallets
  end

  def transaction_old
    @wallet_id = @transaction.wallet_id
    @total_old = @transaction.total
    @category_type_old = @transaction.category_type
    @wallet_old = Wallet.find_by id: @wallet_id
  end

  def user_correct_wallet
    return redirect_to new_wallet_path if @wallet.nil?

    return if current_user? @wallet.user_id

    flash[:danger] = t ".unauthorization"
    redirect_to new_wallet_path
  end

  def load_wallet
    if current_user.wallets.present? && params[:wallet_id].nil?
      params[:wallet_id] = current_user.wallets.first.id
    end
    @wallet = Wallet.find_by id: params[:wallet_id] || @wallet_id
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

  def create_update_balance
    ActiveRecord::Base.transaction do
      @transaction = Transaction.create transaction_params
      @transaction.save!
      update_wallet_transaction_new
    end
  rescue StandardError
    respond_to :js
  end

  def update_transaction
    ActiveRecord::Base.transaction do
      @transaction.update! transaction_params
      update_wallet_transaction_old
      update_wallet_transaction_new
    end
  rescue StandardError
    respond_to do |format|
      format.js{flash.now[:danger] = t ".edit_failure_message"}
    end
  end

  def delete_transaction
    ActiveRecord::Base.transaction do
      @transaction.destroy!
      update_wallet_transaction_old
    end
  rescue StandardError
    flash[:danger] = t ".failure_message"
    redirect_to wallet_transaction_path(wallet_id: @wallet_id,
                                        id: @transaction.id) and return
  end

  def update_wallet_transaction_old
    if @category_type_old == "income"
      @wallet_old.update! balance: @wallet_old.balance - @total_old
    else
      @wallet_old.update! balance: @wallet_old.balance + @total_old
    end
  end

  def update_wallet_transaction_new
    wallet = Wallet.find_by id: @transaction.wallet_id
    category = @transaction.category
    if category.income?
      wallet.update! balance: wallet.balance + @transaction.total
    else
      wallet.update! balance: wallet.balance - @transaction.total
    end
  end
end
