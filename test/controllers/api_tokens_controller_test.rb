require "test_helper"

class ApiTokensControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get api_tokens_url
    assert_redirected_to new_session_url
  end

  test "creates a token and shows it once" do
    sign_in_as users(:zoel)

    assert_difference("ApiToken.count") do
      post api_tokens_url, params: { api_token: { name: "ci-script" } }
    end

    assert_redirected_to api_tokens_url
    follow_redirect!
    assert_match(/tc_[0-9a-f]{40}/, response.body)
  end

  test "revokes a token" do
    sign_in_as users(:zoel)
    token = users(:zoel).api_tokens.create!(name: "doomed")

    assert_difference("ApiToken.count", -1) do
      delete api_token_url(token)
    end
  end

  test "cannot revoke another operator's token" do
    other_token = users(:two).api_tokens.create!(name: "not-yours")
    sign_in_as users(:zoel)

    assert_no_difference("ApiToken.count") do
      delete api_token_url(other_token)
    end
    assert_response :not_found
  end
end
