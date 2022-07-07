require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let!(:user) {FactoryBot.create :user, name: "User 1"}
  let!(:user_admin) {FactoryBot.create :user, role: 1, name: "User 2"}
  describe "#GET index" do
    context "when not admin login" do
      before do
        sign_in user
        get :index
      end
      it "returns a 302 response" do
        expect(response).to have_http_status "302"
      end
      it { is_expected.to redirect_to root_path }
      it { expect(flash[:danger]).to eq "You don't have permission to do this action" }
    end

    context "when admin login" do
      before do
        sign_in user_admin
        get :index
      end
      it "returns a 200 response" do
        expect(response).to have_http_status "200"
      end
      it {expect(assigns(:users).pluck(:id)).to eq([user.id, user_admin.id])}
      it {expect(assigns(:pagy).count).to eq 2}
    end
  end
end
