import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "slotsContainer", "startTime", "endTime", "dateInput", "branchRadio", "submitArea"]

  connect() {
    this.currentStep = 1
    this.selectedBranchId = null
    this.selectedSlot = null
    this.doctorId = this.extractDoctorId()
  }

  extractDoctorId() {
    // Extract doctor_id from the form action URL: /doctors/:id/booking
    const form = this.element.closest("form") || this.element.querySelector("form")
    if (form) {
      const match = form.action.match(/\/doctors\/(\d+)\/booking/)
      if (match) return match[1]
    }
    return null
  }

  selectBranch(event) {
    const branchId = event.currentTarget.dataset.branchId
    this.selectedBranchId = branchId

    // Highlight selected branch
    this.element.querySelectorAll("[data-branch-id]").forEach(el => {
      el.classList.remove("border-sky-500", "bg-sky-50", "dark:bg-sky-900/20")
      el.classList.add("border-gray-200", "dark:border-slate-600")
    })
    event.currentTarget.classList.remove("border-gray-200", "dark:border-slate-600")
    event.currentTarget.classList.add("border-sky-500", "bg-sky-50", "dark:bg-sky-900/20")

    this.showStep(2)
  }

  selectDate() {
    const date = this.dateInputTarget.value
    if (!date || !this.selectedBranchId) return

    this.showStep(3)
    this.loadSlots()
  }

  loadSlots() {
    const branchId = this.selectedBranchId
    const date = this.dateInputTarget.value

    if (!branchId || !date || !this.doctorId) return

    this.slotsContainerTarget.innerHTML = '<p class="col-span-full text-sm text-gray-500 dark:text-gray-400">Cargando horarios...</p>'

    fetch(`/doctors/${this.doctorId}/booking/slots?branch_id=${branchId}&date=${date}`, {
      headers: { "Accept": "application/json" }
    })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.json()
      })
      .then(slots => this.renderSlots(slots))
      .catch(() => {
        this.slotsContainerTarget.innerHTML = '<p class="col-span-full text-sm text-red-500">Error al cargar horarios.</p>'
      })
  }

  renderSlots(slots) {
    if (slots.length === 0) {
      this.slotsContainerTarget.innerHTML = '<p class="col-span-full text-sm text-gray-500 dark:text-gray-400">No hay horarios disponibles para esta fecha.</p>'
      return
    }

    this.slotsContainerTarget.innerHTML = ""

    slots.forEach(slot => {
      const button = document.createElement("button")
      button.type = "button"
      button.className = "px-3 py-2 text-sm rounded-lg border border-gray-300 dark:border-slate-600 text-gray-700 dark:text-gray-300 hover:border-sky-500 hover:text-sky-600 transition cursor-pointer"
      button.textContent = slot.start_time
      button.addEventListener("click", () => this.selectSlot(button, slot))

      this.slotsContainerTarget.appendChild(button)
    })
  }

  selectSlot(button, slot) {
    // Deselect previous
    if (this.selectedSlot) {
      this.selectedSlot.classList.remove("bg-sky-500", "text-white", "border-sky-500")
      this.selectedSlot.classList.add("border-gray-300", "dark:border-slate-600", "text-gray-700", "dark:text-gray-300")
    }

    // Select new
    button.classList.remove("border-gray-300", "dark:border-slate-600", "text-gray-700", "dark:text-gray-300")
    button.classList.add("bg-sky-500", "text-white", "border-sky-500")
    this.selectedSlot = button

    this.startTimeTarget.value = slot.start_time
    this.endTimeTarget.value = slot.end_time

    this.showStep(4)
    this.submitAreaTarget.classList.remove("hidden")
  }

  showStep(step) {
    this.stepTargets.forEach(el => {
      const s = parseInt(el.dataset.step)
      if (s <= step) {
        el.classList.remove("hidden")
      } else {
        el.classList.add("hidden")
      }
    })
    this.currentStep = step
  }
}
