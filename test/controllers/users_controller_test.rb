require 'test_helper'
require 'controllers/controller_test_base'

class AdminUsersControllerTest < ControllerTestBase

  ROOTS = {
    alice: {
      phone:    "1234567890",
      email:    "alice@ali.ce",
      password: "qwerty"
    }
  }

  test "should not create user w/o password supplied" do
    assert_no_difference('Users::User.all.count') do
      post  :create, {
              user: {
                name:   "Alice",
                phone:  ROOTS[:alice][:phone],
                email:  ROOTS[:alice][:email],

                role:   Users::Roles::Role.as(:admin)
              }
            }

      assert_redirected_to controller: "admin/users", action: :new
    end
  end

  protected

    def setup
      super

      @controller = Admin::UsersController.new
    end

end
