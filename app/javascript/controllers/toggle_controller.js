import { Controller } from "@hotwired/stimulus"

// Shows and hides a panel, e.g. the mobile navigation.
export default class extends Controller {
  static targets = ["panel", "button"]

  toggle() {
    const hidden = this.panelTarget.classList.toggle("hidden")
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", String(!hidden))
  }
}
