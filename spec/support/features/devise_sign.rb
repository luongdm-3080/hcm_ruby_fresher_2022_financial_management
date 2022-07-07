module Features
  def sign_in
    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Login"
    visit root_path
  end

  def sign_up user
    visit new_user_registration_path
    fill_in "Name", :with => user.name
    fill_in "Email", :with => user.email
    fill_in "Password", :with => user.password
    fill_in "Password confirmation", :with => user.password_confirmation
    click_button "Sign up"
  end 

  def reset_password user
    visit new_user_password_path
    within("#new_user") do
      fill_in "Email", with: user.email
    end
    click_button('Send me reset password instructions')
  end
  def comfirmation user
    visit new_user_confirmation_path
    fill_in "Email", :with => user.email
    click_button "Resend confirmation instructions"
  end
end
