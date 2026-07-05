import { Controller } from "@hotwired/stimulus"

// Paleta de comandos ⌘K / Ctrl+K: buscador instantáneo global de doctores con
// navegación por teclado (↑ ↓ ↵) y Esc para cerrar. Se puede abrir con el
// atajo o con un botón (data-action="command-palette#open").
export default class extends Controller {
  static targets = ["overlay", "panel", "input", "results"]
  static values = { url: String }

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    document.addEventListener("keydown", this.onKeydown)
    this.timeout = null
    this.items = []
    this.selected = -1
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    clearTimeout(this.timeout)
    document.body.style.overflow = ""
  }

  onKeydown(e) {
    const isK = e.key === "k" || e.key === "K"
    if ((e.metaKey || e.ctrlKey) && isK) {
      e.preventDefault()
      this.isOpen() ? this.close() : this.open()
    } else if (e.key === "Escape" && this.isOpen()) {
      this.close()
    }
  }

  isOpen() { return !this.overlayTarget.classList.contains("hidden") }

  open() {
    this.overlayTarget.classList.remove("hidden")
    this.overlayTarget.classList.add("flex")
    document.body.style.overflow = "hidden"
    requestAnimationFrame(() => { this.inputTarget.focus(); this.inputTarget.select() })
  }

  close() {
    this.overlayTarget.classList.add("hidden")
    this.overlayTarget.classList.remove("flex")
    document.body.style.overflow = ""
    this.inputTarget.value = ""
    this.resultsTarget.innerHTML = ""
    this.items = []
    this.selected = -1
  }

  backdropClose(e) {
    if (e.target === this.overlayTarget) this.close()
  }

  search() {
    clearTimeout(this.timeout)
    const q = this.inputTarget.value.trim()
    if (q.length < 2) { this.resultsTarget.innerHTML = ""; this.items = []; this.selected = -1; return }
    this.timeout = setTimeout(() => {
      fetch(`${this.urlValue}?q=${encodeURIComponent(q)}`, { headers: { Accept: "application/json" } })
        .then((r) => r.json())
        .then((data) => this.render(data.doctors || [], q))
        .catch(() => {})
    }, 180)
  }

  render(doctors, q) {
    let html = ""
    if (doctors.length) {
      html += `<p class="px-3 pt-2 pb-1 text-xs font-medium uppercase tracking-wider text-muted">Doctores</p>`
      doctors.forEach((d) => {
        const meta = [d.specialty, d.city].filter(Boolean).join(" · ")
        const avatar = d.thumb
          ? `<img src="${this.esc(d.thumb)}" class="h-full w-full object-cover">`
          : `<span class="font-display text-sm font-semibold text-primary/60">${this.esc((d.name || "?")[0])}</span>`
        html += `<a href="${this.esc(d.url)}" data-cp-item class="flex items-center gap-3 rounded-xl px-3 py-2 transition-colors">
          <span class="flex h-9 w-9 shrink-0 items-center justify-center overflow-hidden rounded-full bg-primary-soft dark:bg-slate-700">${avatar}</span>
          <span class="min-w-0 flex-1">
            <span class="block truncate text-sm font-medium text-ink dark:text-white">${this.esc(d.name)}</span>
            ${meta ? `<span class="block truncate text-xs text-muted">${this.esc(meta)}</span>` : ""}
          </span>
        </a>`
      })
    } else {
      html += `<p class="px-3 py-6 text-center text-sm text-muted">Sin coincidencias directas.</p>`
    }
    html += `<a href="/doctors?q=${encodeURIComponent(q)}" data-cp-item class="mt-1 flex items-center gap-2 rounded-xl px-3 py-2 text-sm font-medium text-primary transition-colors">
      Ver todos los resultados de “${this.esc(q)}”</a>`

    this.resultsTarget.innerHTML = html
    this.items = Array.from(this.resultsTarget.querySelectorAll("[data-cp-item]"))
    this.selected = this.items.length ? 0 : -1
    this.highlight()
  }

  nav(e) {
    if (!this.items.length) return
    if (e.key === "ArrowDown") {
      e.preventDefault(); this.selected = (this.selected + 1) % this.items.length; this.highlight()
    } else if (e.key === "ArrowUp") {
      e.preventDefault(); this.selected = (this.selected - 1 + this.items.length) % this.items.length; this.highlight()
    } else if (e.key === "Enter") {
      e.preventDefault(); this.items[this.selected]?.click()
    }
  }

  highlight() {
    this.items.forEach((el, i) => {
      const on = i === this.selected
      el.classList.toggle("bg-primary-soft", on)
      el.classList.toggle("dark:bg-slate-700/60", on)
    })
    this.items[this.selected]?.scrollIntoView({ block: "nearest" })
  }

  esc(s) {
    const d = document.createElement("div")
    d.textContent = s == null ? "" : String(s)
    return d.innerHTML
  }
}
