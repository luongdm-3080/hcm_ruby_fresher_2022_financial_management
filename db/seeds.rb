User.create!(name: "Minh Luong",
    email: "duongminhluong89@gmail.com",
    password: "123456",
    password_confirmation: "123456",
    role: 1,
    confirmed_at: Time.zone.now)
10.times do |n|
  name = Faker::Name.name
  email = Faker::Internet.email
  password = "123456"
  User.create!(name: name, email: email, password: password, password_confirmation: password, confirmed_at: Time.zone.now)
end

categories = [["Eat rice", 1], ["My salary", 0], ["Car fare", 1]]
categories.each do |key, value|
  Category.create!(name: key, category_type: value, type_name: 1)
end
