class Admin::UsersController < Admin::AdminController
  def index
    @users = User.all
    @pagy, @users = pagy(@users, items: Settings.pagy_page.default_page)
  end
end
