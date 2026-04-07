class Guess < ApplicationRecord
  belongs_to :player

  validates :round, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
end
