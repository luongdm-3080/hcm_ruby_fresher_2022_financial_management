class WalletsController < ApplicationController
  before_action :logged_in_user
  before_action :load_wallet, :user_correct_wallet, only: :show
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

  def index
    @wallets = current_user.wallets.newest
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
