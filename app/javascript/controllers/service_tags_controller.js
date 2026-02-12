import { Controller } from "@hotwired/stimulus"

// Manages service tag selection with specialty-based suggestions and custom service creation.
//
// Usage:
//   <div data-controller="service-tags" data-service-tags-specialty-value="51">
//     <div data-service-tags-target="suggestions"><!-- suggestion chips --></div>
//     <div data-service-tags-target="selected"><!-- selected tags --></div>
//     <input data-service-tags-target="customInput">
//     <button data-action="service-tags#addCustom">Agregar</button>
//   </div>

export default class extends Controller {
  static targets = ["suggestions", "selected", "customInput", "hiddenFields"]
  static values = { specialty: Number }

  connect() {
    this.selectedServiceIds = new Set()
    this.selectedCustomNames = new Set()

    // Collect already-selected service IDs from hidden fields
    this.hiddenFieldsTarget.querySelectorAll("input[type=hidden]").forEach(input => {
      if (input.value) this.selectedServiceIds.add(parseInt(input.value))
    })

    if (this.specialtyValue) {
      this.loadSuggestions(this.specialtyValue)
    }

    // Listen for specialty changes from the subspecialty controller
    this._onSpecialtyChanged = (event) => {
      this.specialtyValue = parseInt(event.detail.specialtyId) || 0
    }
    window.addEventListener("specialty-changed", this._onSpecialtyChanged)
  }

  disconnect() {
    window.removeEventListener("specialty-changed", this._onSpecialtyChanged)
  }

  specialtyValueChanged() {
    if (this.specialtyValue) {
      this.loadSuggestions(this.specialtyValue)
    } else {
      this.suggestionsTarget.innerHTML = ""
    }
  }

  async loadSuggestions(specialtyId) {
    try {
      const response = await fetch(`/specialties/${specialtyId}/services.json`)
      const services = await response.json()
      this.renderSuggestions(services)
    } catch (error) {
      console.error("Error loading services:", error)
    }
  }

  renderSuggestions(services) {
    this.suggestionsTarget.innerHTML = ""
    services.forEach(service => {
      if (this.selectedServiceIds.has(service.id)) return

      const chip = document.createElement("button")
      chip.type = "button"
      chip.className = "inline-flex items-center px-3 py-1 text-sm rounded-full bg-gray-100 text-gray-700 hover:bg-sky-100 hover:text-sky-700 transition-colors mr-2 mb-2"
      chip.textContent = `+ ${service.name}`
      chip.dataset.serviceId = service.id
      chip.dataset.serviceName = service.name
      chip.dataset.action = "service-tags#selectSuggestion"
      this.suggestionsTarget.appendChild(chip)
    })
  }

  selectSuggestion(event) {
    event.preventDefault()
    const btn = event.currentTarget
    const serviceId = parseInt(btn.dataset.serviceId)
    const serviceName = btn.dataset.serviceName

    if (this.selectedServiceIds.has(serviceId)) return

    this.selectedServiceIds.add(serviceId)
    this.addSelectedTag(serviceId, serviceName)
    this.addHiddenField(serviceId)
    btn.remove()
  }

  addCustom(event) {
    event.preventDefault()
    const input = this.customInputTarget
    const name = input.value.trim()
    if (!name) return
    if (this.selectedCustomNames.has(name.toLowerCase())) return

    // Create the service on the server, then add it
    this.createAndAddService(name)
    input.value = ""
  }

  handleCustomKeydown(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.addCustom(event)
    }
  }

  async createAndAddService(name) {
    try {
      // Check if service already exists by searching
      const response = await fetch(`/services/find_or_create`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ name: name })
      })
      const service = await response.json()

      if (this.selectedServiceIds.has(service.id)) return

      this.selectedServiceIds.add(service.id)
      this.selectedCustomNames.add(name.toLowerCase())
      this.addSelectedTag(service.id, service.name)
      this.addHiddenField(service.id)

      // Remove from suggestions if present
      const suggestionBtn = this.suggestionsTarget.querySelector(`[data-service-id="${service.id}"]`)
      if (suggestionBtn) suggestionBtn.remove()
    } catch (error) {
      console.error("Error creating service:", error)
    }
  }

  addSelectedTag(serviceId, serviceName) {
    const tag = document.createElement("span")
    tag.className = "inline-flex items-center px-3 py-1 text-sm rounded-full bg-sky-500 text-white mr-2 mb-2"
    tag.dataset.serviceId = serviceId
    tag.innerHTML = `
      ${serviceName}
      <button type="button" class="ml-1.5 hover:text-sky-200" data-action="service-tags#removeTag" data-service-id="${serviceId}" data-service-name="${serviceName}">
        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      </button>
    `
    this.selectedTarget.appendChild(tag)
  }

  addHiddenField(serviceId) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = "doctor_profile[service_ids][]"
    input.value = serviceId
    input.dataset.serviceId = serviceId
    this.hiddenFieldsTarget.appendChild(input)
  }

  removeTag(event) {
    event.preventDefault()
    const btn = event.currentTarget
    const serviceId = parseInt(btn.dataset.serviceId)

    this.selectedServiceIds.delete(serviceId)

    // Remove the whole tag span (parent of the button)
    const tag = this.selectedTarget.querySelector(`:scope > [data-service-id="${serviceId}"]`)
    if (tag) tag.remove()

    // Remove hidden field
    const hidden = this.hiddenFieldsTarget.querySelector(`input[data-service-id="${serviceId}"]`)
    if (hidden) hidden.remove()

    // Reload suggestions to show the removed service again
    if (this.specialtyValue) {
      this.loadSuggestions(this.specialtyValue)
    }
  }

  // Called from the specialty select change event to update specialty value
  updateSpecialty(event) {
    this.specialtyValue = parseInt(event.currentTarget.value) || 0
  }
}
