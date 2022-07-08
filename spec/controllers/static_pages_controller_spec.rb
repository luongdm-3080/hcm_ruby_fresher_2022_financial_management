require "rails_helper"
include SessionsHelper

RSpec.describe StaticPagesController, type: :controller do
  let!(:user) {FactoryBot.create :user}
  describe "GET #home" do
    it_behaves_like "not logged for get method", "home"

    context "when user logged" do
      before do
        sign_in user
      end
      actions = [:home , :help, :about]
      actions.each do |action|
        it_behaves_like "logged static page", action
      end
    end
  end
end
