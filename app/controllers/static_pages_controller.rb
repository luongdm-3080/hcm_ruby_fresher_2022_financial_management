class StaticPagesController < ApplicationController
  before_action :logged_in_user
  def home; end

  def help; end

  def about; end
end
