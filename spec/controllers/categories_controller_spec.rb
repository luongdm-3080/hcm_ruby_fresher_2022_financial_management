require "rails_helper"
include SessionsHelper
require "cancan/matchers"
RSpec.describe CategoriesController, type: :controller do
  let(:user) {FactoryBot.create :user}
  let(:wallet){FactoryBot.create :wallet, user_id: user.id}
  let!(:category_1) {FactoryBot.create :category, user_id: user.id, name: "category_3"}
  let!(:category_2) {FactoryBot.create :category, user_id: user.id, name: "category_2"}
  let!(:category_3) {FactoryBot.create :category, user_id: user.id, name: "category_1"}
  let!(:transaction_1){FactoryBot.create :transaction, category_id: category_1.id, wallet_id: wallet.id, total: 11}
  let!(:transaction_2){FactoryBot.create :transaction, category_id: category_1.id, wallet_id: wallet.id, total: 10}
  let!(:transaction_3){FactoryBot.create :transaction, category_id: category_2.id, wallet_id: wallet.id, total: 9}

  describe "GET #index" do
    it_behaves_like "not logged for get method", "index"

    context "when user logged" do
      subject(:ability){Ability.new(user)}
      before do
        sign_in user
        @ids = [category_3.id, category_2.id, category_1.id]
      end

      context "when new category" do
        before {get :index}
        it { expect(assigns(:category)).to_not eq nil }
        it "should be success" do
          expect(assigns(:category)).to be_a_new(Category)
        end
      end

      context "when has categories" do
        before do
          params = {
            current_user_id: user.id,
          }
          get :index, params: params, xhr: true
        end
        it "returns a 200 response" do
          expect(response).to have_http_status "200"
        end

        it "gets wallet by params scope" do
          expect(assigns(:categories).order_by_name.pluck(:id)).to eq(@ids)
        end

        it {expect(assigns(:pagy).count).to eq 3}
        it {expect(ability).to be_able_to(:manage, Category, user_id: user.id)}

        it "render index" do
          expect(response).to render_template :index
        end
      end

      context "when search params" do
        before do
          get :index, params: {
            search: {sum_money_category_gteq: 20, sum_money_category_lteq: 21} }
        end
        it "should find just categories" do
          expect(assigns(:categories)).to eq [category_1]
        end
      end
    end
  end

  describe "POST create" do
    it_behaves_like "not logged for other method" do
      before do
        post :create, params: {
          category: { name: "test", category_type: "income"} }
      end
    end

    context "when user logged" do
      before do
        sign_in user
        post :create, params: {
          category: { name: "test", category_type: "income" } }
      end

      it "build category success" do
        expect(assigns(:category)).to eq(user.categories.last)
      end

      context "category save success" do
        it "show flash success" do
          expect(flash[:success]).to eq "Create category success"
        end

        it "redirect to category" do
          expect(response).to redirect_to categories_path
        end
      end

      context "category save failed" do
        before do
          sign_in user
          post :create, params: { category: { category_type: "income" } }, xhr: true
        end
        it "not show template" do
          response.should_not render_template :index
        end
      end
    end
  end

  describe "PATCH update" do
    it_behaves_like "not logged for methods" do
      before do
        patch :update, params: { id: category_1.id, category: { name: "test1", category_type: "income" } }, xhr: true
      end
    end

    context "when user logged" do
      before { sign_in user }
      it "update success" do
        patch :update, params: { id: category_1.id, category: { name: "test1", category_type: "income" } }, xhr: true
        expect(flash.now[:success]).to eq "Update success"
      end
      it "update failed" do
        patch :update, params: { id: category_1.id, category: { name: nil , category_type: "income" } }, xhr: true
        expect(flash.now[:danger]).to eq "Update Failure"
      end

      it "update success no transaction" do
        patch :update, params: { id: category_3.id, category: { name: "test2" , category_type: "expense" } }, xhr: true
        expect(flash.now[:success]).to eq "Update success"
      end
      it "update success expense" do
        patch :update, params: { id: category_1.id, category: { name: "test1", category_type: "expense" } }, xhr: true
        expect(flash.now[:success]).to eq "Update success"
      end

      context "when find not found" do
        before do
          patch :update, params: { id: -12}, xhr: true
        end
        it "show flash danger" do
          expect(flash[:danger]).to eq "Category not found"
        end
        it "redirect to categories" do
          expect(response).to redirect_to categories_path
        end
      end
    end
  end

  describe "DELETE destroy" do
    it_behaves_like "not logged for methods" do
      before do
        patch :destroy, params: { id: category_1.id}, xhr: true
      end
    end

    context "when user logged" do
      before {sign_in user}
      it "delete success" do
        patch :destroy, params: { id: category_1.id}
        expect(flash[:success]).to eq "Delete success"
      end
      it "delete failed" do
        allow_any_instance_of(Category).to receive(:destroy).and_return false
        patch :destroy, params: { id: category_1.id}
        expect(flash[:danger]).to eq "Delete fail"
      end

      context "when load failed" do
        before do
          patch :destroy, params: { id: -12}
        end
        it "show flash danger" do
          expect(flash[:danger]).to eq "Category not found"
        end
        it "redirect to wallet" do
          expect(response).to redirect_to categories_path
        end
      end
    end
  end
end
