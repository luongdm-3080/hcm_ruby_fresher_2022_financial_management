User.create!(name: "Minh Luong",
  email: "duongminhluong89@gmail.com",
  password: "123456",
  password_confirmation: "123456",
  admin: true,
  activated: true,
  activated_at: Time.zone.now)
10.times do |n|
  name = Faker::Name.name
  email = Faker::Internet.email
  password = "123456"
  User.create!(name: name, email: email, password: password, password_confirmation: password,activated: true,
  activated_at: Time.zone.now)
end
