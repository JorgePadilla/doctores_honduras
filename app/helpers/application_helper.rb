module ApplicationHelper
  def paid_plan?(plan)
    plan.present? && !plan.free?
  end
end
