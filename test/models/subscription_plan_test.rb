require "test_helper"

class SubscriptionPlanTest < ActiveSupport::TestCase
  def build_plan(attrs = {})
    SubscriptionPlan.new({
      name: "Doctor Elite", price: 3500, interval: "month",
      profile_type: "doctor", tier: "elite"
    }.merge(attrs))
  end

  # --- patient_limit validation ---

  test "patient_limit is optional (nil for plans without expediente)" do
    assert build_plan(patient_limit: nil).valid?
  end

  test "patient_limit must be a positive integer when present" do
    assert_not build_plan(patient_limit: 0).valid?
    assert_not build_plan(patient_limit: -5).valid?
    assert build_plan(patient_limit: 5_000).valid?
  end

  # --- capacity helpers ---

  test "patient_limit? reflects presence of a limit" do
    assert build_plan(patient_limit: 5_000).patient_limit?
    assert_not build_plan(patient_limit: nil).patient_limit?
  end

  test "patient_limit_label formats the ceiling for the UI" do
    assert_equal "Hasta 25,000 registros clínicos", build_plan(patient_limit: 25_000).patient_limit_label
    assert_nil build_plan(patient_limit: nil).patient_limit_label
  end

  # --- Stripe price stays in sync with the amount ---

  test "changing the price clears the stale stripe_price_id" do
    plan = build_plan(price: 2900, stripe_price_id: "price_old")
    plan.save!
    plan.update!(price: 3500)
    assert_nil plan.reload.stripe_price_id, "a price change must force a fresh Stripe Price"
  end

  test "saving without a price change keeps the stripe_price_id" do
    plan = build_plan(price: 3500, stripe_price_id: "price_keep")
    plan.save!
    plan.update!(name: "Doctor Elite (renamed)")
    assert_equal "price_keep", plan.reload.stripe_price_id
  end

  # --- 3 Elite tiers coexist under one (profile_type, tier) ---

  test "multiple elite doctor plans can coexist (index is not unique)" do
    build_plan(name: "Doctor Elite", price: 3500, patient_limit: 5_000).save!
    second = build_plan(name: "Doctor Elite 25K", price: 6900, patient_limit: 25_000)
    assert second.save, second.errors.full_messages.to_sentence
    assert_equal 2, SubscriptionPlan.where(profile_type: "doctor", tier: "elite").count
  end
end
