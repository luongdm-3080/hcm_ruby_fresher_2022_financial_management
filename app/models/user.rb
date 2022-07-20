class User < ApplicationRecord
  acts_as_paranoid
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  has_many :wallets, dependent: :destroy
  has_many :categories, dependent: :destroy
  enum role: {user: 0, admin: 1}

  validates :name, presence: true,
            length: {maximum: Settings.digits.length_name_max_25}

  scope :order_by_name, ->{order name: :asc}
  ransack_alias :user, :name_or_email
  delegate :total_category, to: :categories
  delegate :total_wallet, :sum_balance, to: :wallets
  before_save :downcase_email

  def self.from_omniauth auth
    @user = where(email: auth.info.email).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.skip_confirmation!
    end

    @user.update_user
    @user
  end

  def update_user
    user_provider_ready = @user && !@user.provider && !@user.uid
    @user.update(provider: auth.provider, uid: auth.uid) if user_provider_ready
  end

  private

  def downcase_email
    email.downcase!
  end

  ransacker :created_at, type: :date do
    Arel.sql("date(created_at)")
  end
end
