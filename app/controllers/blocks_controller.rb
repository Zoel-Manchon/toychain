class BlocksController < ApplicationController
  def index
    @blocks = Block.all
    @chain_valid = ChainValidator.valid?(@blocks)
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
