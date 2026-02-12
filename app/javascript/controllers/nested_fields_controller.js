import { Controller } from "@hotwired/stimulus"

// Reusable controller for dynamically adding/removing nested form entries.
// Uses a <template> tag with NEW_RECORD placeholder replaced by timestamp.
//
// Supports an optional max-entries value to limit how many entries can be added.
// When the limit is reached, the add button is hidden and an upgrade target is shown.

export default class extends Controller {
  static targets = ["template", "container", "addButton", "upgrade"]
  static values = { maxEntries: { type: Number, default: 0 } }

  connect() {
    this.enforceLimit()
  }

  add(event) {
    event.preventDefault()
    if (this.maxEntriesValue > 0 && this.visibleCount() >= this.maxEntriesValue) return

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
    this.enforceLimit()
  }

  remove(event) {
    event.preventDefault()
    const entry = event.target.closest("[data-nested-fields-entry]")
    if (!entry) return

    const destroyInput = entry.querySelector("input[name*='_destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
      entry.style.display = "none"
    } else {
      entry.remove()
    }
    this.enforceLimit()
  }

  visibleCount() {
    return this.containerTarget.querySelectorAll("[data-nested-fields-entry]:not([style*='display: none'])").length
  }

  enforceLimit() {
    if (this.maxEntriesValue <= 0) return

    const atLimit = this.visibleCount() >= this.maxEntriesValue

    if (this.hasAddButtonTarget) {
      this.addButtonTarget.style.display = atLimit ? "none" : ""
    }
    if (this.hasUpgradeTarget) {
      this.upgradeTarget.style.display = atLimit ? "" : "none"
    }
  }
}
