require "rails_helper"
include SessionsHelper
require "cancan/matchers"
RSpec.describe TransactionsController, type: :controller do
  let(:user) {FactoryBot.create :user}
  let(:user_2) {FactoryBot.create :user}
  let(:wallet_1){FactoryBot.create :wallet, user_id: user.id}
  let(:wallet_2){FactoryBot.create :wallet, user_id: user_2.id}
  let(:category) {FactoryBot.create :category, user_id: user.id, category_type: 0}
  let(:category_2) {FactoryBot.create :category, user_id: user.id, category_type: 1}
  let!(:transaction_1){FactoryBot.create :transaction, category_id: category.id, wallet_id: wallet_1.id, transaction_date: (Time.zone.now + 55) }
  let!(:transaction_2){FactoryBot.create :transaction, category_id: category_2.id, wallet_id: wallet_1.id, transaction_date: (Time.zone.now.end_of_day + 60)}
  let!(:transaction_3){FactoryBot.create :transaction, category_id: category.id, wallet_id: wallet_2.id}
  describe "GET #index" do
    it_behaves_like "not logged for get method", "index"

    context "when user logged" do
      subject(:ability){Ability.new(user)}
      before do
        sign_in user
      end

      context "when new transaction" do
        before {get :index}
        it { expect(assigns(:transaction)).to_not eq nil }
        it "should be success" do
          expect(assigns(:transaction)).to be_a_new(Transaction)
        end
      end

      context "when has transactions success" do
        before do
          params = {
            wallet_id: wallet_1.id,
          }
          get :index, params: params, xhr: true
        end
        it "returns a 200 response" do
          expect(response).to have_http_status "200"
        end

        it "should be success" do
          expect(assigns(:wallet_id).to_i).to eq wallet_1.id
          expect(assigns(:time_now)).to eq Time.zone.now.strftime(Settings.time)
        end

        it {expect(ability).to be_able_to(:manage, Transaction, wallet_id: user.wallets.ids)}
        it "render index" do
          expect(response).to render_template :index
        end
      end

      context "when transactions success params time" do
        before do
          params = {
            wallet_id: wallet_1.id,
            start_day: Time.zone.now.beginning_of_day,
            end_day: Time.zone.now.end_of_day
          }
          get :index, params: params, xhr: true
        end
        it "returns a 200 response" do
          expect(response).to have_http_status "200"
        end
        it "render index" do
          expect(response).to render_template :index
        end
      end

      context "when user not correct wallet" do
        before do
          params = {
            wallet_id: wallet_2.id,
          }
          get :index, params: params, xhr: true
        end
        it "show flash danger" do
          expect(flash[:danger]).to eq "You don't have permission to do this action"
        end
        it "redirect to wallet" do
          expect(response).to redirect_to new_wallet_path
        end
      end
    end
  end


  describe "POST create" do
    it_behaves_like "not logged for other method" do
      before do
        post :create, params: {
          transaction: { total: 123, category_id: category.id, wallet_id: wallet_1.id, transaction_date: Time.zone.now} }
      end
    end

    context "when user logged" do
      before do
        sign_in user
        post :create, params: {
          transaction: { total: 123, category_id: category.id, wallet_id: wallet_1.id, transaction_date: Time.zone.now} }
      end

      it "build transaction success" do
        expect(assigns(:transaction)).to eq(wallet_1.transactions.last)
      end

      context "transaction save success" do
        it "show flash success" do
          expect(flash[:success]).to eq "Create transactions success"
        end

        it "redirect to transaction" do
          expect(response).to redirect_to wallet_transactions_path(wallet_1.id)
        end
      end

      context "transaction create failed" do
        before do
          sign_in user
        end

        context "transaction save failed" do
          before do
            allow_any_instance_of(Transaction).to receive(:save!).and_raise(StandardError)
            post :create, params: { transaction: { total: 123, category_id: category.id, wallet_id: wallet_1.id, transaction_date: Time.zone.now} }, xhr: true
          end
          it "show flash danger" do
            expect(flash[:danger]).to eq "Create failed"
          end
          it "not show template" do
            response.should_not render_template :index
          end
        end

        context "wallet update failed" do
          before do
            allow_any_instance_of(Wallet).to receive(:update!).and_raise(StandardError)
            post :create, params: { transaction: { total: 123, category_id: category.id, wallet_id: wallet_1.id, transaction_date: Time.zone.now} }, xhr: true
          end
          it "show flash danger" do
            expect(flash[:danger]).to eq "Create failed"
          end
          it "not show template" do
            response.should_not render_template :index
          end
        end
      end
    end
  end

  describe "GET show/:id" do
    it_behaves_like "not logged for other method" do
      before do
        get :show, params: {wallet_id: wallet_1.id, id: transaction_1.id}
      end
    end
    context "when user logged" do
      before { sign_in user }
      context "when found" do
        it "show transactions id" do
          get :show, params: {wallet_id: wallet_1.id, id: transaction_1.id}

          expect(assigns(:transaction)).to eq(transaction_1)
        end
      end

      context "when not found" do
        before do
          get :show, params: {wallet_id: wallet_1.id, id: transaction_3.id}
        end
        it "show flash danger" do
          expect(flash[:danger]).to eq "Wallet not found"
        end
        it "redirect to wallet" do
          expect(response).to redirect_to new_wallet_path
        end
      end
    end
  end

   describe "PATCH update" do
    it_behaves_like "not logged for methods" do
      before do
        patch :update, params: {
           id: transaction_1.id, transaction: { total: 123, category_id: category.id, wallet_id: wallet_1.id, transaction_date: Time.zone.now } }, xhr: true
      end
    end

    context "when user logged" do
      before { sign_in user }
      context "when update success " do
        it "success income" do
          patch :update, params: {
            id: transaction_1.id, transaction: { total: 123, category_id: category.id, wallet_id: wallet_1.id, transaction_date: Time.zone.now } }, xhr: true
          expect(flash.now[:success]).to eq "Update success"
        end
        it "success expense" do
          patch :update, params: {
            id: transaction_2.id, transaction: { total: 123, category_id: category_2.id, wallet_id: wallet_1.id, transaction_date: Time.zone.now } }, xhr: true
          expect(flash.now[:success]).to eq "Update success"
        end
      end

      context "when update failed" do
        it "update failed transaction" do
          allow_any_instance_of(Transaction).to receive(:update!).and_raise(StandardError)
          patch :update, params: {
            id: transaction_1.id, transaction: { total: 123, category_id: category.id, wallet_id: wallet_1.id, transaction_date: Time.zone.now } }, xhr: true
          expect(flash.now[:danger]).to eq "Update failed"
        end

        it "update failed transaction" do
          allow_any_instance_of(Wallet).to receive(:update!).and_raise(StandardError)
          patch :update, params: {
            id: transaction_1.id, transaction: { total: 123, category_id: category.id, wallet_id: wallet_1.id, transaction_date: Time.zone.now } }, xhr: true
          expect(flash.now[:danger]).to eq "Update failed"
        end
      end

      context "when find not found" do
        before do
          patch :update, params: { id: -12}, xhr: true
        end
        it "show flash danger" do
          expect(flash[:danger]).to eq "Wallet not found"
        end
        it "redirect to wallet transaction" do
          expect(response).to redirect_to wallet_transactions_path(user.wallets.first.id)
        end
      end
    end
  end

  describe "DELETE destroy" do
    it_behaves_like "not logged for methods" do
      before do
        patch :destroy, params: { id: transaction_1.id}, xhr: true
      end
    end

    context "when user logged" do
      before do
        sign_in user
      end
      it "delete success" do
        patch :destroy, params: { id: transaction_1.id}
        expect(flash[:success]).to eq "Delete success"
      end
      context "When delete transaction failed" do
        before do
          allow_any_instance_of(Transaction).to receive(:destroy!).and_raise(StandardError)
          patch :destroy, params: { id: transaction_1.id}
        end
        it "delete failed" do
          expect(flash[:danger]).to eq "Delete fail"
        end
        it "redirect to transaction" do
          expect(response).to redirect_to wallet_transaction_path(wallet_id: transaction_1.wallet_id, id: transaction_1.id)
        end
      end

      context "When update failed wallet" do
        before do
          allow_any_instance_of(Wallet).to receive(:update!).and_raise(StandardError)
          patch :destroy, params: { id: transaction_1.id}
        end
        it "delete failed" do
          expect(flash[:danger]).to eq "Delete fail"
        end
        it "redirect to transaction" do
          expect(response).to redirect_to wallet_transaction_path(wallet_id: transaction_1.wallet_id, id: transaction_1.id)
        end
      end
    end
  end

  describe "chart_analysis" do
    it_behaves_like "not logged for other method" do
      before do
        get :chart_analysis, params: {wallet_id: wallet_1.id}
      end
    end

    context "when user logged" do
      before do
        sign_in user
        get :chart_analysis, params: {wallet_id: wallet_1.id}
      end
      context "when found" do
        it "wallet id found" do
          expect(assigns(:wallet_id).to_i).to eq(wallet_1.id)
        end
        it { expect(assigns(:date_of_transactions)).to eq([transaction_1]) }
      end
    end
  end
end
