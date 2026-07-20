require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "shows the registration form to anonymous visitors" do
    get new_registration_url
    assert_response :success
  end

  test "registers an operator and signs them in" do
    assert_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: "new-op@toychain.dev",
          password: "a-strong-passphrase",
          password_confirmation: "a-strong-passphrase"
        }
      }
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_response :success   # ya autenticado: la cadena carga
  end

  test "rejects mismatched password confirmation" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: "bad@toychain.dev",
          password: "a-strong-passphrase",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "rejects duplicate email" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: users(:zoel).email_address,
          password: "a-strong-passphrase",
          password_confirmation: "a-strong-passphrase"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
