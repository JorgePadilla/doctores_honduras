class Admin::AnalyticsController < Admin::BaseController
  ALLOWED_DAYS = [ 7, 30, 90, 365 ].freeze

  def index
    @days = params[:days].to_i
    @days = 30 unless ALLOWED_DAYS.include?(@days)
    @analytics = AdminAnalytics.new(range: @days.days.ago..Time.current)
    @funnel = @analytics.funnel
  end
end
