require "rails_helper"
include SessionsHelper

RSpec.describe WalletsController, type: :controller do
  let!(:user) {FactoryBot.create :user}
  let!(:wallet_1){FactoryBot.create :wallet, user_id: user.id}
  let!(:wallet_2){FactoryBot.create :wallet, user_id: user.id}
  let!(:wallet_3){FactoryBot.create :wallet, user_id: user.id}

  describe "GET #index" do
    it_behaves_like "not logged for get method", "index"

    context "when user logged" do
      before do
        sign_in user
        get :index
        @ids = [wallet_3.id, wallet_2.id, wallet_1.id]
      end

      context "when has wallets" do
        it "load wallet users" do
          params = {
            current_user_id: user.id,
          }
          get :index, params: params, xhr: true
          expect(assigns(:wallets).pluck(:id)).to eq(@ids)
        end

        it "gets wallet by params scope" do
          params = {
            current_user_id: user.id,
          }
          get :index, params: params, xhr: true
          expect(assigns(:wallets).newest.pluck(:id)).to eq(@ids)
        end

        it "render index" do
          expect(response).to render_template :index
        end
      end
    end
  end

  describe "GET #new" do
    it_behaves_like "not logged for other method" do
      before do
        get :new
      end
    end
    context "when user logged" do
      before do
        sign_in user
        get :new
      end
      it "should be success" do
        expect(assigns(:wallet)).to_not eq nil
        expect(assigns(:wallet)).to be_a_new(Wallet)
      end
    end
  end

  describe "POST create" do
    it_behaves_like "not logged for other method" do
      before do
        post :create, params: {
          wallet: { name: "test", balance: 5678 } }
      end
    end
    context "when user logged" do
      before do
        sign_in user
        post :create, params: {
          wallet: { name: "test", balance: 5678 } }
      end

      it "build wallet success" do
        expect(assigns(:wallet)).to eq(user.wallets.last)
      end

      context "wallet save success" do
        it "show flash success" do
          expect(flash[:success]).to eq I18n.t("success_wallet")
        end

        it "redirect to wallets" do
          expect(response).to redirect_to wallet_transactions_path(user.wallets.last.id)
        end
      end

      context "wallet save failed" do
        before do
          sign_in user
          post :create, params: { wallet: { balance: 5678 } }
        end
        it "show flash danger" do
          expect(flash.now[:danger]).to eq I18n.t("danger_wallet")
        end
        it "redirect to home page" do
          expect(response).to render_template :new
        end
      end
    end
  end

  describe "GET show/:id" do
    it_behaves_like "not logged for other method" do
      before do
        get :show, params: {id: wallet_1.id}
      end
    end
    let(:category){FactoryBot.create :category, category_type: 1, user_id: user.id}
    let!(:transaction_1){FactoryBot.create :transaction, category_id: category.id, wallet_id: wallet_1.id}
    let!(:transaction_2){FactoryBot.create :transaction, category_id: category.id, wallet_id: wallet_1.id, transaction_date: (Time.zone.now + 12)}
    context "when user logged" do
      before { sign_in user }
      context "when found" do
        it "show transactions latest" do
          get :show, params: {id: wallet_1.id}

          expect(assigns(:transactions).pluck(:id)).to eq([transaction_2.id,transaction_1.id])
        end
      end

      context "when not found" do
        it "show empty" do
          get :show, params: {id: wallet_2.id}
          expect(assigns(:transactions).pluck(:id)).to eq([])
        end
      end
    end
  end

  describe "PATCH update/:id" do
    it_behaves_like "not logged for methods" do
      before do
        patch :update, params: { id: wallet_1.id, wallet: { name: "xyz", balance: 20 } }, xhr: true
      end
    end
    context "when user logged" do
      before { sign_in user }
      it "update success" do
        patch :update, params: { id: wallet_1.id, wallet: { name: "xyz", balance: 20 } }, xhr: true
        expect(flash.now[:success]).to eq I18n.t("update_success_wallet")
      end
      it "update failed" do
        patch :update, params: { id: wallet_1.id, wallet: { name: "xyz", balance: nil } }, xhr: true
        expect(flash.now[:danger]).to eq I18n.t("update_failed_wallet")
      end
    end
  end

  describe "DELETE destroy" do
    it_behaves_like "not logged for methods" do
      before do
        patch :destroy, params: { id: wallet_1.id}, xhr: true
      end
    end

    context "when user logged" do
      before {sign_in user}
      it "delete success" do
        patch :destroy, params: { id: wallet_1.id}, xhr: true
        expect(flash.now[:success]).to eq I18n.t("delete_success_wallet")
      end
      it "delete failed" do
        allow_any_instance_of(Wallet).to receive(:destroy).and_return false
        patch :destroy, params: { id: wallet_1.id}, xhr: true
        expect(flash.now[:danger]).to eq "Wallet delete failed"
      end

      context "when load failed" do
        before do
          patch :destroy, params: { id: -12}, xhr: true
        end
        it "show flash danger" do
          expect(flash[:danger]).to eq I18n.t("not_found")
        end
        it "redirect to wallet" do
          expect(response).to redirect_to wallets_path
        end
      end
    end
  end
end
