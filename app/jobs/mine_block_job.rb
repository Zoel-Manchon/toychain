class MineBlockJob < ApplicationJob
  queue_as :default

  def perform(data)
    block_index = Block.next_index
    previous_hash = Block.latest_hash

    result = ProofOfWork.mine(
      block_index: block_index,
      data: data,
      previous_hash: previous_hash
    )

    Block.create!(
      block_index: block_index,
      data: data,
      previous_hash: previous_hash,
      block_hash: result[:block_hash],
      nonce: result[:nonce],
      mined_at: Time.current
    )
  end

  def perform(data)
  block_index = Block.next_index
  previous_hash = Block.latest_hash

  result = ProofOfWork.mine(
    block_index: block_index,
    data: data,
    previous_hash: previous_hash
  )

  Block.create!(
    block_index: block_index,
    data: data,
    previous_hash: previous_hash,
    block_hash: result[:block_hash],
    nonce: result[:nonce],
    mined_at: Time.current
  )

  broadcast_chain
end

private

  def broadcast_chain
    blocks = Block.all
    Turbo::StreamsChannel.broadcast_replace_to(
      "chain",
      target: "chain",
      partial: "blocks/chain",
      locals: { blocks: blocks, first_invalid: ChainValidator.first_invalid_position(blocks) }
    )
  end
end
