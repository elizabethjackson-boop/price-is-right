class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :guesses, through: :players

  # Real Clever Real Estate closed deals — shuffled so prices aren't predictable
  # images: array of paths served from public/listing-photos/
  # First image is the hero (large), rest are secondary (smaller, side by side)
  LISTINGS = [
    {   # Round 1 — $546,900
      images: ["/listing-photos/13910-1.webp", "/listing-photos/13910-2.webp", "/listing-photos/13910-3.webp"],
      address: "13910 NE 101st St, Vancouver, WA",
      beds: 3, baths: 3, sqft: "1,952", price: 546_900, year: 2014,
      lot: "5,227 sqft", property_type: "Single Family",
      label: "Offers (Agent)", deal_product: "Offers",
      deal_type: "Seller", vendor: nil,
      bif: false, closings: false
    },
    {   # Round 2 — $182,000
      images: ["/listing-photos/4444-1.webp"],
      address: "4444 Carmanwood Dr, Flint, MI",
      beds: 3, baths: 1, sqft: "1,587", price: 182_000, year: 1959,
      lot: "10,454 sqft", property_type: "Single Family",
      label: "Pro Buyer + BIF + Closings", deal_product: "Pro Buyer",
      deal_type: "Buyer", vendor: "Best Interest Financial",
      bif: true, closings: true
    },
    {   # Round 3 — $925,000
      images: ["/listing-photos/11442-1.webp"],
      address: "11442 Pinehurst Dr, Lakeside, CA",
      beds: 4, baths: 3, sqft: "2,219", price: 925_000, year: 1953,
      lot: "1.49 Acres", property_type: "Single Family",
      label: "Pro Buyer (U.S. Bank)", deal_product: "Pro Buyer",
      deal_type: "Buyer", vendor: "U.S. Bank",
      bif: false, closings: false
    },
    {   # Round 4 — $440,000
      images: ["/listing-photos/8407-1.webp", "/listing-photos/8407-2.webp", "/listing-photos/8407-3.webp"],
      address: "8407 Bending Branch Ln, Cypress, TX",
      beds: 4, baths: 4, sqft: "3,400", price: 440_000, year: 2004,
      lot: "8,842 sqft", property_type: "Single Family",
      label: "Listing Agent + Closings", deal_product: "D2C Seller",
      deal_type: "Seller", vendor: nil,
      bif: false, closings: true
    },
    {   # Round 5 — $1,120,000
      images: ["/listing-photos/5206-1.png"],
      address: "5206 Teesdale Ave, Valley Village, CA",
      beds: 3, baths: 2, sqft: "1,736", price: 1_120_000, year: 1948,
      lot: "7,005 sqft", property_type: "Single Family",
      label: "Offers (Agent) + Closings", deal_product: "Offers",
      deal_type: "Seller", vendor: nil,
      bif: false, closings: true
    },
    {   # Round 6 — $212,000
      images: ["/listing-photos/1801-1.webp", "/listing-photos/1801-2.webp", "/listing-photos/1801-3.webp"],
      address: "1801 Winston Dr, South Bend, IN",
      beds: 4, baths: 2, sqft: "1,462", price: 212_000, year: 1961,
      lot: "8,276 sqft", property_type: "Single Family",
      label: "Listing Agent", deal_product: "D2C Seller",
      deal_type: "Seller", vendor: nil,
      bif: false, closings: false
    },
    {   # Round 7 — $780,000
      images: ["/listing-photos/3219-1.webp", "/listing-photos/3219-2.webp", "/listing-photos/3219-3.webp"],
      address: "3219 N Richmond St, Chicago, IL",
      beds: 4, baths: 4, sqft: "1,920", price: 780_000, year: 1993,
      lot: "3,149 sqft", property_type: "Single Family",
      label: "Listing Agent", deal_product: "D2C Seller",
      deal_type: "Seller", vendor: nil,
      bif: false, closings: false
    },
    {   # Round 8 — $474,990
      images: ["/listing-photos/181-1.webp", "/listing-photos/181-2.webp", "/listing-photos/181-3.webp"],
      address: "181 Austrian Dr, Blandon, PA",
      beds: 4, baths: 3, sqft: "2,263", price: 474_990, year: 2025,
      lot: "0.27 Acres", property_type: "Single Family",
      label: "Pro Buyer (U.S. Bank)", deal_product: "Pro Buyer",
      deal_type: "Buyer", vendor: "U.S. Bank",
      bif: false, closings: false
    },
    {   # Round 9 — $940,000
      images: ["/listing-photos/965-1.webp", "/listing-photos/965-2.webp", "/listing-photos/965-3.webp"],
      address: "965 Chatsworth Dr, Melbourne, FL",
      beds: 4, baths: 4, sqft: "3,894", price: 940_000, year: 2001,
      lot: "0.32 Acres", property_type: "Single Family",
      label: "Listing Agent + Closings", deal_product: "D2C Seller",
      deal_type: "Seller", vendor: nil,
      bif: false, closings: true
    },
    {   # Round 10 — $640,000
      images: ["/listing-photos/13828-1.webp", "/listing-photos/13828-2.webp", "/listing-photos/13828-3.webp"],
      address: "13828 N Lobelia Way, Oro Valley, AZ",
      beds: 2, baths: 2, sqft: "1,745", price: 640_000, year: 1995,
      lot: "6,970 sqft", property_type: "Single Family",
      label: "Listing Agent + Closings", deal_product: "D2C Seller",
      deal_type: "Seller", vendor: nil,
      bif: false, closings: true
    },
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

  def leaderboard(limit: 5)
    players.order(score: :desc, created_at: :asc).limit(limit)
  end

  def round_results
    guesses.where(round: current_round)
           .includes(:player)
           .where.not(result: nil)
           .order(points: :desc, created_at: :asc)
  end

  # Top 5 closest guesses across all rounds (without going over).
  # Returns guesses sorted by smallest |diff| (closest to actual price).
  def best_guesses(limit: 5)
    guesses.includes(:player)
           .where(result: %w[win exact])
           .order(Arel.sql("ABS(diff) ASC"))
           .limit(limit)
  end

  # Accuracy-only scoring — no speed bonus.
  # Over = 0 pts. Under = points by accuracy tier.
  # Max 1,000 per round, 10,000 across all 10 rounds.
  def score_round!
    listing = current_listing
    actual_price = listing[:price]

    # Speed rank is determined by created_at order. Tests that assert speed bonuses
    # must set explicit created_at values on guesses to avoid non-deterministic rank
    # when two guesses are created within the same millisecond.
    round_guesses = guesses.where(round: current_round)
                           .includes(:player)
                           .order(:created_at)

    round_guesses.each do |guess|
      diff = guess.amount - actual_price
      over = diff > 0
      exact = diff == 0
      result = exact ? "exact" : over ? "lose" : "win"
      guess.assign_attributes(diff: diff, result: result)

      if over
        guess.assign_attributes(speed_bonus: 0, points: 0)
      else
        pct_off = diff.abs.to_f / actual_price * 100

        points = if pct_off <= 5     then 1000   # within 5% or exact
                 elsif pct_off <= 10  then 750    # within 10%
                 elsif pct_off <= 25  then 500    # within 25%
                 else                      250    # under but far off
                 end

        guess.assign_attributes(speed_bonus: 0, points: points)
      end
    end

    # Bulk save in a transaction.
    # Player scores are updated via a single correlated UPDATE to avoid N+1.
    Guess.transaction do
      round_guesses.each(&:save!)
      Player.where(game_id: id)
            .update_all("score = (SELECT COALESCE(SUM(points), 0) FROM guesses WHERE guesses.player_id = players.id)")
    end
  end

  private

  def generate_code
    self.code ||= SecureRandom.alphanumeric(6).upcase
  end
end
