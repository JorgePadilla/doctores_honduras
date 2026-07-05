import { Controller } from "@hotwired/stimulus"

// Scroll reveal: añade .is-visible cuando el elemento entra al viewport (una vez).
// Uso: <div data-controller="reveal" data-reveal-delay-value="60"> (delay en ms para stagger)
// El CSS (.reveal / .is-visible) hace el fade-up y respeta prefers-reduced-motion.
export default class extends Controller {
  static values = { delay: { type: Number, default: 0 } }

  connect() {
    // El elemento ya trae la clase .reveal en el HTML (evita flash). Si por
    // algún uso no la tiene, la añadimos.
    if (!this.element.classList.contains("reveal")) this.element.classList.add("reveal")

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.element.classList.add("is-visible")
      return
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return
        setTimeout(() => entry.target.classList.add("is-visible"), this.delayValue)
        this.observer.unobserve(entry.target)
      })
    }, { threshold: 0.12 })

    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
