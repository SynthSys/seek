require 'test_helper'

class DsPacksControllerTest < ActionController::TestCase

  test "should get new" do
    get :new
    puts response
    puts response.location

    assert_template :new
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

end
