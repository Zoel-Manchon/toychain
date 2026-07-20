require "test_helper"
require "turbo/broadcastable/test_helper"

class MineBlockJobTest < ActiveJob::TestCase
  include Turbo::Broadcastable::TestHelper

  test "mines a valid block and broadcasts the chain" do
    assert_turbo_stream_broadcasts("chain") do
      MineBlockJob.perform_now("hello")
    end

    block = Block.last
    assert_equal "hello", block.data
    assert block.block_hash.start_with?("0" * ProofOfWork::DIFFICULTY)
  end

  test "mines at the requested difficulty and records timing" do
    MineBlockJob.perform_now("hard one", 5)

    block = Block.last
    assert_equal 5, block.difficulty
    assert block.block_hash.start_with?("00000")
    assert block.mined_ms >= 0
  end

  test "records the mining operator when given a user id" do
    MineBlockJob.perform_now("authored", 2, users(:zoel).id)

    assert_equal users(:zoel), Block.last.user
  end
end
