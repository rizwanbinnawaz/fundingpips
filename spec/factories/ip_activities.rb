# frozen_string_literal: true

FactoryBot.define do
  factory :ip_activity do
    ip_address_record { association(:ip_address) }
    activity_type { :trade }
    created_at { rand(6.months.ago..Time.current) }

    trait :login do
      user
      activity_type { :login }
    end

    trait :kyc do
      activity_type { :kyc }
      user
    end

    trait :trade do
      trading_account
      owning_user_id { trading_account.user_id }
      activity_type { :trade }
    end
  end
end
