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
    assert_enqueued_with(job: MineBlockJob, args: [ "hello", 4 ]) do
      post blocks_url, params: { block: { data: "hello", difficulty: 4 } }
    end
  end

  test "difficulty is clamped to the allowed range" do
    assert_enqueued_with(job: MineBlockJob, args: [ "sneaky", 6 ]) do
      post blocks_url, params: { block: { data: "sneaky", difficulty: 99 } }
    end
  end

  test "missing difficulty falls back to the minimum" do
    assert_enqueued_with(job: MineBlockJob, args: [ "plain", 2 ]) do
      post blocks_url, params: { block: { data: "plain" } }
    end
  end

  test "should mine a block on create" do
    assert_difference("Block.count") do
      perform_enqueued_jobs do
        post blocks_url, params: { block: { data: "test payload", difficulty: 4 } }
      end
    end

    block = Block.order(:block_index).last
    assert_equal "test payload", block.data
    assert block.block_hash.start_with?("0" * 4)
  end

  test "should not enqueue a job without data" do
    assert_no_enqueued_jobs do
      post blocks_url, params: { block: { data: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "mined blocks form a valid chain" do
    perform_enqueued_jobs do
      post blocks_url, params: { block: { data: "first", difficulty: 2 } }
      post blocks_url, params: { block: { data: "second", difficulty: 2 } }
    end

    assert ChainValidator.valid?(Block.all)
  end

  test "tampering a block corrupts the chain" do
    perform_enqueued_jobs do
      post blocks_url, params: { block: { data: "first", difficulty: 2 } }
      post blocks_url, params: { block: { data: "second", difficulty: 2 } }
    end
    victim = Block.first

    post tamper_block_url(victim)

    refute ChainValidator.valid?(Block.all)
    assert_redirected_to blocks_url
  end

  test "reset wipes the chain" do
    perform_enqueued_jobs do
      post blocks_url, params: { block: { data: "doomed", difficulty: 2 } }
    end

    assert_difference("Block.count", -1) do
      delete reset_blocks_url
    end
    assert_redirected_to blocks_url
  end
end
