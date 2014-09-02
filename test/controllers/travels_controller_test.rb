require 'test_helper'
require 'controllers/controller_test_base'

class TravelsControllerTest < ControllerTestBase

  test "should show travel status" do
    get :status,
        {
          id: @_1.id
        },
        session(:alex)

    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  protected

    def setup
      super
      @_1 = travels_travels(:_1)
    end

end
