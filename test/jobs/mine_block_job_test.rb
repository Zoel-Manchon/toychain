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
end
