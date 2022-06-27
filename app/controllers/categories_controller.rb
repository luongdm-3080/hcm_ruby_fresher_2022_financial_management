class CategoriesController < ApplicationController
  before_action :logged_in_user
  before_action :load_category, only: %i(update destroy)
  Pagy::DEFAULT[:items] = Settings.pagy_page.default_page

  def index
    @pagy, @categories = pagy current_user.categories.order_by_name
    store_location
    @category = Category.new
  end

  def create
    @category = current_user.categories.build category_params
    if @category.save
      flash[:success] = t ".success"
      redirect_back_or categories_path
    else
      respond_to :js
    end
  end

  def update; end

  def destroy; end

  private

  def category_params
    params.require(:category).permit(Category::CATEGORY_CREATE_ATTRS)
  end

  def load_category
    @category = Category.find_by id: params[:id]
    return if @category

    flash[:danger] = t ".not_found"
    redirect_to categories_path
  end
end
