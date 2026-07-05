require "test_helper"

class Agenda::AttachmentsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def create_doctor(tier: "elite")
    user = User.create!(email: "doc-#{SecureRandom.hex(4)}@example.com", password: "password", profile_type: "doctor")
    profile = DoctorProfile.create!(user: user, name: "Doc", department: departments(:one), city: cities(:one))
    branch = profile.doctor_branches.create!(name: "Sede", address: "Calle 1")
    branch.ensure_default_schedules!
    profile.create_agenda_setting!(appointment_duration: 30, buffer_minutes: 0)
    plan = SubscriptionPlan.create!(name: "P-#{SecureRandom.hex(3)}", price: 100, interval: "month", profile_type: "doctor", tier: tier)
    Subscription.create!(user: user, subscription_plan: plan, plan_name: plan.name, status: "active", current_period_end: 1.year.from_now)
    appt = profile.appointments.create!(doctor_branch: branch, patient_name: "Ana",
      appointment_date: Date.new(2026, 7, 6), start_time: "10:00", end_time: "10:30", booking_source: "manual")
    [ user, appt ]
  end

  test "elite doctor uploads a lab attachment" do
    user, appt = create_doctor
    sign_in_as(user)
    assert_difference -> { appt.reload.lab_attachments.count }, 1 do
      post agenda_appointment_attachments_url(appt), params: { files: [ fixture_file_upload("lab_result.pdf", "application/pdf") ] }
    end
    assert_redirected_to agenda_appointment_path(appt)
  end

  test "disallowed file type is rejected" do
    user, appt = create_doctor
    sign_in_as(user)
    assert_no_difference -> { appt.reload.lab_attachments.count } do
      post agenda_appointment_attachments_url(appt), params: { files: [ fixture_file_upload("notes.txt", "text/plain") ] }
    end
    assert_redirected_to agenda_appointment_path(appt)
  end

  test "attachment can be deleted" do
    user, appt = create_doctor
    sign_in_as(user)
    appt.lab_attachments.attach(fixture_file_upload("lab_result.pdf", "application/pdf"))
    att = appt.lab_attachments.first
    perform_enqueued_jobs do
      delete agenda_appointment_attachment_url(appt, att.id)
    end
    assert_equal 0, appt.reload.lab_attachments.count
    assert_redirected_to agenda_appointment_path(appt)
  end

  test "non-elite doctor cannot upload" do
    user, appt = create_doctor(tier: "profesional")
    sign_in_as(user)
    assert_no_difference -> { appt.reload.lab_attachments.count } do
      post agenda_appointment_attachments_url(appt), params: { files: [ fixture_file_upload("lab_result.pdf", "application/pdf") ] }
    end
    assert_redirected_to agenda_patients_path
  end
end
