import { Controller } from "@hotwired/stimulus"

// Shows the panel whose data-mode matches the checked radio button.
export default class extends Controller {
  static targets = ["mode", "panel"]

  connect() {
    this.update()
  }

  update() {
    const mode = this.modeTargets.find((radio) => radio.checked)?.value
    this.panelTargets.forEach((panel) => panel.hidden = panel.dataset.mode !== mode)
  }
}
