import { Controller } from "@hotwired/stimulus"

// Cascading location filter: País → Departamento → Ciudad.
// Changing the country repopulates departments (and clears cities);
// changing the department repopulates cities. Each change auto-submits the
// filter form (the selects also carry change->form#submit).
//
//   <div data-controller="location-filter">
//     <select data-location-filter-target="country"    data-action="change->location-filter#loadDepartments">
//     <select data-location-filter-target="department" data-action="change->location-filter#loadCities">
//     <select data-location-filter-target="city">
export default class extends Controller {
  static targets = ["country", "department", "city"]
  // Blank-option labels are configurable so forms can say "Selecciona…" while
  // the search filter keeps "Todos…". Defaults preserve the filter behavior.
  static values = {
    departmentBlank: { type: String, default: "Todos los departamentos" },
    cityBlank: { type: String, default: "Todas las ciudades" }
  }

  async loadDepartments() {
    const countryId = this.hasCountryTarget ? this.countryTarget.value : null
    this.resetSelect(this.departmentTarget, this.departmentBlankValue)
    this.resetSelect(this.cityTarget, this.cityBlankValue)
    if (!countryId) return
    await this.populate(this.departmentTarget, `/countries/${countryId}/departments`)
  }

  async loadCities() {
    const departmentId = this.departmentTarget.value
    this.resetSelect(this.cityTarget, this.cityBlankValue)
    if (!departmentId) return
    await this.populate(this.cityTarget, `/departments/${departmentId}/cities`)
  }

  resetSelect(select, blankLabel) {
    if (select) select.innerHTML = `<option value="">${blankLabel}</option>`
  }

  async populate(select, url) {
    try {
      const items = await (await fetch(url)).json()
      items.forEach(({ id, name }) => {
        const option = document.createElement("option")
        option.value = id
        option.textContent = name
        select.appendChild(option)
      })
    } catch (error) {
      console.error("location-filter: failed to load", url, error)
    }
  }
}
