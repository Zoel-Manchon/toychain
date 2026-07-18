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

class ChainValidator
  # Posición (0-based) del primer bloque que rompe la cadena, o nil si es válida.
  # Un bloque falla por integridad (su hash no verifica contra sus datos)
  # o por enlace (su previous_hash no coincide con el hash del anterior).
  def self.first_invalid_position(blocks)
    previous_hash = nil

    blocks.each_with_index do |block, position|
      link_ok = previous_hash.nil? || block.previous_hash == previous_hash
      integrity_ok = block.block_hash == ProofOfWork.compute(
        block.block_index, block.data, block.previous_hash, block.nonce
      )

      return position unless link_ok && integrity_ok

      previous_hash = block.block_hash
    end

    nil
  end

  def self.valid?(blocks)
    first_invalid_position(blocks).nil?
  end
end
