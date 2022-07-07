class CategoriesController < ApplicationController
  before_action :authenticate_user!
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

  def update
    if @category.update category_params
      respond_to do |format|
        format.js{flash.now[:success] = t ".edit_success_message"}
      end
    else
      respond_to do |format|
        format.js{flash.now[:danger] = t ".edit_failure_message"}
      end
    end
  end

  def destroy
    if @category.destroy
      flash[:success] = t ".success_message"
    else
      flash[:danger] = t ".failure_message"
    end
    redirect_back_or categories_path
  end

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
