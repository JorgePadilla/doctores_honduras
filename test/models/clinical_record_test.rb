require "test_helper"

class ClinicalRecordTest < ActiveSupport::TestCase
  setup do
    user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    @profile = DoctorProfile.create!(user: user, name: "Doc", department: departments(:one), city: cities(:one))
    @patient = Patient.create!(doctor_profile: @profile, name: "Ana")
  end

  test "valid with a patient and no clinical fields; blank_record? is true" do
    record = ClinicalRecord.new(patient: @patient)
    assert record.valid?, record.errors.full_messages.to_sentence
    assert record.blank_record?
  end

  test "blood_type accepts a value from the allowed list" do
    record = ClinicalRecord.new(patient: @patient, blood_type: "O+")
    assert record.valid?, record.errors.full_messages.to_sentence
  end

  test "blood_type rejects a value outside the allowed list" do
    record = ClinicalRecord.new(patient: @patient, blood_type: "Z")
    assert_not record.valid?
    assert record.errors[:blood_type].any?
  end

  test "blood_type allows blank" do
    assert ClinicalRecord.new(patient: @patient, blood_type: "").valid?
    assert ClinicalRecord.new(patient: @patient, blood_type: nil).valid?
  end

  test "allergies? is true when allergies are present" do
    record = ClinicalRecord.new(patient: @patient, allergies: "Penicilina")
    assert record.allergies?

    assert_not ClinicalRecord.new(patient: @patient).allergies?
  end

  test "doctor_profile delegates to the patient's doctor_profile" do
    record = ClinicalRecord.new(patient: @patient)
    assert_equal @profile, record.doctor_profile
  end

  test "blank_record? is false once any field is set" do
    record = ClinicalRecord.new(patient: @patient)
    assert record.blank_record?

    record.allergies = "Polen"
    assert_not record.blank_record?
  end
end
