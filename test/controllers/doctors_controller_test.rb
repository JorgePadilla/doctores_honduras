require "test_helper"

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
end
