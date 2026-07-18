class ChainValidator
  def self.valid?(blocks)
    blocks.each_cons(2).all? do |prev_block, current|
      current.previous_hash == prev_block.block_hash &&
        current.block_hash == ProofOfWork.compute(
          current.block_index, current.data, current.previous_hash, current.nonce
        )
    end
  end
end
