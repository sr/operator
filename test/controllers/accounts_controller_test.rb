require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:accounts)
  end
end
