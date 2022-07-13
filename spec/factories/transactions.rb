FactoryBot.define do
  factory :transaction do
    id{Faker::Number.unique.number(digits: 3)}
    transaction_date{Time.zone.now}
    description{Faker::Name.first_name}
  end
end
