class Block < ApplicationRecord
  validates :data, presence: true

  default_scope { order(:block_index) }

  def self.next_index
    maximum(:block_index).to_i + 1
  end

  def self.latest_hash
    order(:block_index).last&.block_hash || GENESIS_HASH
  end

  GENESIS_HASH = "0" * 64
end
