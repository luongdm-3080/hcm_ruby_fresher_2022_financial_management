User.create!(name: "Minh Luong",
    email: "duongminhluong89@gmail.com",
    password: "123456",
    password_confirmation: "123456",
    role: 0,
    confirmed_at: Time.zone.now)

categories = [["Eat rice", 1], ["My salary", 0], ["Car fare", 1]]
categories.each do |key, value|
  Category.create!(name: key, category_type: value, type_name: 1)
end
