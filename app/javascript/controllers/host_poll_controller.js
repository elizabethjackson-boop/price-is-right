import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { gameId: Number }

  connect() {
    this.pollInterval = setInterval(() => {
      this.refreshGuessCount()
    }, 1000)
  }

  disconnect() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
      this.pollInterval = null
    }
  }

  async refreshGuessCount() {
    try {
      const response = await fetch(`/games/${this.gameIdValue}/status`, {
        headers: { "Accept": "application/json" }
      })
      const data = await response.json()

      const el = document.getElementById("guess-count-text")
      if (el) {
        el.textContent = `${data.guesses_count} / ${data.player_count} guesses received`
      }
    } catch (e) {
      // Silently fail
    }
  }
}
