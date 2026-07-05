require "test_helper"
require "minitest/mock"

class DoctorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @doctor = DoctorProfile.create!(
      user: users(:two),
      name: "Dra. Búsqueda Servicio",
      department: departments(:one),
      city: cities(:one)
    )
    @service = Service.create!(name: "Cesárea de prueba")
    DoctorService.create!(doctor_profile: @doctor, service: @service)
  end

  test "index renders" do
    get doctors_url
    assert_response :success
  end

  # Ticket A1: patients search by procedure/service, not by doctor name.
  test "free-text search matches a doctor's service name" do
    get doctors_url, params: { q: "cesárea de prueba" }
    assert_response :success
    assert_select "a[href=?]", doctor_path(@doctor)
  end

  test "free-text search excludes doctors when the term matches nothing" do
    get doctors_url, params: { q: "terminoinexistentexyz" }
    assert_response :success
    assert_select "a[href=?]", doctor_path(@doctor), count: 0
  end

  # Ticket A3: filter by city.
  test "city filter matches doctors in that city and excludes others" do
    get doctors_url, params: { city_id: cities(:one).id }
    assert_select "a[href=?]", doctor_path(@doctor)

    get doctors_url, params: { city_id: cities(:two).id }
    assert_select "a[href=?]", doctor_path(@doctor), count: 0
  end

  # Ticket A3: filter by hospital/clinic.
  test "hospital filter matches doctors linked to that establishment" do
    establishment = Establishment.create!(name: "Hospital Test A3", est_type: "Hospital", address: "Calle 1", phone: "2200-0000")
    DoctorEstablishment.create!(doctor_profile: @doctor, establishment: establishment)

    get doctors_url, params: { establishment_id: establishment.id }
    assert_select "a[href=?]", doctor_path(@doctor)
  end

  # Ticket A2: a lay term finds a doctor via the synonym dictionary.
  test "synonym expands a lay term to a clinical service and finds the doctor" do
    surgery = Service.create!(name: "Apendicectomía")
    DoctorService.create!(doctor_profile: @doctor, service: surgery)

    # Without a synonym, the lay term does not match the clinical service name.
    get doctors_url, params: { q: "apendicitis" }
    assert_select "a[href=?]", doctor_path(@doctor), count: 0

    # With the synonym, the lay term resolves to the clinical keyword.
    SearchSynonym.create!(term: "apendicitis", keywords: "Apendicectomía")
    get doctors_url, params: { q: "apendicitis" }
    assert_select "a[href=?]", doctor_path(@doctor)
  end

  # Doctor-level phone: "Llamar" (tel:) link on the profile.
  test "show renders a Llamar tel link normalized to digits when a phone is set" do
    @doctor.update!(phone: "+504 2200-0000")
    get doctor_path(@doctor)
    assert_response :success
    assert_select "a[href=?]", "tel:50422000000"
  end

  test "show omits the tel link when no phone is set" do
    @doctor.update!(phone: nil)
    get doctor_path(@doctor)
    assert_response :success
    assert_select "a[href^=?]", "tel:", count: 0
  end

  # País select se oculta cuando hay un solo país (ruido), y aparece con varios.
  test "index hides the country select when there is only one country" do
    get doctors_url
    assert_select "select[name=?]", "country_id", count: 0
  end

  test "index shows the country select when there are multiple countries" do
    Country.create!(name: "Guatemala", iso_code: "GT")
    get doctors_url
    assert_select "select[name=?]", "country_id"
  end

  # Location filter: department (parent of city).
  test "department filter matches doctors in that department and excludes others" do
    get doctors_url, params: { department_id: departments(:one).id }
    assert_select "a[href=?]", doctor_path(@doctor)

    get doctors_url, params: { department_id: departments(:two).id }
    assert_select "a[href=?]", doctor_path(@doctor), count: 0
  end

  # Geolocation preselect: on a fresh visit, scope results to the visitor's region.
  test "geolocation preselects the visitor's department and filters" do
    IpGeolocator.stub(:available?, true) do
      # Visitor detected in Cortés — @doctor is in Francisco Morazán, so excluded.
      IpGeolocator.stub(:from_request, { country: "Honduras", region: departments(:two).name }) do
        get doctors_url
        assert_response :success
        assert_select "a[href=?]", doctor_path(@doctor), count: 0
      end
    end
  end

  test "geolocation preselect is skipped when all=1" do
    IpGeolocator.stub(:available?, true) do
      IpGeolocator.stub(:from_request, { country: "Honduras", region: departments(:two).name }) do
        get doctors_url, params: { all: 1 }
        assert_select "a[href=?]", doctor_path(@doctor)
      end
    end
  end

  # Ticket B1: WhatsApp contact button links to wa.me using digits only.
  test "show renders a WhatsApp link normalized to digits when a number is set" do
    @doctor.update!(whatsapp: "+504 9999-8888")
    get doctor_path(@doctor)
    assert_response :success
    assert_select "a[href=?]", "https://wa.me/50499998888"
  end

  test "show omits the WhatsApp link when no number is set" do
    @doctor.update!(whatsapp: nil)
    get doctor_path(@doctor)
    assert_response :success
    assert_select "a[href^=?]", "https://wa.me/", count: 0
  end

  # Ticket B5: the generic "Medicina General" specialty is not headlined when a
  # more specific subspecialty exists.
  test "show hides the Medicina General headline when a subspecialty exists" do
    general = Specialty.find_or_create_by!(name: DoctorProfile::GENERAL_SPECIALTY_NAME)
    sub = Subspecialty.create!(name: "Cardiología Intervencionista", specialty: general)
    @doctor.update!(specialty: general, subspecialty: sub)

    get doctor_path(@doctor)
    assert_response :success
    assert_select "p", text: /Cardiología Intervencionista/
    assert_select "p", text: /Medicina General/, count: 0
  end
end
