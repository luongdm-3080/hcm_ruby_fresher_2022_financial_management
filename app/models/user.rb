class User < ApplicationRecord
  has_many :wallets, dependent: :destroy
  has_many :categories, dependent: :destroy
  enum role: {user: 0, admin: 1}
  VALID_EMAIL_REGEX = Settings.regex.email
  USER_SINGUP_ATTRS = %i(name email password password_confirmation).freeze

  validates :name, presence: true,
            length: {maximum: Settings.digits.length_name_max_25}
  validates :email, presence: true,
            length: {maximum: Settings.digits.length_email_max_50},
            format: {with: VALID_EMAIL_REGEX}
  validates :password, presence: true,
            length: {minimum: Settings.digits.length_password_min_6}

  has_secure_password
end
