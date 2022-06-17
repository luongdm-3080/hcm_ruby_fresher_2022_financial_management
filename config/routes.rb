Rails.application.routes.draw do
  scope "(:locale)", locale: /en|ja|vi/ do
  end
end
