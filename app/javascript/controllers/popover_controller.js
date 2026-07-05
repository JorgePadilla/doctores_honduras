import { Controller } from "@hotwired/stimulus"

// Popover anclado a un trigger (píldora de filtro). Abre un panel debajo en
// desktop y como bottom-sheet en móvil (todo por CSS via `.is-open` en la raíz).
// Cierra con click-afuera, Esc, o cuando se abre otro popover. Devuelve el foco
// al trigger al cerrar con Esc.
//
//   <div class="filter-unit" data-controller="popover">
//     <button data-popover-target="trigger" data-action="popover#toggle">…</button>
//     <div data-popover-target="backdrop" data-action="click->popover#close"></div>
//     <div data-popover-target="panel">…</div>
//   </div>
export default class extends Controller {
  static targets = ["trigger", "panel", "backdrop"]

  connect() {
    this.onDocClick = this.onDocClick.bind(this)
    this.onKeydown = this.onKeydown.bind(this)
    this.onOtherOpen = this.onOtherOpen.bind(this)
    document.addEventListener("popover:open", this.onOtherOpen)
  }

  disconnect() {
    this.removeListeners()
    document.removeEventListener("popover:open", this.onOtherOpen)
  }

  toggle(e) {
    e.preventDefault()
    this.isOpen ? this.close() : this.open()
  }

  open() {
    if (this.isOpen) return
    // Cierra cualquier otro popover abierto.
    document.dispatchEvent(new CustomEvent("popover:open", { detail: { source: this } }))
    this.element.classList.add("is-open")
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.onDocClick, true)
    document.addEventListener("keydown", this.onKeydown)
    // Avisa a controllers hermanos (p.ej. combobox resetea su filtro).
    this.dispatch("opened")
    requestAnimationFrame(() => {
      const focusable = this.hasPanelTarget &&
        this.panelTarget.querySelector("input, select, button, [tabindex]:not([tabindex='-1'])")
      if (focusable) focusable.focus()
    })
  }

  close() {
    if (!this.isOpen) return
    this.element.classList.remove("is-open")
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-expanded", "false")
    this.removeListeners()
  }

  get isOpen() { return this.element.classList.contains("is-open") }

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
