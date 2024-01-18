import { Controller } from "@hotwired/stimulus"

// Fades out a flash message after a few seconds, or immediately when closed.
export default class extends Controller {
  static values = { timeout: { type: Number, default: 5000 } }

  connect() {
    this.timer = setTimeout(() => this.dismiss(), this.timeoutValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.classList.add("opacity-0")
    setTimeout(() => this.element.remove(), 300)
  }
}
