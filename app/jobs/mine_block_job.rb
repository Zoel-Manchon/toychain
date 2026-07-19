class MineBlockJob < ApplicationJob
  queue_as :default

  def perform(data, difficulty = ProofOfWork::DIFFICULTY)
    block_index = Block.next_index
    previous_hash = Block.latest_hash

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = ProofOfWork.mine(
      block_index: block_index,
      data: data,
      previous_hash: previous_hash,
      difficulty: difficulty
    )
    elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round

    Block.create!(
      block_index: block_index,
      data: data,
      previous_hash: previous_hash,
      block_hash: result[:block_hash],
      nonce: result[:nonce],
      difficulty: difficulty,
      mined_ms: elapsed_ms,
      mined_at: Time.current
    )

    # Este job aún cuenta como no-terminado mientras corre perform: lo excluimos.
    ChainBroadcaster.call(pending: [ MiningQueue.pending - 1, 0 ].max)
  end
end
