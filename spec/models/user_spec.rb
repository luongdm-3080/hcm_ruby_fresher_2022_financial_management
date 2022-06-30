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

  describe "Scope" do
    let!(:user_one){FactoryBot.create :user, name: "user1"}
    let!(:user_two){FactoryBot.create :user, name: "user2"}
    let!(:user_three){FactoryBot.create :user, name: "user3"}
    it "orders by ascending name" do
      expect(User.order_by_name).to eq([user_one, user_two, user_three])
    end
  end
end
