require "rails_helper"
include Features
feature "Comfirmations" do
  given!(:user) {FactoryBot.create :user, email: 'user@example.com', confirmed_at: nil }
  given!(:user_2) {FactoryBot.create :user, email: 'user1@example.com' }
  scenario "send correct" do
    comfirmation user
    expect(page).to have_text("You will receive an email with instructions for how to confirm your email address in a few minutes.")
  end

  context "when not correct" do
    scenario "email blank" do
      user = User.create()
      comfirmation user
      expect(page).to have_text("Email can't be blank")
    end

    scenario "email not found" do
      user = User.create(email: 'user2@example.com')
      comfirmation user
      expect(page).to have_text("Email not found")
    end

    scenario "email was already confirmed" do
      comfirmation user_2
      expect(page).to have_text("Email was already confirmed, please try signing in")
    end
  end
end
