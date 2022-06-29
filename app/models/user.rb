class User < ApplicationRecord
  has_many :wallets, dependent: :destroy
  has_many :categories, dependent: :destroy
  enum role: {user: 0, admin: 1}
  VALID_EMAIL_REGEX = Settings.regex.email
  USER_SINGUP_ATTRS = %i(name email password password_confirmation).freeze

  attr_accessor :remember_token, :activation_token

  validates :name, presence: true,
            length: {maximum: Settings.digits.length_name_max_25}
  validates :email, presence: true,
            length: {maximum: Settings.digits.length_email_max_50},
            format: {with: VALID_EMAIL_REGEX}
  validates :password, presence: true,
            length: {minimum: Settings.digits.length_password_min_6}

  scope :order_by_name, ->{order name: :asc}
  delegate :total_category, to: :categories
  delegate :total_wallet, :sum_balance, to: :wallets
  before_save :downcase_email
  before_create :create_activation_digest
  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end

      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")

    return false unless digest

    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns(activated: true,
                   activated_at: Time.zone.now,
                   activation_digest: nil)
  end

  def forget
    update_column :remember_digest, nil
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
