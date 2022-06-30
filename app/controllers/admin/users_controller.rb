class Admin::UsersController < Admin::AdminController
  def index
    @users = User.order_by_name
    @pagy, @users = pagy(@users, items: Settings.pagy_page.default_page)
  end
end
