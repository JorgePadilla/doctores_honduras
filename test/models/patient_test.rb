require "test_helper"

class PatientTest < ActiveSupport::TestCase
  setup do
    @profile = create_doctor_profile
  end

  def create_doctor_profile(name: "Doc")
    user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    DoctorProfile.create!(user: user, name: name, department: departments(:one), city: cities(:one))
  end

  # --- resolve_for: walk-in (no user_id) ---

  test "resolve_for creates a walk-in patient by name and returns it" do
    patient = Patient.resolve_for(doctor_profile_id: @profile.id, name: "Ana")

    assert patient.persisted?
    assert_nil patient.user_id
    assert_equal "Ana", patient.name
    assert_equal @profile.id, patient.doctor_profile_id
  end

  test "resolve_for reuses the same walk-in patient for a normalized name" do
    first = Patient.resolve_for(doctor_profile_id: @profile.id, name: "Ana")
    count_after_first = Patient.count

    second = Patient.resolve_for(doctor_profile_id: @profile.id, name: "  ana  ")

    assert_equal first.id, second.id, "the normalized name should map to the same patient"
    assert_equal count_after_first, Patient.count, "no duplicate patient should be created"
  end

  # --- resolve_for: keyed by user_id ---

  test "resolve_for keys by user_id and updates the name across calls" do
    patient_user = User.create!(email: "pac-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "paciente")

    first = Patient.resolve_for(doctor_profile_id: @profile.id, name: "Ana", user_id: patient_user.id)
    count_after_first = Patient.count

    second = Patient.resolve_for(doctor_profile_id: @profile.id, name: "Ana María", user_id: patient_user.id)

    assert_equal first.id, second.id, "same user_id should resolve to the same patient"
    assert_equal count_after_first, Patient.count, "no duplicate patient should be created for the same user"
    assert_equal "Ana María", second.name, "name should be updated on subsequent resolve"
    assert_equal patient_user.id, second.user_id
  end

  # --- resolve_for: phone/email assignment ---

  test "resolve_for updates phone and email when provided and keeps them when blank" do
    patient = Patient.resolve_for(
      doctor_profile_id: @profile.id, name: "Bob",
      phone: "9999-0000", email: "bob@example.com"
    )
    assert_equal "9999-0000", patient.phone
    assert_equal "bob@example.com", patient.email

    # Blank values must not overwrite existing contact info.
    Patient.resolve_for(doctor_profile_id: @profile.id, name: "Bob", phone: "", email: nil)
    patient.reload
    assert_equal "9999-0000", patient.phone
    assert_equal "bob@example.com", patient.email

    # A present value updates.
    Patient.resolve_for(doctor_profile_id: @profile.id, name: "Bob", phone: "8888-1111")
    patient.reload
    assert_equal "8888-1111", patient.phone
    assert_equal "bob@example.com", patient.email
  end

  # --- resolve_for: guards ---

  test "resolve_for returns nil when name is blank" do
    assert_nil Patient.resolve_for(doctor_profile_id: @profile.id, name: "")
    assert_nil Patient.resolve_for(doctor_profile_id: @profile.id, name: nil)
  end

  test "resolve_for scopes patients per doctor" do
    other = create_doctor_profile(name: "Other Doc")

    a = Patient.resolve_for(doctor_profile_id: @profile.id, name: "Ana")
    b = Patient.resolve_for(doctor_profile_id: other.id, name: "Ana")

    assert_not_equal a.id, b.id, "same name for different doctors should create separate patients"
    assert_equal @profile.id, a.doctor_profile_id
    assert_equal other.id, b.doctor_profile_id
  end

  # --- validations & helpers ---

  test "name is required" do
    patient = Patient.new(doctor_profile: @profile, name: "")
    assert_not patient.valid?
    assert patient.errors[:name].any?
  end

  test "display_contact formats email and phone with a middle dot" do
    both = Patient.create!(doctor_profile: @profile, name: "Both", email: "a@b.com", phone: "555")
    assert_equal "a@b.com · 555", both.display_contact

    only_email = Patient.create!(doctor_profile: @profile, name: "OnlyEmail", email: "a@b.com")
    assert_equal "a@b.com", only_email.display_contact

    only_phone = Patient.create!(doctor_profile: @profile, name: "OnlyPhone", phone: "555")
    assert_equal "555", only_phone.display_contact

    neither = Patient.create!(doctor_profile: @profile, name: "Neither")
    assert_equal "", neither.display_contact
  end

  test "allergies and allergies? reflect the linked clinical record" do
    patient = Patient.create!(doctor_profile: @profile, name: "Allergic")
    assert_nil patient.allergies
    assert_not patient.allergies?

    patient.create_clinical_record!(allergies: "Penicilina")
    patient.reload
    assert_equal "Penicilina", patient.allergies
    assert patient.allergies?
  end
end
