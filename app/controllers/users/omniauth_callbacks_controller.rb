class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :load_data, only: :google_oauth2

  def google_oauth2
    if @user.persisted?
      flash[:notice] = t "devise.omniauth_callbacks.success", kind: "Google"
      sign_in_and_redirect @user, event: :authentication
    else
      session_data = request.env["omniauth.auth"].except(:extra)
      session["devise.google_data"] = session_data
      errors = @user.errors.full_messages.join("\n")
      redirect_to new_user_registration_url, alert: errors
    end
  end

  def load_data
    @user = User.from_omniauth(request.env["omniauth.auth"])
  end
end
