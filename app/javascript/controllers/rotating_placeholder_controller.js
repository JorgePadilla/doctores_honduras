import { Controller } from "@hotwired/stimulus"

// Rota el placeholder de un input entre varias frases (especialidades reales).
// Uso:
//   <div data-controller="rotating-placeholder"
//        data-rotating-placeholder-phrases-value='["Cardiología","Pediatría"]'
//        data-rotating-placeholder-interval-value="3000">
//     <input data-rotating-placeholder-target="input">
export default class extends Controller {
  static targets = ["input"]
  static values = {
    phrases: { type: Array, default: [] },
    interval: { type: Number, default: 3000 },
    prefix: { type: String, default: "" }
  }

  connect() {
    if (!this.hasInputTarget || this.phrasesValue.length === 0) return
    this.i = 0
    this.apply()
    this.timer = setInterval(() => this.rotate(), this.intervalValue)
  }

  rotate() {
    // No rotar mientras el usuario escribe.
    if (this.inputTarget.value.length > 0) return
    this.i = (this.i + 1) % this.phrasesValue.length
    this.apply()
  }

  apply() {
    this.inputTarget.setAttribute("placeholder", `${this.prefixValue}${this.phrasesValue[this.i]}`)
  }

  disconnect() {
    clearInterval(this.timer)
  }
}
