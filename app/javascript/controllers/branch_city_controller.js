import { Controller } from "@hotwired/stimulus"

// Loads cities dynamically when department changes within a branch fieldset.
//
// Usage:
//   <div data-controller="branch-city">
//     <select data-branch-city-target="department" data-action="change->branch-city#loadCities">
//     <select data-branch-city-target="city">
//   </div>

export default class extends Controller {
  static targets = ["department", "city"]

  async loadCities() {
    const departmentId = this.departmentTarget.value
    const citySelect = this.cityTarget

    // Clear current options
    citySelect.innerHTML = '<option value="">Selecciona una ciudad</option>'

    if (!departmentId) return

    try {
      const response = await fetch(`/departments/${departmentId}/cities`)
      const cities = await response.json()

      cities.forEach(city => {
        const option = document.createElement("option")
        option.value = city.id
        option.textContent = city.name
        citySelect.appendChild(option)
      })
    } catch (error) {
      console.error("Error loading cities:", error)
    }
  }
}
