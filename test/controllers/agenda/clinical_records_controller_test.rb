require "test_helper"

class Agenda::ClinicalRecordsControllerTest < ActionDispatch::IntegrationTest
  def create_doctor(tier: "elite", patient_limit: nil)
    user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    profile = DoctorProfile.create!(user: user, name: "Doc", department: departments(:one), city: cities(:one))
    plan = SubscriptionPlan.create!(name: "P-#{SecureRandom.hex(3)}", price: 100, interval: "month", profile_type: "doctor", tier: tier, patient_limit: patient_limit)
    Subscription.create!(user: user, subscription_plan: plan, plan_name: plan.name, status: "active", current_period_end: 1.year.from_now)
    [user, profile]
  end

  test "new renders for elite" do
    user, profile = create_doctor(tier: "elite")
    patient = profile.patients.create!(name: "Ana")
    sign_in_as(user)

    get new_agenda_patient_clinical_record_path(patient)

    assert_response :success
    assert_select "textarea[name=?]", "clinical_record[allergies]"
  end

  test "create persists a ficha" do
    user, profile = create_doctor(tier: "elite")
    patient = profile.patients.create!(name: "Ana")
    sign_in_as(user)

    post agenda_patient_clinical_record_path(patient), params: { clinical_record: { allergies: "Penicilina" } }

    assert_redirected_to agenda_patient_path(patient)
    assert_equal "Penicilina", patient.reload.clinical_record.allergies
  end

  test "update edits the ficha" do
    user, profile = create_doctor(tier: "elite")
    patient = profile.patients.create!(name: "Ana")
    patient.create_clinical_record!(allergies: "Penicilina")
    sign_in_as(user)

    patch agenda_patient_clinical_record_path(patient), params: { clinical_record: { allergies: "Ibuprofeno" } }

    assert_redirected_to agenda_patient_path(patient)
    assert_equal "Ibuprofeno", patient.reload.clinical_record.allergies
  end

  test "non-elite doctor is blocked" do
    user, profile = create_doctor(tier: "profesional")
    patient = profile.patients.create!(name: "Ana")
    sign_in_as(user)

    get new_agenda_patient_clinical_record_path(patient)

    assert_redirected_to agenda_patients_path
  end

  test "patient_limit is enforced" do
    user, profile = create_doctor(tier: "elite", patient_limit: 1)
    patient1 = profile.patients.create!(name: "Ana")
    patient1.create_clinical_record!(allergies: "Penicilina")
    patient2 = profile.patients.create!(name: "Beto")
    sign_in_as(user)

    assert_no_difference "ClinicalRecord.count" do
      post agenda_patient_clinical_record_path(patient2), params: { clinical_record: { allergies: "Aspirina" } }
    end

    assert_redirected_to agenda_patient_path(patient2)
  end
end
