FactoryBot.define do


  factory :business do

    offer { Faker::Commerce.product_name }
    sequence(:description) {|n| n%5==0 ? nil : Faker::Lorem.paragraphs.join}

    trait :with_fields do
      description { Faker::Lorem.paragraphs.join }
    end

    trait :with_roles do
      transient do
        originator_id 1
        member_id nil
        creator_id 3
      end

      after(:create) do |business|
        Role.create(:role_name=>Role::ORGANIZER,
                    :mname=>"Business",
                    :mid=>business.id,
                    :user_id=>creator_id)
        Role.create(:role_name=>Role::MEMBER,
                    :mname=>"Business",
                    :mid=>business.id,
                    :user_id=>creator_id)  if creator_id
      end
    end
  end

end
