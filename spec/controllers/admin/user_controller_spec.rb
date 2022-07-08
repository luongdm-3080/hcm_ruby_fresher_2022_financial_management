require "rails_helper"
require "cancan/matchers"
RSpec.describe Admin::UsersController, type: :controller do
  let!(:user) {FactoryBot.create :user, name: "User 1"}
  let!(:user_admin) {FactoryBot.create :user, role: 1, name: "User 2"}

  describe "#GET index" do
    context "when not admin login" do
      subject(:ability){Ability.new(user)}
      before do
        sign_in user
        get :index
      end
      it "returns a 302 response" do
        expect(response).to have_http_status "302"
      end
      it { is_expected.to redirect_to root_path }
      it { expect(flash[:danger]).to eq "You are not authorized to this page" }
      it { expect(ability).not_to be_able_to(:manage, :all)}
    end

    context "when admin login" do
      subject(:ability){Ability.new(user_admin)}
      before do
        sign_in user_admin
        get :index
      end
      it "returns a 200 response" do
        expect(response).to have_http_status "200"
      end
      it {expect(assigns(:users).pluck(:id)).to eq([user.id, user_admin.id])}
      it {expect(assigns(:pagy).count).to eq 2}
      it {expect(ability).to be_able_to(:manage, :all)}

      context "search sort users" do
        it "gets user by name or email" do
          expect(User.ransack(user_cont: user.name).result.pluck(:id)).to eq [user.id]
        end

        it "gets user by created_at" do
          expect(User.ransack(created_at_eq: user.created_at).result.pluck(:id)).to eq [user.id, user_admin.id]
        end

        context "when search params" do
          before do
            get :index, params: {
              search: {user_cont: "User 1", created_at_eq: Time.zone.now} }
          end
          it "should find just categories" do
            expect(assigns(:users)).to eq [user]
          end
        end
      end
    end
  end
end
