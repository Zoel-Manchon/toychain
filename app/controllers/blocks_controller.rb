class BlocksController < ApplicationController
  def index
    @blocks = Block.all
    @first_invalid = ChainValidator.first_invalid_position(@blocks)
    @chain_valid = @first_invalid.nil?
  end

  def new
    @block = Block.new
  end

  def create
    @block = Block.new(data: block_params[:data])

    if @block.data.blank?
      @block.validate
      render :new, status: :unprocessable_entity
    else
      MineBlockJob.perform_later(@block.data)
      redirect_to blocks_path, notice: "⛏ Mining queued — refresh in a moment to see your block."
    end
  end

  def tamper
    block = Block.find(params[:id])
    block.update!(data: "#{block.data} ⚠ TAMPERED")
    redirect_to blocks_path, alert: "Block ##{block.block_index} tampered — integrity broken downstream."
  end

  def reset
    Block.delete_all
    redirect_to blocks_path, notice: "Chain reset — genesis awaits."
  end

  private

  def block_params
    params.expect(block: [ :data ])
  end
end
