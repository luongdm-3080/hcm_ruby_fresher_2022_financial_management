require "rails_helper"
RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before(:all) do
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  describe "google_oauth2" do
    context "when login success" do
      before {
        get :google_oauth2
      }
      it "new user form" do
        expect(assigns(:user)).to eq User.first
      end

      it "show flash success" do
        expect(flash[:notice]).to eq "Successfully authenticated from Google account."
      end

      it "redirect to root" do
        expect(response).to redirect_to root_path
      end

    end

    context "when login failed" do
      before {
        allow_any_instance_of(User).to receive(:save).and_return(false)
        get :google_oauth2
      }
      it "session not nil" do
        expect(session['devise.google_data']).to_not eq nil
      end
      it { expect(OmniAuth.config.mock_auth[:google_oauth2]).to eq(session['devise.google_data']) }

      it "redirect to registration" do
        expect(response).to redirect_to new_user_registration_url
      end
    end
  end
end
