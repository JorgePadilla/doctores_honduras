import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["branchSelect", "dateInput", "slotsContainer", "startTime", "endTime"]

  connect() {
    this.selectedSlot = null
  }

  loadSlots() {
    const branchId = this.branchSelectTarget.value
    const date = this.dateInputTarget.value

    if (!branchId || !date) return

    this.slotsContainerTarget.innerHTML = '<p class="col-span-full text-sm text-gray-500 dark:text-gray-400">Cargando horarios...</p>'

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(`/agenda/slots?branch_id=${branchId}&date=${date}`, {
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken
      }
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
      button.dataset.startTime = slot.start_time
      button.dataset.endTime = slot.end_time

      if (slot.available) {
        button.className = "px-3 py-2 text-sm rounded-lg border border-gray-300 dark:border-slate-600 text-gray-700 dark:text-gray-300 hover:border-sky-500 hover:text-sky-600 dark:hover:text-sky-400 transition cursor-pointer"
        button.addEventListener("click", () => this.selectSlot(button, slot))
      } else {
        button.className = "px-3 py-2 text-sm rounded-lg border border-gray-200 dark:border-slate-700 text-gray-400 dark:text-gray-600 cursor-not-allowed line-through"
        button.disabled = true
      }

      button.textContent = slot.start_time

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

    // Update hidden fields
    this.startTimeTarget.value = slot.start_time
    this.endTimeTarget.value = slot.end_time
  }
}
