import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "nameField", "phoneField", "emailField", "patientUserIdField"]

  connect() {
    this.timeout = null
    this.selectedIndex = -1
    document.addEventListener("click", this.closeDropdown.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.closeDropdown.bind(this))
  }

  search() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.hideDropdown()
      return
    }

    this.timeout = setTimeout(() => {
      fetch(`/agenda/patients/search?q=${encodeURIComponent(query)}`)
        .then(response => response.json())
        .then(patients => this.showResults(patients))
        .catch(() => this.hideDropdown())
    }, 300)
  }

  showResults(patients) {
    if (patients.length === 0) {
      this.hideDropdown()
      return
    }

    const dropdown = this.dropdownTarget
    dropdown.innerHTML = ""

    patients.forEach((patient, index) => {
      const item = document.createElement("button")
      item.type = "button"
      item.className = "w-full text-left px-4 py-2 text-sm hover:bg-sky-50 dark:hover:bg-slate-700 transition-colors"
      item.innerHTML = `
        <p class="font-medium text-gray-900 dark:text-white">${this.escapeHtml(patient.name)}</p>
        <p class="text-xs text-gray-500 dark:text-slate-400">${this.escapeHtml(patient.email || "")} ${patient.phone ? "· " + this.escapeHtml(patient.phone) : ""}</p>
      `
      item.addEventListener("click", () => this.selectPatient(patient))
      dropdown.appendChild(item)
    })

    dropdown.classList.remove("hidden")
  }

  selectPatient(patient) {
    if (this.hasNameFieldTarget) this.nameFieldTarget.value = patient.name || ""
    if (this.hasPhoneFieldTarget) this.phoneFieldTarget.value = patient.phone || ""
    if (this.hasEmailFieldTarget) this.emailFieldTarget.value = patient.email || ""
    if (this.hasPatientUserIdFieldTarget) this.patientUserIdFieldTarget.value = patient.patient_user_id || ""
    this.hideDropdown()
  }

  hideDropdown() {
    this.dropdownTarget.classList.add("hidden")
  }

  closeDropdown(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
