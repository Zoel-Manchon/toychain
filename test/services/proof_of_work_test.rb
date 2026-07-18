require "test_helper"

class ProofOfWorkTest < ActiveSupport::TestCase
  test "mine returns a hash meeting the difficulty target" do
    result = ProofOfWork.mine(block_index: 1, data: "hello", previous_hash: "0" * 64)

    assert result[:block_hash].start_with?("0" * ProofOfWork::DIFFICULTY)
    assert result[:nonce] >= 0
  end

  test "compute is deterministic" do
    a = ProofOfWork.compute(1, "hello", "abc", 42)
    b = ProofOfWork.compute(1, "hello", "abc", 42)

    assert_equal a, b
  end

  test "changing any input changes the hash" do
    base = ProofOfWork.compute(1, "hello", "abc", 42)

    refute_equal base, ProofOfWork.compute(2, "hello", "abc", 42)
    refute_equal base, ProofOfWork.compute(1, "hello!", "abc", 42)
    refute_equal base, ProofOfWork.compute(1, "hello", "abd", 42)
    refute_equal base, ProofOfWork.compute(1, "hello", "abc", 43)
  end

  test "mined result verifies against compute" do
    result = ProofOfWork.mine(block_index: 7, data: "payload", previous_hash: "f" * 64)

    assert_equal result[:block_hash],
                 ProofOfWork.compute(7, "payload", "f" * 64, result[:nonce])
  end
end
