require "rails_helper"
include Features
feature "Signing in" do
  given!(:user) {FactoryBot.create :user, email: 'user@example.com'}
  
  background do
    @user = User.create(email: "user@example.com", password: "password")
  end
  context "when loggin correct" do
    scenario "not remember token" do
      visit user_session_path
      within("#new_user") do
        sign_in
      end
      expect(page).to have_text('Personal Financial Management Add Wallet')
      click_link('Logout')
      expect(page).to have_text('You need to sign in or sign up before continuing.')
    end
    scenario "remember token" do
      visit user_session_path
      within("#new_user") do
        check("Remember me")
        sign_in
      end
      user.reload
      expect(user.remember_created_at).to be_truthy
    end
  end

  context "when loggin not correct" do
    given(:other_user) { User.create(email: 'user@example.com', password: "1234567") }
    scenario "Signing in" do
      visit user_session_path
      within("#new_user") do
        fill_in "Email", with: other_user.email
        fill_in "Password", with: other_user.password
        click_button "Login"
      end
      expect(page).to have_text('Invalid Email or password')
    end
  end
end
