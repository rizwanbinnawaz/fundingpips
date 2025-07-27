class IpActivity < ApplicationRecord
  enum activity_type: { trade: 0, login: 1, kyc: 2 }

  validates :activity_type, :ip_address, presence: true
  validate :resource_presence

  belongs_to :ip_address_record,
             primary_key: :address,
             foreign_key: :ip_address,
             inverse_of: :ip_activities,
             class_name: "IpAddress"
  belongs_to :trading_account,
             primary_key: :login,
             foreign_key: :trading_account_login,
             inverse_of: :ip_activities,
             optional: true
  belongs_to :user, optional: true
  belongs_to :owning_user, class_name: "User", optional: true

  default_scope { order(created_at: :desc) }

  scope :for_user, lambda { |user|
    where(user: user).or(where(trading_account_login: user.trading_accounts.select(:login)))
  }

  # Scopes for enums to allow .kyc, .login, .trade
  # These are auto-created by enum, so no need to define explicitly

  # Smart limiting to fetch latest kyc, login, and trade activities prioritized.
  def self.smart_limit_for_user(user, total_limit: 3000, kyc_limit: 10, login_limit: 1000)
    kyc_activities = for_user(user).kyc.limit(kyc_limit)
    login_activities = for_user(user).login.limit(login_limit)

    kyc_count = kyc_activities.size
    login_count = login_activities.size

    trade_limit = total_limit - kyc_count - login_count
    trade_limit = 0 if trade_limit < 0

    trade_activities = for_user(user).trade.limit(trade_limit)

    combined_ids = (kyc_activities.ids + login_activities.ids + trade_activities.ids).uniq

    where(id: combined_ids).order(created_at: :desc)
  end

  def resource
    trading_account || user
  end

  private

  def resource_presence
    errors.add(:base, "Either user or trading_account must be present") unless user.present? || trading_account.present?
  end
end
