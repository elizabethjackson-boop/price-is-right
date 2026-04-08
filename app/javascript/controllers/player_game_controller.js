import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    gameId: Number,
    playerId: Number,
    gameState: String,
    currentRound: Number,
    totalRounds: Number,
    gameCode: String,
    token: String
  }

  connect() {
    this.startPolling()
  }

  disconnect() {
    this.stopPolling()
  }

  startPolling() {
    this.pollInterval = setInterval(() => {
      this.checkForStateChange()
    }, 1500)
  }

  stopPolling() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
      this.pollInterval = null
    }
  }

  async checkForStateChange() {
    try {
      const response = await fetch(`/games/${this.gameIdValue}/status`, {
        headers: { "Accept": "application/json" }
      })
      const data = await response.json()

      // If state or round changed, reload the page
      if (data.state !== this.gameStateValue || data.current_round !== this.currentRoundValue) {
        this.stopPolling()
        Turbo.visit(window.location.href, { action: "replace" })
      }
    } catch (e) {
      // Silently fail — will retry on next poll
    }
  }

  formatAmount(event) {
    const input = event.target
    const raw = input.value.replace(/[^0-9]/g, "")
    if (raw) {
      input.value = Number(raw).toLocaleString()
    } else {
      input.value = ""
    }
  }

  submitGuess(event) {
    event.preventDefault()
    const form = document.getElementById("guess-form")
    if (form) form.requestSubmit()
  }
}
