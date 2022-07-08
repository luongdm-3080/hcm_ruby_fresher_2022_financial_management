require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "Associations" do
    it {is_expected.to belong_to(:user)}
    it {is_expected.to have_many(:transactions).dependent(:destroy)}
  end

  describe "Validations" do
    subject{FactoryBot.build(:category)}

    context "when field name" do
      it {is_expected.to validate_presence_of(:name)}
      it {is_expected.to validate_length_of(:name).is_at_most(Settings.digits.length_name_max_25)}
    end
  end

  describe "define enum for category_type" do
    it {is_expected.to define_enum_for :category_type}
  end

  describe "Public class methods" do
    let(:user) {FactoryBot.create :user}
    let!(:category_1) {FactoryBot.create :category, user_id: user.id}
    let!(:category_2) {FactoryBot.create :category, user_id: user.id}
    let!(:category_3) {FactoryBot.create :category, user_id: user.id}
    subject {Category}

    describe "responds to its methods" do
      it {is_expected.to respond_to :total_category}
    end

    describe ".total_category" do
      it "returns count category" do
        expect(Category.total_category).to eq 3
      end
    end

    describe "search ransacker" do
      let(:wallet){FactoryBot.create :wallet, user_id: user.id}
      let!(:transaction_1){FactoryBot.create :transaction, category_id: category_1.id, wallet_id: wallet.id, total: 11}
      let!(:transaction_2){FactoryBot.create :transaction, category_id: category_1.id, wallet_id: wallet.id, total: 9}
      it "gets category sum_money_category" do
        expect(Category.ransack(sum_money_category_gteq: transaction_1.total).result.pluck(:id)).to eq [category_1.id]
      end
      it "gets category count_transaciton" do
        expect(Category.ransack(count_transaction_gteq: 1).result.pluck(:id)).to eq [category_1.id]
      end
    end
  end
end
