require "rails_helper"
include Features
feature "Signing up" do

  scenario "Create a new user correct" do

    visit new_user_registration_path

    fill_in "Name", :with => "My Name"
    fill_in "Email", :with => "duongminhluong889@gmail.com"
    fill_in "Password", :with => "123456789"
    fill_in "Password confirmation", :with => "123456789"
    click_button "Sign up"
    expect(page).to have_text("You need to sign in or sign up before continuing.")
  end

  context "when create a new user not correct" do
    scenario "not all" do
      user = User.create()
      sign_up user
      expect(page).to have_text('The form contains 3 errors')
    end

    scenario "not name" do
      user = User.create(email: "my@email.com", password: "123456789", password_confirmation: "123456789"  )
      sign_up user
      expect(page).to have_text("Name can't be blank")
    end

    scenario "not email" do
      user = User.create(name: "user", password: "123456789", password_confirmation: "123456789"  )
      sign_up user
      expect(page).to have_text("Email can't be blank")
    end

    scenario "not password" do
      user = User.create(name: "user", email: "my@email.com" )
      sign_up user
      expect(page).to have_text("Password can't be blank")
    end

    scenario "not password match" do
      user = User.create(name: "user",email: "my@email.com", password: "123456", password_confirmation: "123456789"  )
      sign_up user
      expect(page).to have_text("Password confirmation doesn't match")
    end
  end
end
