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
  end
end
