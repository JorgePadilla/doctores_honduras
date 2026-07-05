require "test_helper"

class Agenda::PrescriptionsControllerTest < ActionDispatch::IntegrationTest
  MONDAY = Date.new(2026, 7, 6)

  def create_doctor(tier: "elite")
    user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    profile = DoctorProfile.create!(user: user, name: "Doc", medical_license: "CMH-123", department: departments(:one), city: cities(:one))
    plan = SubscriptionPlan.create!(name: "P-#{SecureRandom.hex(3)}", price: 100, interval: "month", profile_type: "doctor", tier: tier)
    Subscription.create!(user: user, subscription_plan: plan, plan_name: plan.name, status: "active", current_period_end: 1.year.from_now)
    [ user, profile ]
  end

  def create_appointment(profile)
    branch = profile.doctor_branches.create!(name: "Sede Central", address: "Calle 1")
    branch.ensure_default_schedules!
    profile.appointments.create!(doctor_branch: branch, patient_name: "Ana",
      appointment_date: MONDAY, start_time: "10:00", end_time: "10:30", booking_source: "manual")
  end

  test "edit renders for elite" do
    user, profile = create_doctor(tier: "elite")
    @appointment = create_appointment(profile)
    sign_in_as(user)

    get edit_agenda_appointment_prescription_path(@appointment)

    assert_response :success
    assert_select "input[name=?]", "prescription[prescription_items_attributes][0][medication]"
  end

  test "update persists a prescription with items" do
    user, profile = create_doctor(tier: "elite")
    @appointment = create_appointment(profile)
    sign_in_as(user)

    patch agenda_appointment_prescription_path(@appointment), params: { prescription: {
      instructions: "Tomar con agua",
      prescription_items_attributes: {
        "0" => { medication: "Amoxicilina", dosage: "500mg", frequency: "c/8h", duration: "7 días" }
      }
    } }

    assert_redirected_to agenda_appointment_path(@appointment)
    prescription = @appointment.reload.prescription
    assert_not_nil prescription
    assert_equal 1, prescription.prescription_items.count
    assert_equal "Amoxicilina", prescription.prescription_items.first.medication
  end

  test "show renders the printable receta" do
    user, profile = create_doctor(tier: "elite")
    @appointment = create_appointment(profile)
    prescription = @appointment.create_prescription!(instructions: "Tomar con agua")
    prescription.prescription_items.create!(medication: "Amoxicilina", dosage: "500mg", frequency: "c/8h", duration: "7 días")
    sign_in_as(user)

    get agenda_appointment_prescription_path(@appointment)

    assert_response :success
    assert_includes @response.body, "Amoxicilina"
  end

  test "non-elite doctor is blocked" do
    user, profile = create_doctor(tier: "profesional")
    @appointment = create_appointment(profile)
    sign_in_as(user)

    get edit_agenda_appointment_prescription_path(@appointment)

    assert_redirected_to agenda_patients_path
  end
end
