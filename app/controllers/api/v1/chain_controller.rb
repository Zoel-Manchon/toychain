module Api
  module V1
    class ChainController < ApplicationController
      def show
        blocks = Block.all
        first_invalid = ChainValidator.first_invalid_position(blocks)

        render json: {
          valid: first_invalid.nil?,
          first_invalid: first_invalid,
          length: blocks.size,
          pending: MiningQueue.pending,
          blocks: blocks.map { |block| serialize(block) }
        }
      end

      private

      def serialize(block)
        {
          index: block.block_index,
          data: block.data,
          previous_hash: block.previous_hash,
          hash: block.block_hash,
          nonce: block.nonce,
          difficulty: block.difficulty,
          mined_ms: block.mined_ms,
          mined_at: block.mined_at
        }
      end
    end
  end
end
