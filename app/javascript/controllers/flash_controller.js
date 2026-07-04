import { Controller } from "@hotwired/stimulus"

// Toast flash message: slides in on connect, auto-dismisses after `delay` ms,
// and can be dismissed manually via data-action="click->flash#dismiss".
export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    // Slide/fade in on the next frame (element starts at opacity-0 translate-x-4).
    requestAnimationFrame(() => {
      this.element.classList.remove("opacity-0", "translate-x-4")
    })

    if (this.delayValue > 0) {
      this.timeout = setTimeout(() => this.remove(), this.delayValue)
    }
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  remove() {
    if (this.timeout) clearTimeout(this.timeout)
    this.element.classList.add("opacity-0", "translate-x-4")
    setTimeout(() => this.element.remove(), 300)
  }

  dismiss(event) {
    if (event) event.preventDefault()
    this.remove()
  }
}
