class FilterEngine
  # Initialize with:
  # - base_scope: ActiveRecord::Relation (e.g. IpActivity.for_user(user))
  # - filter_params: Hash of filtering parameters
  # - filterable_type: Symbol/String (e.g. :ip_activity, :user, :trading_account) - optional for type-specific logic
  def initialize(base_scope, filter_params = {}, filterable_type: nil)
    @scope = base_scope
    @params = filter_params
    @filterable_type = filterable_type&.to_sym
  end

  def apply
    apply_date_range(:created_at)
    apply_enum_filter(:activity_type) if @filterable_type == :ip_activity
    apply_enum_filter(:phase, join: :trading_account) if @filterable_type == :ip_activity
    apply_enum_filter(:platform, join: :trading_account) if @filterable_type == :ip_activity
    apply_text_filter(:trading_account_login)
    self
  end

  def result
    @scope
  end

  private

  def apply_date_range(field)
    from = @params["#{field}_from"]
    to = @params["#{field}_to"]
    @scope = @scope.where("#{field} >= ?", Time.zone.parse(from)) if from.present?
    @scope = @scope.where("#{field} <= ?", Time.zone.parse(to)) if to.present?
  end

  def apply_enum_filter(field, join: nil)
    values = @params[field.to_s]
    return if values.blank?

    values = values.is_a?(String) ? values.split(",") : Array(values)
    if join
      @scope = @scope.joins(join).where(join.to_s.pluralize => { field => values })
    else
      @scope = @scope.where(field => values)
    end
  end

  def apply_text_filter(field)
    values = @params[field.to_s]
    return if values.blank?

    values = values.is_a?(String) ? values.split(",") : Array(values)
    @scope = @scope.where(field => values)
  end
end