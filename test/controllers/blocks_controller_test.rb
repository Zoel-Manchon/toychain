require "test_helper"

class BlocksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should get index" do
    get blocks_url
    assert_response :success
  end

  test "should get new" do
    get new_block_url
    assert_response :success
  end

  test "create enqueues a mining job" do
    assert_enqueued_with(job: MineBlockJob, args: [ "hello" ]) do
      post blocks_url, params: { block: { data: "hello" } }
    end
  end

  test "should mine a block on create" do
    assert_difference("Block.count") do
      perform_enqueued_jobs do
        post blocks_url, params: { block: { data: "test payload" } }
      end
    end

    block = Block.order(:block_index).last
    assert_equal "test payload", block.data
    assert block.block_hash.start_with?("0" * ProofOfWork::DIFFICULTY)
  end

  test "should not enqueue a job without data" do
    assert_no_enqueued_jobs do
      post blocks_url, params: { block: { data: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "mined blocks form a valid chain" do
    perform_enqueued_jobs do
      post blocks_url, params: { block: { data: "first" } }
      post blocks_url, params: { block: { data: "second" } }
    end

    assert ChainValidator.valid?(Block.all)
  end

  test "tampering a block corrupts the chain" do
    perform_enqueued_jobs do
      post blocks_url, params: { block: { data: "first" } }
      post blocks_url, params: { block: { data: "second" } }
    end
    victim = Block.first

    post tamper_block_url(victim)

    refute ChainValidator.valid?(Block.all)
    assert_redirected_to blocks_url
  end

  test "reset wipes the chain" do
    perform_enqueued_jobs do
      post blocks_url, params: { block: { data: "doomed" } }
    end

    assert_difference("Block.count", -1) do
      delete reset_blocks_url
    end
    assert_redirected_to blocks_url
  end
end
