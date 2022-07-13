require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe "Associations" do
    it {is_expected.to belong_to(:wallet)}
    it {is_expected.to belong_to(:category)}
  end

  describe "Validations" do
    subject{FactoryBot.build(:transaction)}

    context "when field description" do
      it {is_expected.to validate_length_of(:description).is_at_most(Settings.digits.length_text_max_20)}
    end

    context "when field total" do
      it {is_expected.to validate_presence_of(:total)}
      it {is_expected.to validate_numericality_of(:total).only_integer}
    end

    context "when field transaction_date" do
      it {is_expected.to validate_presence_of(:transaction_date)}
    end
  end

  describe "Scope" do
    let(:user) {FactoryBot.create :user}
    let(:wallet){FactoryBot.create :wallet, user_id: user.id}
    let(:category_1){FactoryBot.create :category, category_type: 1, user_id: user.id}
    let(:category_2){FactoryBot.create :category, category_type: 0, user_id: user.id}
    let!(:transaction_1){FactoryBot.create :transaction, category_id: category_1.id, wallet_id: wallet.id}
    let!(:transaction_2){FactoryBot.create :transaction, category_id: category_1.id, wallet_id: wallet.id, transaction_date: (Time.zone.now + 12)}

    before do
      @ids = [transaction_2.id, transaction_1.id]
    end

    describe ".category_type transaction" do
      context "when found" do
        it "search transaction by category_type" do
          expect(Transaction.latest.category_type_transaction(1).pluck(:id)).to eq(@ids)
        end
      end

      context "when not found" do
        it "should be empty" do
          expect(Transaction.category_type_transaction(0).pluck(:id)).to eq []
        end
      end
    end

    describe ".transactions_today" do
      before(:all){
        @start_time = Time.zone.now.beginning_of_day
        @end_time = Time.zone.now.end_of_day
      }

      context "when found" do
        it "transaction by days" do
          expect(Transaction.latest.transactions_today(wallet.id, @start_time,
            @end_time).pluck(:id)).to eq(@ids)
        end
      end

      context "when not found" do
        it "should be empty" do
          expect(Transaction.transactions_today(wallet.id, @start_time - 24.hours,
            @end_time - 24.hours).pluck(:id)).to eq []
        end
      end
    end

    describe "by_transaction" do
      
      it "check scope by_transaction" do
        expect(Transaction.latest.by_transaction(wallet.id).pluck(:id)).to eq([transaction_2.id, transaction_1.id])
      end
    end
  end
end
