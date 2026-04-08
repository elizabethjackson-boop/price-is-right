import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Small random delay (0-500ms) to slightly spread out reloads from 100 players
    // Kept short so rapid host actions (reveal -> advance) don't cause missed broadcasts
    const delay = Math.random() * 500
    this.timeout = setTimeout(() => {
      Turbo.visit(window.location.href, { action: "replace" })
    }, delay)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }
}
