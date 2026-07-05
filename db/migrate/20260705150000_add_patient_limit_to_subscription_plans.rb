class AddPatientLimitToSubscriptionPlans < ActiveRecord::Migration[8.0]
  def change
    # Registros (expedientes clínicos) permitidos por plan. NULL = la función
    # no aplica (planes sin Expediente Clínico, p.ej. gratis/profesional).
    add_column :subscription_plans, :patient_limit, :integer

    # Los 3 niveles Elite comparten tier "elite" (para no romper el gating que
    # revisa tier == "elite") y se diferencian por patient_limit. Por eso el
    # índice (profile_type, tier) ya no puede ser único.
    remove_index :subscription_plans,
      column: %i[profile_type tier],
      name: "index_subscription_plans_on_profile_type_and_tier",
      unique: true
    add_index :subscription_plans, %i[profile_type tier],
      name: "index_subscription_plans_on_profile_type_and_tier"
  end
end
