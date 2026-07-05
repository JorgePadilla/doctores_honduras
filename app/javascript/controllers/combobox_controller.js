import { Controller } from "@hotwired/stimulus"

// Combobox filtrable (patrón ARIA APG). Escribí para filtrar la lista de forma
// insensible a acentos ("cesarea" encuentra "Cesárea"), navegá con ↑/↓, elegí
// con Enter o click. Al elegir: setea el hidden field con el valor canónico,
// actualiza el label de la píldora, cierra el popover y envía el form al frame.
//
// Convive con `popover` en el mismo elemento; escucha `popover:opened` para
// resetear el filtro cada vez que se abre.
export default class extends Controller {
  static targets = ["field", "search", "option", "empty", "label", "trigger"]
  static values = { placeholder: String }

  connect() {
    this.active = -1
  }

  // minúsculas y sin acentos.
  norm(s) {
    return (s || "").toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "")
  }

  reset() {
    this.searchTarget.value = ""
    this.applyFilter("")
  }

  filter() {
    this.applyFilter(this.norm(this.searchTarget.value.trim()))
  }

  applyFilter(q) {
    let visible = 0
    this.optionTargets.forEach((li) => {
      // "Todas…" (valor vacío) siempre visible.
      const match = !q || li.dataset.value === "" || this.norm(li.textContent).includes(q)
      li.classList.toggle("hidden", !match)
      if (match) visible++
    })
    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", visible > 0)
    this.active = -1
    this.clearHighlight()
  }

  get shown() {
    return this.optionTargets.filter((li) => !li.classList.contains("hidden"))
  }

  nav(e) {
    const opts = this.shown
    if (e.key === "ArrowDown") {
      e.preventDefault()
      this.active = Math.min(this.active + 1, opts.length - 1)
      this.highlight(opts)
    } else if (e.key === "ArrowUp") {
      e.preventDefault()
      this.active = Math.max(this.active - 1, 0)
      this.highlight(opts)
    } else if (e.key === "Enter") {
      e.preventDefault();
      (opts[this.active] || opts[0])?.click()
    }
  }

  highlight(opts) {
    this.clearHighlight()
    const el = opts[this.active]
    if (el) {
      el.classList.add("is-active")
      el.setAttribute("aria-selected", "true")
      this.searchTarget.setAttribute("aria-activedescendant", el.id || "")
      el.scrollIntoView({ block: "nearest" })
    }
  }

  clearHighlight() {
    this.optionTargets.forEach((li) => {
      li.classList.remove("is-active")
      li.setAttribute("aria-selected", "false")
    })
    this.searchTarget.removeAttribute("aria-activedescendant")
  }

  // click->combobox#select delegado en el <ul>: resuelve la opción clickeada.
  select(e) {
    const li = e.target.closest("[role='option']")
    if (!li) return
    const value = li.dataset.value || ""
    this.fieldTarget.value = value
    this.setLabel(value ? li.textContent.trim() : "")
    this.closePopover()
    this.submit()
  }

  setLabel(text) {
    if (this.hasLabelTarget) this.labelTarget.textContent = text || this.placeholderValue
    if (this.hasTriggerTarget) this.triggerTarget.classList.toggle("is-active", !!text)
  }

  closePopover() {
    const pop = this.application.getControllerForElementAndIdentifier(this.element, "popover")
    if (pop) pop.close()
  }

  submit() {
    this.element.closest("form")?.requestSubmit()
  }
}
