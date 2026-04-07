class CreateGuesses < ActiveRecord::Migration[8.1]
  def change
    create_table :guesses do |t|
      t.references :player, null: false, foreign_key: true
      t.integer :round
      t.integer :amount
      t.string :result
      t.integer :diff

      t.timestamps
    end
  end
end
