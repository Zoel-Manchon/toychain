require "test_helper"

class Api::V1::ChainControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get api_v1_chain_url
    assert_redirected_to new_session_url
  end

  test "returns the chain as JSON when signed in" do
    MineBlockJob.perform_now("api block", 2)
    sign_in_as users(:zoel)

    get api_v1_chain_url
    assert_response :success

    body = JSON.parse(response.body)
    assert body["valid"]
    assert_equal 1, body["length"]
    assert_equal "api block", body["blocks"].first["data"]
    assert body["blocks"].first["hash"].start_with?("00")
  end
end
