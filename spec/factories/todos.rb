FactoryGirl.define do

  factory :todo do
    sequence(:title) { |n| "This is todo #{n.to_s.humanize}" }
    complete false
  end


end
