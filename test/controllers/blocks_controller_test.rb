require "test_helper"

class BlocksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get blocks_url
    assert_response :success
  end

  test "should get new" do
    get new_block_url
    assert_response :success
  end

  test "should mine a block on create" do
    assert_difference("Block.count") do
      post blocks_url, params: { block: { data: "test payload" } }
    end

    block = Block.order(:block_index).last
    assert_equal "test payload", block.data
    assert block.block_hash.start_with?("0" * ProofOfWork::DIFFICULTY)
    assert_redirected_to blocks_url
  end

  test "should not create block without data" do
    assert_no_difference("Block.count") do
      post blocks_url, params: { block: { data: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "mined blocks form a valid chain" do
    post blocks_url, params: { block: { data: "first" } }
    post blocks_url, params: { block: { data: "second" } }

    assert ChainValidator.valid?(Block.all)
  end
end
