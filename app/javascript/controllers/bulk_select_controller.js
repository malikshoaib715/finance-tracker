import { Controller } from "@hotwired/stimulus"

// Tracks the ticked rows and shows the bulk action bar while any are selected.
export default class extends Controller {
  static targets = ["checkbox", "bar", "count"]

  connect() {
    this.update()
  }

  update() {
    const selected = this.checkboxTargets.filter((box) => box.checked).length
    this.barTarget.classList.toggle("hidden", selected === 0)
    this.countTarget.textContent = `${selected} selected`
  }

  clear() {
    this.checkboxTargets.forEach((box) => (box.checked = false))
    this.update()
  }
}
