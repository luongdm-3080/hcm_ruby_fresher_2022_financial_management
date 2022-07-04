FactoryBot.define do
  factory :user do
    name{Faker::Name.first_name}
    email{Faker::Internet.email.downcase}
    role {0}
    password{"password"}
    password_confirmation{"password"}
    activated{true}
    activated_at{Time.zone.now}
  end
end
