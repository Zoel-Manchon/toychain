module Api
  module V1
    class ChainController < ApplicationController
      # La API no usa cookies de sesión: autentica por token Bearer.
      allow_unauthenticated_access
      skip_before_action :verify_authenticity_token
      before_action :authenticate_token!

      def show
        blocks = Block.includes(:user)
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

      def authenticate_token!
        authenticate_or_request_with_http_token do |raw, _options|
          token = ApiToken.authenticate(raw)
          token&.touch(:last_used_at)
          @current_operator = token&.user
        end
      end

      def serialize(block)
        {
          index: block.block_index,
          data: block.data,
          previous_hash: block.previous_hash,
          hash: block.block_hash,
          nonce: block.nonce,
          difficulty: block.difficulty,
          mined_ms: block.mined_ms,
          mined_at: block.mined_at,
          mined_by: block.user&.email_address
        }
      end
    end
  end
end
