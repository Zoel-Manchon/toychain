class ChainBroadcaster
  # Punto único de difusión: cualquier cambio en la cadena (minado, tamper,
  # reset, encolado) pasa por aquí para que todos los navegadores suscritos
  # vean el mismo estado.
  def self.call(pending: MiningQueue.pending)
    blocks = Block.all
    Turbo::StreamsChannel.broadcast_replace_to(
      "chain",
      target: "chain",
      partial: "blocks/chain",
      locals: {
        blocks: blocks,
        first_invalid: ChainValidator.first_invalid_position(blocks),
        pending: pending
      }
    )
  end
end
