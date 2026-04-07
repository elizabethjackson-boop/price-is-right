class Player < ApplicationRecord
  belongs_to :game
  has_many :guesses, dependent: :destroy

  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  def current_guess(round)
    guesses.find_by(round: round)
  end

  private

  def generate_token
    self.token ||= SecureRandom.uuid
  end
end
