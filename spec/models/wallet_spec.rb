require 'rails_helper'

RSpec.describe Wallet, type: :model do
  let(:user) {FactoryBot.create :user}
  let!(:wallet_1) {FactoryBot.create :wallet, user_id: user.id, balance: 3, id: 1}
  let!(:wallet_2) {FactoryBot.create :wallet, created_at: (Time.zone.now + 12), user_id: user.id, balance: 3, id: 2}
  let!(:wallet_3) {FactoryBot.create :wallet, created_at: (Time.zone.now + 55), user_id: user.id, balance: 3, id: 3}

  describe "Associations" do
    it {is_expected.to belong_to(:user)}
    it {is_expected.to have_many(:transactions).dependent(:destroy)}
  end

  describe "Validations" do
    subject{FactoryBot.build(:wallet)}

    context "when field name" do
      it {is_expected.to validate_presence_of(:name)}
      it {is_expected.to validate_length_of(:name).is_at_most(Settings.digits.length_name_max_25)}
    end

    context "when field balance" do
      it {is_expected.to validate_presence_of(:balance)}
      it {is_expected.to validate_numericality_of(:balance).only_integer}
    end
  end

  describe "scope" do
    it "check scope wallet newest" do
      expect(Wallet.newest.pluck(:id)).to eq([wallet_3.id, wallet_2.id, wallet_1.id])
    end
  end

  describe "Public class methods" do
    subject {Wallet}

    describe "responds to its methods" do
      it {is_expected.to respond_to :total_wallet}
      it {is_expected.to respond_to :sum_balance}
    end

    describe ".total_wallet" do
      it "returns total wallet" do
        expect(Wallet.total_wallet).to eq 3
      end
    end
    describe ".sum_balance" do
      it "returns sum balance" do
        expect(Wallet.sum_balance).to eq 9
      end
    end
  end
end
