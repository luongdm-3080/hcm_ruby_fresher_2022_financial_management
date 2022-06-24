class WalletsController < ApplicationController
  before_action :logged_in_user
  before_action :load_wallet, :user_correct_wallet, except: %i(create index new)

  def index
    @wallets = current_user.wallets.newest
  end

  def new
    @wallet = Wallet.new
  end

  def create
    @wallet = current_user.wallets.build wallet_params
    if @wallet.save
      flash[:success] = t ".success"
      redirect_to wallets_url
    else
      flash.now[:danger] = t ".failure"
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @wallet.update wallet_params
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
    if @wallet.destroy
      respond_to do |format|
        format.js{flash.now[:success] = t ".deleted_message"}
      end
    else
      respond_to do |format|
        format.js{flash.now[:danger] = t ".delete_failed_message"}
      end
    end
  end

  private

  def wallet_params
    params.require(:wallet).permit(Wallet::WALLET_CREATE_ATTRS)
  end

  def load_wallet
    @wallet = Wallet.find_by id: params[:id]
    return if @wallet

    flash[:danger] = t ".not_found"
    redirect_to wallets_url
  end

  def user_correct_wallet
    return if current_user? @wallet.user_id

    flash[:danger] = t ".unauthorization"
    redirect_to wallets_url
  end
end
