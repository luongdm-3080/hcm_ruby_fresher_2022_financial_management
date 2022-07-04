require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Associations" do
    it {is_expected.to have_many(:wallets).dependent(:destroy)}
    it {is_expected.to have_many(:categories).dependent(:destroy)}
  end

  describe "Validations" do
    subject{FactoryBot.build(:user)}

    context "when field name" do
      it {is_expected.to validate_presence_of(:name)}
      it {is_expected.to validate_length_of(:name).is_at_most(Settings.digits.length_name_max_25)}
    end

    context "when field email" do
      it {is_expected.to validate_presence_of(:email)}
      it {is_expected.to validate_length_of(:email).is_at_most(Settings.digits.length_email_max_50)}
      it {is_expected.to validate_uniqueness_of(:email).case_insensitive}
    end

    context "when field password" do
      it {is_expected.to validate_length_of(:password).is_at_least(Settings.digits.length_password_min_6)}
      it {is_expected.to validate_confirmation_of(:password)}
    end
  end

  describe "define enum for role" do
    it {is_expected.to define_enum_for :role}
  end

  describe "Public instance methods" do
    let(:user){FactoryBot.create :user}

    describe "responds to its methods" do
      methods = [:remember, :authenticated?, :forget, :activate, :send_activation_email, :create_reset_digest, :send_password_reset_email, :password_reset_expired?]
      context "when responds methods" do
        methods.each do |method|
          it {is_expected.to respond_to method}
        end
      end
    end

    describe "#remember" do
      it "returns true" do
        expect(user.remember).to be true
      end
    end

    describe "#forget" do
      it "returns true" do
        expect(user.forget).to be true
      end
    end

    describe "#authenticated?" do
      context "when correct token" do
        it "returns true" do
          token = User.new_token
          remember_token = User.digest token
          user.update_column :remember_digest, remember_token

          expect(user.authenticated?(:remember, token)).to be true
        end
      end

      context "when uncorrect token" do
        it "returns false" do
          remember_token = User.digest User.new_token
          user.update_column :remember_digest, remember_token

          expect(user.authenticated?(:remember, "unkown")).to be false
        end
      end

      context "when digest for token is nil" do
        it { expect(user.authenticated?(:remember, "unknown")).to be false }
      end
    end

    describe "#activate" do
      it "return true" do
        expect(user.activate).to be true
      end
    end

    describe "#send_activation_email" do
      before { user.send_activation_email }

      context "send email true" do
        it { expect(user.activation_digest).to_not be_nil }
        it { expect(ActionMailer::Base.deliveries.count(1)) }
      end
    end

    describe "#create_reset_digest" do
      it "return true" do
        expect(user.create_reset_digest).to be true
      end
    end

    describe "#send_password_reset_email" do
      it "send password reset true" do
        user.create_reset_digest
        user.send_password_reset_email
        expect(user.reset_digest).to_not be_nil
        expect(ActionMailer::Base.deliveries.count(1))
      end
    end

    describe " #password_reset" do
      context "password_reset_expired" do
        it "return false" do
          user.update_column :reset_sent_at, Time.zone.now
          expect(user.password_reset_expired?).to be false
        end
        it "return true" do
          time = Time.zone.now - Settings.digits.expired_reset_password_time.hours
          user.update_column :reset_sent_at ,time
          expect(user.password_reset_expired?).to be true
        end
      end
    end
  end

  describe "Public class methods" do
    subject {User}

    describe "responds to its methods" do
      it {is_expected.to respond_to :new_token}
      it {is_expected.to respond_to :digest}
    end

    describe ".new_token" do
      it "returns a token with length is 22" do
        expect(subject.new_token.size).to eq 22
      end
    end

    describe ".digest" do

      context "when min_cost is present" do
        it "returns a digest with length is 60" do
          ActiveModel::SecurePassword.min_cost = 8
          expect(subject.digest(subject.new_token).size).to eq 60
        end
      end

      context "when min_cost is nil" do
        it "returns a digest with length is 60" do
          ActiveModel::SecurePassword.min_cost = nil
          expect(subject.digest(subject.new_token).size).to eq 60
        end
      end
    end
  end

  describe "Scope" do
    let!(:user_one){FactoryBot.create :user, name: "user1"}
    let!(:user_two){FactoryBot.create :user, name: "user2"}
    let!(:user_three){FactoryBot.create :user, name: "user3"}
    it "orders by ascending name" do
      expect(User.order_by_name).to eq([user_one, user_two, user_three])
    end
  end
end
