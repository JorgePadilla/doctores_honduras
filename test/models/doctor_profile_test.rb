require "test_helper"

class DoctorProfileTest < ActiveSupport::TestCase
  setup do
    @doctor = DoctorProfile.new(name: "Dr. Test", department: departments(:one), city: cities(:one), user: users(:two))
  end

  test "phone_digits strips to digits and returns nil when blank" do
    @doctor.phone = "+504 2200-0000"
    assert_equal "50422000000", @doctor.phone_digits
    @doctor.phone = ""
    assert_nil @doctor.phone_digits
  end

  test "tel_url builds a tel: link from the digits, nil when blank" do
    @doctor.phone = "2200-1234"
    assert_equal "tel:22001234", @doctor.tel_url
    @doctor.phone = nil
    assert_nil @doctor.tel_url
  end
end
