class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :guesses, through: :players

  LISTINGS = [
    { image: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=500&fit=crop", address: "2847 Ridgecrest Dr, Austin, TX", beds: 3, baths: 2, sqft: "2,100", price: 485_000, year: 2019, feature: "Open concept with chef's kitchen" },
    { image: "https://images.unsplash.com/photo-1600596542815-ffad4c1539a6?w=800&h=500&fit=crop", address: "914 Elm Park Ln, Nashville, TN", beds: 4, baths: 3, sqft: "2,800", price: 625_000, year: 2017, feature: "Wraparound porch, finished basement" },
    { image: "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&h=500&fit=crop", address: "1120 Maple Ridge Ct, Denver, CO", beds: 3, baths: 2, sqft: "1,950", price: 550_000, year: 2021, feature: "Mountain views, updated throughout" },
    { image: "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=500&fit=crop", address: "5503 Oakwood Dr, Raleigh, NC", beds: 4, baths: 3, sqft: "3,200", price: 725_000, year: 2023, feature: "New build, smart home wired" },
    { image: "https://images.unsplash.com/photo-1600566753376-12c8ab7c17a7?w=800&h=500&fit=crop", address: "780 Desert Bloom Way, Phoenix, AZ", beds: 3, baths: 2, sqft: "1,800", price: 410_000, year: 2020, feature: "Pool & spa, desert landscaping" }
  ].freeze

  STATES = %w[waiting playing revealing finished].freeze

  validates :code, presence: true, uniqueness: true
  validates :state, inclusion: { in: STATES }

  before_validation :generate_code, on: :create

  def current_listing
    LISTINGS[current_round]
  end

  def total_rounds
    LISTINGS.length
  end

  def last_round?
    current_round >= total_rounds - 1
  end

  def channel_name
    "game_#{id}"
  end

  def score_round!
    listing = current_listing
    actual_price = listing[:price]

    players.each do |player|
      guess = player.guesses.find_by(round: current_round)
      next unless guess

      diff = guess.amount - actual_price
      over = diff > 0
      exact = diff == 0

      guess.update!(
        diff: diff,
        result: exact ? "exact" : over ? "lose" : "win"
      )

      player.increment!(:score) unless over
    end
  end

  private

  def generate_code
    self.code ||= SecureRandom.alphanumeric(6).upcase
  end
end
