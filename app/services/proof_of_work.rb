class ProofOfWork
  DIFFICULTY = 4                  # default
  DIFFICULTY_RANGE = (2..6).freeze

  def self.mine(block_index:, data:, previous_hash:, difficulty: DIFFICULTY)
    nonce = 0
    target = "0" * difficulty
    loop do
      digest = compute(block_index, data, previous_hash, nonce)
      return { block_hash: digest, nonce: nonce } if digest.start_with?(target)

      nonce += 1
    end
  end

  def self.compute(block_index, data, previous_hash, nonce)
    Digest::SHA256.hexdigest("#{block_index}#{data}#{previous_hash}#{nonce}")
  end
end
