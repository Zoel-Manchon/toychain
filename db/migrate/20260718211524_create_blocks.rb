class CreateBlocks < ActiveRecord::Migration[8.1]
  def change
    create_table :blocks do |t|
      t.integer :block_index
      t.text :data
      t.string :previous_hash
      t.string :block_hash
      t.integer :nonce
      t.datetime :mined_at

      t.timestamps
    end
  end
end
