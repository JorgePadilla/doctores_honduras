import { Controller } from "@hotwired/stimulus"

// Dropdown de navbar (menú de usuario y campana de notificaciones). Toggle con
// click; cierra con click-afuera, Escape, o cuando se abre otro dropdown.
// Maneja aria-expanded. Reemplaza el <script> inline que re-ligaba handlers en
// cada turbo:render.
//
//   <div data-controller="dropdown">
//     <button data-dropdown-target="trigger" data-action="dropdown#toggle">…</button>
//     <div data-dropdown-target="menu" class="hidden">…</div>
//   </div>
export default class extends Controller {
  static targets = ["trigger", "menu"]

  connect() {
    this.onDocClick = this.onDocClick.bind(this)
    this.onKeydown = this.onKeydown.bind(this)
    this.onOtherOpen = this.onOtherOpen.bind(this)
    document.addEventListener("dropdown:open", this.onOtherOpen)
  }

  disconnect() {
    this.removeListeners()
    document.removeEventListener("dropdown:open", this.onOtherOpen)
  }

  toggle(e) {
    e.preventDefault()
    e.stopPropagation()
    this.isOpen ? this.close() : this.open()
  }

  open() {
    if (this.isOpen) return
    document.dispatchEvent(new CustomEvent("dropdown:open", { detail: { source: this } }))
    this.menuTarget.classList.remove("hidden")
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.onDocClick, true)
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    if (!this.isOpen) return
    this.menuTarget.classList.add("hidden")
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-expanded", "false")
    this.removeListeners()
  }

  get isOpen() { return !this.menuTarget.classList.contains("hidden") }

  removeListeners() {
    document.removeEventListener("click", this.onDocClick, true)
    document.removeEventListener("keydown", this.onKeydown)
  }

  onDocClick(e) {
    if (!this.element.contains(e.target)) this.close()
  }

  onKeydown(e) {
    if (e.key === "Escape") {
      this.close()
      if (this.hasTriggerTarget) this.triggerTarget.focus()
    }
  }

  onOtherOpen(e) {
    if (e.detail.source !== this) this.close()
  }
}
