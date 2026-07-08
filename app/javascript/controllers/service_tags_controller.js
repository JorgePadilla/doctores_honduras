import { Controller } from "@hotwired/stimulus"

// Compact service picker: selected chips + ONE autocomplete input (filters the
// specialty's suggested services; offers "create" when there's no match) + a
// capped row of suggestion chips.
//
// Submits ids via hidden inputs named doctor_profile[service_ids][].
export default class extends Controller {
  static targets = ["selected", "hiddenFields", "input", "dropdown",
                    "suggestions", "suggestionsWrap", "emptyMessage"]
  static values = { specialty: Number, cap: { type: Number, default: 8 } }

  initialize() {
    this.selectedServiceIds = new Set()
    this.allServices = []
    this.showAll = false
  }

  connect() {
    this.hiddenFieldsTarget.querySelectorAll("input[type=hidden]").forEach(input => {
      if (input.value) this.selectedServiceIds.add(parseInt(input.value))
    })

    if (this.specialtyValue) this.loadSuggestions(this.specialtyValue)

    this._onSpecialtyChanged = (event) => {
      this.specialtyValue = parseInt(event.detail.specialtyId) || 0
    }
    window.addEventListener("specialty-changed", this._onSpecialtyChanged)

    this._onOutsideClick = (event) => {
      if (!this.element.contains(event.target)) this.closeDropdown()
    }
    document.addEventListener("click", this._onOutsideClick)
  }

  disconnect() {
    window.removeEventListener("specialty-changed", this._onSpecialtyChanged)
    document.removeEventListener("click", this._onOutsideClick)
  }

  specialtyValueChanged() {
    if (!this.selectedServiceIds) return // fires before initialize state on first set
    if (this.specialtyValue) {
      this.loadSuggestions(this.specialtyValue)
    } else {
      this.allServices = []
      this.renderSuggestions()
    }
  }

  async loadSuggestions(specialtyId) {
    try {
      const response = await fetch(`/specialties/${specialtyId}/services.json`)
      this.allServices = await response.json()
      this.renderSuggestions()
    } catch (error) {
      console.error("Error loading services:", error)
    }
  }

  available() {
    return this.allServices.filter(s => !this.selectedServiceIds.has(s.id))
  }

  // --- Suggestion chips (capped) ---

  renderSuggestions() {
    if (!this.hasSuggestionsTarget) return
    const avail = this.available()
    this.suggestionsWrapTarget.classList.toggle("hidden", avail.length === 0)
    this.suggestionsTarget.innerHTML = ""

    const visible = this.showAll ? avail : avail.slice(0, this.capValue)
    visible.forEach(service => this.suggestionsTarget.appendChild(this.buildSuggestionChip(service)))

    if (avail.length > this.capValue) {
      const toggle = document.createElement("button")
      toggle.type = "button"
      toggle.className = "inline-flex items-center rounded-full border border-dashed border-line dark:border-slate-600 px-3 py-1 text-sm text-muted dark:text-slate-400 hover:text-primary-hover hover:border-primary transition-colors"
      toggle.textContent = this.showAll ? "Mostrar menos" : `+${avail.length - this.capValue} más`
      toggle.dataset.action = "service-tags#toggleAll"
      this.suggestionsTarget.appendChild(toggle)
    }
  }

  buildSuggestionChip(service) {
    const chip = document.createElement("button")
    chip.type = "button"
    chip.className = "inline-flex items-center rounded-full border border-line dark:border-slate-600 px-3 py-1 text-sm text-slate-600 dark:text-slate-300 hover:border-primary hover:text-primary-hover hover:bg-primary-soft dark:hover:bg-sky-900/20 transition-colors"
    chip.textContent = `+ ${service.name}`
    chip.dataset.serviceId = service.id
    chip.dataset.serviceName = service.name
    chip.dataset.action = "service-tags#selectSuggestion"
    return chip
  }

  toggleAll(event) {
    event.preventDefault()
    this.showAll = !this.showAll
    this.renderSuggestions()
  }

  selectSuggestion(event) {
    event.preventDefault()
    const { serviceId, serviceName } = event.currentTarget.dataset
    this.select(parseInt(serviceId), serviceName)
  }

  // --- Combobox (filter + create) ---

