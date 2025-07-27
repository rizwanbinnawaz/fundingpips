module Api
  module Users
    class IpActivitiesController < Api::BaseController
      DEFAULT_ORDER_FIELD = :created_at
      DEFAULT_ORDER_DIRECTION = :desc

      before_action :set_user

      def index
        # Get base scope with smart limiting
        ip_activities = IpActivity.smart_limit_for_user(@user)

        # Apply filters via reusable FilterEngine
        filtered_activities = FilterEngine.new(ip_activities, filter_params, filterable_type: :ip_activity).apply.result

        # Apply ordering and render JSON
        render json: filtered_activities.order(order)
      end

      def filter_metadata
        render json: {
          ip_activities_count: IpActivity.for_user(@user).count,
          trading_account_logins: IpActivity.for_user(@user).reorder(nil).distinct.pluck(:trading_account_login).compact,
          activity_types: IpActivity.activity_types.keys,
          phases: TradingAccount.phases.keys,
          platforms: TradingAccount.platforms.keys
        }
      rescue => e
        Rails.logger.error("Error in filter_metadata: #{e.message}\n#{e.backtrace.join("\n")}")
        render json: { error: "Failed to load metadata: #{e.message}" }, status: 500
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end

      def filter_params
        params.permit(
          :created_at_from,
          :created_at_to,
          :activity_type,
          :phase,
          :platform,
          :trading_account_login
        )
      end

      def order
        direction = params[:direction]&.to_sym == :asc ? :asc : :desc
        { DEFAULT_ORDER_FIELD => direction }
      end
    end
  end
end
