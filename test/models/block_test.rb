require "test_helper"

class BlockTest < ActiveSupport::TestCase
  test "requires data to be present" do
    block = Block.new(data: "")

    refute block.valid?
    assert_includes block.errors[:data], "can't be blank"
  end

  test "next_index starts at 1 on an empty chain" do
    assert_equal 1, Block.next_index
  end

  test "latest_hash returns genesis hash on an empty chain" do
    assert_equal Block::GENESIS_HASH, Block.latest_hash
  end
end
