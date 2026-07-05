import { Controller } from "@hotwired/stimulus"

// Anima un número de 0 al target cuando entra al viewport (una sola vez).
// Uso: <span data-controller="count-up" data-count-up-target-value="973">0</span>
export default class extends Controller {
  static values = {
    target: Number,
    duration: { type: Number, default: 1200 }
  }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.render(this.targetValue)
      return
    }

    this.render(0) // arranca en 0 para animar hacia el target al entrar en viewport

    this.observer = new IntersectionObserver((entries) => {
      if (entries[0].isIntersecting) {
        this.animate()
        this.observer.disconnect()
      }
    }, { threshold: 0.6 })

    this.observer.observe(this.element)
  }

  animate() {
    const start = performance.now()
    const step = (now) => {
      const p = Math.min((now - start) / this.durationValue, 1)
      const eased = 1 - Math.pow(1 - p, 3)
      this.render(Math.round(this.targetValue * eased))
      if (p < 1) requestAnimationFrame(step)
    }
    requestAnimationFrame(step)
  }

  render(n) {
    this.element.textContent = n.toLocaleString("es-HN")
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
