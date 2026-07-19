class ChainValidator
  # Posición (0-based) del primer bloque que rompe la cadena, o nil si es válida.
  # Un bloque falla por enlace (previous_hash no coincide), por integridad
  # (su hash no verifica contra sus datos) o por trabajo (el hash no cumple
  # la dificultad que el propio bloque declara).
  def self.first_invalid_position(blocks)
    previous_hash = nil

    blocks.each_with_index do |block, position|
      link_ok = previous_hash.nil? || block.previous_hash == previous_hash
      integrity_ok = block.block_hash == ProofOfWork.compute(
        block.block_index, block.data, block.previous_hash, block.nonce
      )
      work_ok = block.block_hash.start_with?("0" * block.difficulty.to_i)

      return position unless link_ok && integrity_ok && work_ok

      previous_hash = block.block_hash
    end

    nil
  end

  def self.valid?(blocks)
    first_invalid_position(blocks).nil?
  end
end
