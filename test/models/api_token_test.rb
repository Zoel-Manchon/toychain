require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  test "generates a raw token and stores only its digest" do
    token = users(:zoel).api_tokens.create!(name: "t")

    assert token.raw_token.start_with?("tc_")
    assert_equal Digest::SHA256.hexdigest(token.raw_token), token.token_digest
    refute_equal token.raw_token, token.token_digest
  end

  test "authenticate finds by raw token" do
    token = users(:zoel).api_tokens.create!(name: "t")

    assert_equal token, ApiToken.authenticate(token.raw_token)
    assert_nil ApiToken.authenticate("tc_wrong")
    assert_nil ApiToken.authenticate(nil)
  end
end
