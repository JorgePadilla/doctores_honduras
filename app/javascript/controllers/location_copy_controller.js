import { Controller } from "@hotwired/stimulus"

// "Usar la de mi primera ubicación": copies the first branch's department/city
// into the profile's primary-location selects (same form, Ubicaciones tab).
// The primary city select lists ALL cities, so setting the value directly works.
export default class extends Controller {
  static targets = ["department", "city"]

  copyFromBranch(event) {
    event.preventDefault()
    const form = this.element.closest("form")
    if (!form) return

    const entry = form.querySelector("[data-nested-fields-entry]:not([style*='display: none'])")
    if (!entry) return

    const branchDept = entry.querySelector("select[name*='[department_id]']")
    const branchCity = entry.querySelector("select[name*='[city_id]']")

    if (branchDept?.value) this.departmentTarget.value = branchDept.value
    if (branchCity?.value) this.cityTarget.value = branchCity.value
  }
}
