# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user
    return if user.blank?

    user_can user
    return unless user.admin?

    admin_can
  end

  private

  def user_can user
    can :manage, [Wallet, Category], user_id: user.id
    can :manage, Transaction, wallet_id: user.wallets.ids
  end

  def admin_can
    can :manage, :all
  end
end
