class Guess < ApplicationRecord
  belongs_to :player

  validates :round, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :round, uniqueness: { scope: :player_id }

  def correct?
    result.in?(%w[win exact])
  end
end
