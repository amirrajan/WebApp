require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get Index" do
    get welcome_Index_url
    assert_response :success
  end

end
