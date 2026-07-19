class AddDifficultyToBlocks < ActiveRecord::Migration[8.1]
  def change
    add_column :blocks, :difficulty, :integer, default: 4, null: false
    add_column :blocks, :mined_ms, :integer
  end
end
