FactoryBot.define do
  factory :category do
    id{Faker::Number.number(digits: 3)}
    name{Faker::Name.first_name}
    category_type{Random.rand(0...2)}
  end
end
