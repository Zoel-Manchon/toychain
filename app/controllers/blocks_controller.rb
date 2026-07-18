class BlocksController < ApplicationController
  def index
    @blocks = Block.all
    @first_invalid = ChainValidator.first_invalid_position(@blocks)
    @chain_valid = @first_invalid.nil?
  end

  def tamper
    block = Block.find(params[:id])
    block.update!(data: "#{block.data} ⚠ TAMPERED")
    redirect_to blocks_path, alert: "Block ##{block.block_index} tampered — integrity broken downstream."
  end

  def new
    @block = Block.new
  end

  def create
    result = ProofOfWork.mine(
      block_index: Block.next_index,
      data: block_params[:data],
      previous_hash: Block.latest_hash
    )

    @block = Block.new(
      block_index: Block.next_index,
      data: block_params[:data],
      previous_hash: Block.latest_hash,
      block_hash: result[:block_hash],
      nonce: result[:nonce],
      mined_at: Time.current
    )

    if @block.save
      redirect_to blocks_path, notice: "Block ##{@block.block_index} mined with nonce #{@block.nonce}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def block_params
    params.expect(block: [ :data ])
  end
end
