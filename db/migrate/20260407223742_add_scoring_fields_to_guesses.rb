class AddScoringFieldsToGuesses < ActiveRecord::Migration[8.1]
  def change
    add_column :guesses, :speed_bonus, :integer, default: 0, null: false
    add_column :guesses, :points, :integer, default: 0, null: false
  end
end
