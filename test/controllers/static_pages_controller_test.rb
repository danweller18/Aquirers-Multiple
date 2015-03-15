require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "Aquirer's Multiple App"
  end

  test "should get stocks" do
    get :stocks
    assert_response :success
    assert_select "title", "Stocks | Aquirer's Multiple App"
  end

  test "should get about" do
    get :about
    assert_response :success
    assert_select "title", "About | Aquirer's Multiple App"
  end
end
