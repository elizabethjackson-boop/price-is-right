class AddIndexToGuessesOnPlayerIdAndRound < ActiveRecord::Migration[8.1]
  def change
    add_index :guesses, [:player_id, :round], unique: true
  end
end
