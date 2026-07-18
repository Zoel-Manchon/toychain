class ProofOfWork
  DIFFICULTY = 4

  def self.mine(block_index:, data:, previous_hash:)
    nonce = 0
    loop do
      digest = compute(block_index, data, previous_hash, nonce)
      return { block_hash: digest, nonce: nonce } if digest.start_with?("0" * DIFFICULTY)

      nonce += 1
    end
  end

  def self.compute(block_index, data, previous_hash, nonce)
    Digest::SHA256.hexdigest("#{block_index}#{data}#{previous_hash}#{nonce}")
  end
end