require "rails_helper"
include Features
feature "Reset password" do
  given!(:user) {FactoryBot.create :user, email: 'user@example.com'}

  context "when forgot password" do
    scenario "email correct" do
      user = User.create(email: "user@example.com")
      reset_password user
      expect(page).to have_current_path("/en/users/sign_in")
      expect(page).to have_text('You will receive an email with instructions on how to reset your password in a few minutes.')
    end
    scenario "email not correct" do
      user = User.create(email: "user1@example.com")
      reset_password user
      expect(page).to have_text('Email not found')
    end

    scenario "email blank" do
      user = User.create()
      reset_password user
      expect(page).to have_text("Email can't be blank")
    end
  end
end
