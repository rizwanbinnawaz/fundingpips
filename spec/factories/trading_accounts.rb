# frozen_string_literal: true

FactoryBot.define do
  factory :trading_account do
    name { "#{user.first_name}'s Account #{Faker::Number.number(digits: 3)}" }
    login { Faker::Number.unique.number(digits: 10).to_s }
    phase { TradingAccount.phases.keys.sample }
    platform { TradingAccount.platforms.keys.sample }
    user

    trait :student do
      phase { "student" }
    end

    trait :practitioner do
      phase { "practitioner" }
    end

    trait :senior do
      phase { "senior" }
    end

    trait :master do
      phase { "master" }
    end

    trait :mt5 do
      platform { "mt5" }
    end

    trait :matchtrader do
      platform { "matchtrader" }
    end

    trait :tradelocker do
      platform { "tradelocker" }
    end
  end
end
