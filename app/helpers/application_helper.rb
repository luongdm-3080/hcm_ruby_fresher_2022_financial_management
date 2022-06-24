module ApplicationHelper
  include Pagy::Frontend

  def full_title page_title
    base_title = t "base_title"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def load_categories
    current_user.categories
  end
end
