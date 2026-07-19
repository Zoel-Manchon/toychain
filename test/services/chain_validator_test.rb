require "test_helper"

class ChainValidatorTest < ActiveSupport::TestCase
  FakeBlock = Struct.new(:block_index, :data, :previous_hash, :block_hash, :nonce, :difficulty, keyword_init: true)

  def mined_block(block_index:, data:, previous_hash:, difficulty: 4)
    result = ProofOfWork.mine(block_index: block_index, data: data, previous_hash: previous_hash, difficulty: difficulty)
    FakeBlock.new(
      block_index: block_index,
      data: data,
      previous_hash: previous_hash,
      block_hash: result[:block_hash],
      nonce: result[:nonce],
      difficulty: difficulty
    )
  end

  def valid_chain(length)
    chain = []
    previous_hash = "0" * 64
    length.times do |i|
      block = mined_block(block_index: i + 1, data: "block #{i + 1}", previous_hash: previous_hash)
      chain << block
      previous_hash = block.block_hash
    end
    chain
  end

  test "an empty chain is valid" do
    assert ChainValidator.valid?([])
  end

  test "a single-block chain is valid" do
    assert ChainValidator.valid?(valid_chain(1))
  end

  test "a properly mined chain is valid" do
    assert ChainValidator.valid?(valid_chain(3))
  end

  test "tampering with a block's data invalidates the chain" do
    chain = valid_chain(3)
    chain[1].data = "tampered!"

    refute ChainValidator.valid?(chain)
  end

  test "a broken link invalidates the chain" do
    chain = valid_chain(3)
    chain[2].previous_hash = "f" * 64

    refute ChainValidator.valid?(chain)
  end

  test "first_invalid_position returns nil for a valid chain" do
    assert_nil ChainValidator.first_invalid_position(valid_chain(3))
  end

  test "first_invalid_position points at the tampered block" do
    chain = valid_chain(3)
    chain[1].data = "tampered!"

    assert_equal 1, ChainValidator.first_invalid_position(chain)
  end

  test "a block claiming more difficulty than its hash shows is invalid" do
    chain = valid_chain(2)
    chain[1].difficulty = 60

    refute ChainValidator.valid?(chain)
  end
end
