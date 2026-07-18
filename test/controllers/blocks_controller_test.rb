require "test_helper"

class BlocksControllerTest < ActionDispatch::IntegrationTest
  # ... tus tests existentes ...

  test "mined blocks form a valid chain" do
    post blocks_url, params: { block: { data: "first" } }
    post blocks_url, params: { block: { data: "second" } }

    assert ChainValidator.valid?(Block.all)
  end

  test "tampering a block corrupts the chain" do
    post blocks_url, params: { block: { data: "first" } }
    post blocks_url, params: { block: { data: "second" } }
    victim = Block.first

    post tamper_block_url(victim)

    refute ChainValidator.valid?(Block.all)
    assert_redirected_to blocks_url
  end

  test "reset wipes the chain" do
    post blocks_url, params: { block: { data: "doomed" } }

    assert_difference("Block.count", -1) do
      delete reset_blocks_url
    end
    assert_redirected_to blocks_url
  end
end
