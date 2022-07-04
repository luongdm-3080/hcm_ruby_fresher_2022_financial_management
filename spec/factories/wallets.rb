FactoryBot.define do
  factory :wallet do
    id{Faker::Number.number(digits: 3)}
    name{Faker::Name.first_name}
    balance{Faker::Number.number(digits: 3)}
    created_at{Time.zone.now}
    updated_at{Time.zone.now}
  end
end
