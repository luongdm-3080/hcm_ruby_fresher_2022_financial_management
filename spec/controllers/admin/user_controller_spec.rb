require "rails_helper"
require "cancan/matchers"
RSpec.describe Admin::UsersController, type: :controller do
  let!(:user) {FactoryBot.create :user, name: "User 1"}
  let!(:user_1) {FactoryBot.create :user, name: "User 3", deleted_at: Time.zone.now}
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

  describe "#GET restores" do
    context "when admin login" do
      before do
        sign_in user_admin
        get :restores
      end
      it "returns a 200 response" do
        expect(response).to have_http_status "200"
      end
      it {expect(assigns(:pagy).count).to eq 1}

      context "search sort users" do
        it "gets user by name or email" do
          expect(User.only_deleted.ransack(user_cont: user_1.name).result.pluck(:id)).to eq [user_1.id]
        end

        it "gets user by created_at" do
          expect(User.only_deleted.ransack(created_at_eq: user_1.created_at).result.pluck(:id)).to eq [user_1.id]
        end

        context "when search params" do
          before do
            get :restores, params: {
              search: {user_cont: "User 3", created_at_eq: Time.zone.now} }
          end
          it "should find just categories" do
            expect(assigns(:users)).to eq [user_1]
          end
        end
      end
    end
  end

  describe "DELETE destroy" do
    context "when user logged" do
      before do
        sign_in user_admin
      end
      context "when delete success" do
        before do
          patch :destroy, params: { id: user.id}
        end
        it {expect(flash[:success]).to eq "Destroy success"}
        
        it {expect(User.only_deleted.pluck(:id)).to eq [user.id, user_1.id]}

        it {expect(User.pluck(:id)).to eq [user_admin.id]}

        it "redirect to transaction" do
          expect(response).to redirect_to restores_admin_users_path
        end
      end
      context "When delete failed" do
        before do
          allow_any_instance_of(User).to receive(:destroy).and_return false
          patch :destroy, params: { id: user_1.id}
        end
        it "delete failed" do
          expect(flash[:danger]).to eq "Destroy failed"
        end

        it {expect(User.pluck(:id)).to eq [user.id, user_admin.id]}

        it {expect(User.only_deleted.pluck(:id)).to eq [user_1.id]}

        it "render index" do
          expect(response).to render_template :index
        end
      end

      context "when find not found" do
        before do
          patch :destroy, params: { id: -12}
        end
        it "show flash danger" do
          expect(flash[:danger]).to eq "User not found"
        end
        it "redirect to categories" do
          expect(response).to redirect_to admin_root_path
        end
      end
    end
  end

  describe "UPDATE restore" do
    context "when user logged" do
      before do
        sign_in user_admin
      end
      context "when restore success" do
        before do
          patch :restore, params: { id: user_1.id}
        end
        it {expect(flash[:success]).to eq "Restore success"}

        it {expect(User.only_deleted.pluck(:id)).to eq []}

        it {expect(User.pluck(:id)).to eq [user.id, user_1.id, user_admin.id]}

        it "redirect to transaction" do
          expect(response).to redirect_to admin_root_path
        end
      end
      context "When restorefailed" do
        before do
          allow_any_instance_of(User).to receive(:restore).and_return false
          patch :restore, params: { id: user_1.id}
        end
        it "restore failed" do
          expect(flash[:danger]).to eq "Restore failed"
        end

        it {expect(User.only_deleted.pluck(:id)).to eq [user_1.id]}

        it {expect(User.pluck(:id)).to eq [user.id, user_admin.id]}
      
        it "render :restores" do
          expect(response).to render_template :restores
        end
      end

      context "when find not found" do
        before do
          patch :restore, params: { id: -12}
        end
        it "show flash danger" do
          expect(flash[:danger]).to eq "User not found"
        end
        it "redirect to categories" do
          expect(response).to redirect_to admin_root_path
        end
      end
    end
  end

  describe "DELETE really_destroy" do
    context "when user logged" do
      before do
        sign_in user_admin
      end
      context "when really destroy success" do
        before do
          delete :really_destroy, params: { id: user.id}
        end
        it {expect(flash[:success]).to eq "Really destroy success"}
        
        it {expect(User.with_deleted.pluck(:id)).to eq [user_admin.id, user_1.id]}

        it "redirect to admin root path" do
          expect(response).to redirect_to admin_root_path
        end
      end
      context "When really destroy failed" do
        before do
          allow_any_instance_of(User).to receive(:really_destroy!).and_return false
          delete :really_destroy, params: { id: user_1.id}
        end
        it "really destroy failed" do
          expect(flash[:danger]).to eq "Really destroy failed"
        end

        it {expect(User.with_deleted.pluck(:id)).to eq [user.id, user_admin.id, user_1.id]}

        it "redirect to admin root path" do
          expect(response).to redirect_to admin_root_path
        end
      end

      context "when find not found" do
        before do
          delete :really_destroy, params: { id: -12}
        end
        it "show flash danger" do
          expect(flash[:danger]).to eq "User not found"
        end
        it "redirect to categories" do
          expect(response).to redirect_to admin_root_path
        end
      end
    end
  end
end
