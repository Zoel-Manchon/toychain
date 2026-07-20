require "test_helper"

class Api::V1::ChainControllerTest < ActionDispatch::IntegrationTest
  test "returns 401 without a token" do
    get api_v1_chain_url
    assert_response :unauthorized
  end

  test "returns 401 with an invalid token" do
    get api_v1_chain_url, headers: { "Authorization" => "Bearer tc_invalid" }
    assert_response :unauthorized
  end

  test "returns the chain as JSON with a valid bearer token" do
    MineBlockJob.perform_now("api block", 2, users(:zoel).id)
    token = users(:zoel).api_tokens.create!(name: "test")

    get api_v1_chain_url, headers: { "Authorization" => "Bearer #{token.raw_token}" }
    assert_response :success

    body = JSON.parse(response.body)
    assert body["valid"]
    assert_equal 1, body["length"]
    assert_equal "api block", body["blocks"].first["data"]
    assert_equal users(:zoel).email_address, body["blocks"].first["mined_by"]
    assert body["blocks"].first["hash"].start_with?("00")
  end

  test "using a token records last_used_at" do
    token = users(:zoel).api_tokens.create!(name: "audit")

    assert_changes -> { token.reload.last_used_at } do
      get api_v1_chain_url, headers: { "Authorization" => "Bearer #{token.raw_token}" }
    end
  end
end
