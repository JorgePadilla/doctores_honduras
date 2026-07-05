require "test_helper"

class Paciente::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "pac-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "paciente")
    sign_in_as(@user)
  end

  # Regresión: un paciente sin PatientProfile ya no revienta con 500.
  test "show redirects to edit when the patient has no profile yet" do
    assert_nil @user.patient_profile
    get paciente_profile_url
    assert_redirected_to edit_paciente_profile_path
  end

  test "edit renders (building a blank profile) when none exists" do
    get edit_paciente_profile_url
    assert_response :success
  end

  test "update creates the profile when none exists, then show works" do
    assert_difference -> { PatientProfile.count }, 1 do
      patch paciente_profile_url, params: { patient_profile: { name: "Ana Paciente" } }
    end
    assert_redirected_to paciente_profile_path

    get paciente_profile_url
    assert_response :success
    assert_match "Ana Paciente", @response.body
  end

  test "show renders for a patient that already has a profile" do
    PatientProfile.create!(user: @user, name: "Existente")
    get paciente_profile_url
    assert_response :success
    assert_match "Existente", @response.body
  end
end