  filter() {
    const query = this.inputTarget.value.trim()
    if (!query) { this.closeDropdown(); return }

    const q = query.toLowerCase()
    const matches = this.available().filter(s => s.name.toLowerCase().includes(q)).slice(0, 8)
    const exactExists = this.allServices.some(s => s.name.toLowerCase() === q)

    this.dropdownTarget.innerHTML = ""
    matches.forEach(service => {
      this.dropdownTarget.appendChild(this.buildOption(service.name, {
        serviceId: service.id, serviceName: service.name, action: "service-tags#pick"
      }))
    })
    if (!exactExists) {
      const create = this.buildOption(`Crear «${query}»`, {
        serviceName: query, action: "service-tags#createFromOption"
      })
      create.classList.add("text-primary-hover", "dark:text-sky-400", "font-medium")
      this.dropdownTarget.appendChild(create)
    }

    this.dropdownTarget.classList.toggle("hidden", this.dropdownTarget.children.length === 0)
  }

  buildOption(label, dataset) {
    const btn = document.createElement("button")
    btn.type = "button"
    btn.className = "w-full text-left px-3 py-2 text-sm rounded-lg text-ink dark:text-slate-200 hover:bg-primary-soft dark:hover:bg-slate-700 transition-colors"
    btn.textContent = label
    Object.entries(dataset).forEach(([k, v]) => { btn.dataset[k] = v })
    return btn
  }

  keydown(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      const first = this.dropdownTarget.querySelector("button")
      if (first) first.click()
    } else if (event.key === "Escape") {
      this.closeDropdown()
    }
  }

  pick(event) {
    event.preventDefault()
    const { serviceId, serviceName } = event.currentTarget.dataset
    this.select(parseInt(serviceId), serviceName)
  }

  createFromOption(event) {
    event.preventDefault()
    this.createAndAddService(event.currentTarget.dataset.serviceName)
  }

  async createAndAddService(name) {
    try {
      const response = await fetch(`/services/find_or_create`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ name: name })
      })
      const service = await response.json()
      this.select(service.id, service.name)
    } catch (error) {
      console.error("Error creating service:", error)
    }
  }

  // --- Selection state ---

  select(serviceId, serviceName) {
    if (!serviceId || this.selectedServiceIds.has(serviceId)) return

    this.selectedServiceIds.add(serviceId)
    this.addSelectedTag(serviceId, serviceName)
    this.addHiddenField(serviceId)

    this.inputTarget.value = ""
    this.closeDropdown()
    this.renderSuggestions()
    if (this.hasEmptyMessageTarget) this.emptyMessageTarget.classList.add("hidden")
  }

  addSelectedTag(serviceId, serviceName) {
    const tag = document.createElement("span")
    tag.className = "inline-flex items-center gap-1.5 rounded-full bg-primary-soft dark:bg-sky-900/30 px-3 py-1 text-sm font-medium text-primary-hover dark:text-sky-400"
    tag.dataset.serviceId = serviceId
    tag.appendChild(document.createTextNode(serviceName))

    const btn = document.createElement("button")
    btn.type = "button"
    btn.className = "hover:text-primary-deep dark:hover:text-sky-200"
    btn.setAttribute("aria-label", `Quitar ${serviceName}`)
    btn.dataset.action = "service-tags#removeTag"
    btn.dataset.serviceId = serviceId
    btn.innerHTML = `<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>`
    tag.appendChild(btn)

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
    const serviceId = parseInt(event.currentTarget.dataset.serviceId)
    this.selectedServiceIds.delete(serviceId)

    const tag = this.selectedTarget.querySelector(`:scope > [data-service-id="${serviceId}"]`)
    if (tag) tag.remove()
    const hidden = this.hiddenFieldsTarget.querySelector(`input[data-service-id="${serviceId}"]`)
    if (hidden) hidden.remove()

    this.renderSuggestions()
    if (this.hasEmptyMessageTarget && this.selectedServiceIds.size === 0) {
      this.emptyMessageTarget.classList.remove("hidden")
    }
  }

  closeDropdown() {
    if (!this.hasDropdownTarget) return
    this.dropdownTarget.classList.add("hidden")
    this.dropdownTarget.innerHTML = ""
  }
}
