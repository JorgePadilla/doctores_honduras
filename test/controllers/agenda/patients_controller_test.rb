require "test_helper"

class Agenda::PatientsControllerTest < ActionDispatch::IntegrationTest
  def create_agenda_doctor
    user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    profile = DoctorProfile.create!(user: user, name: "Doc", department: departments(:one), city: cities(:one))
    plan = SubscriptionPlan.create!(name: "P-#{SecureRandom.hex(3)}", price: 100, interval: "month", profile_type: "doctor", tier: "elite")
    Subscription.create!(user: user, subscription_plan: plan, plan_name: plan.name, status: "active", current_period_end: 1.year.from_now)
    [ user, profile ]
  end

  test "search finds the doctor's own patient by name and by DNI (dashes ignored)" do
    user, profile = create_agenda_doctor
    profile.patients.create!(name: "Ana López", identity_document: "0801-1990-12345")
    sign_in_as(user)

    get search_agenda_patients_url(q: "Ana")
    assert_includes response.parsed_body.map { |p| p["name"] }, "Ana López"
    assert_equal "0801-1990-12345", response.parsed_body.first["identity_document"]

    # Buscar por DNI sin guiones también matchea (dígitos normalizados).
    get search_agenda_patients_url(q: "0801199012345")
    assert_includes response.parsed_body.map { |p| p["name"] }, "Ana López"
  end

  test "search never leaks another doctor's patients" do
    _user_a, profile_a = create_agenda_doctor
    _user_b, profile_b = create_agenda_doctor
    profile_b.patients.create!(name: "Paciente Ajeno", identity_document: "0501-1980-00000")

    sign_in_as(profile_a.user)
    get search_agenda_patients_url(q: "Ajeno")
    assert_empty response.parsed_body
    get search_agenda_patients_url(q: "0501198000000")
    assert_empty response.parsed_body
  end
end
