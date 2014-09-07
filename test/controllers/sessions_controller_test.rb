require 'test_helper'
require 'controllers/controller_test_base'

class SessionsControllerTest < ControllerTestBase

  ROOTS = {
    alice: {
      phone:    "1234567890",
      email:    "alice@ali.ce",
      password: "qwerty"
    }
  }

  test "should authorize" do

    Users::User.create!({
      name:   "Alice",
      phone:  ROOTS[:alice][:phone],
      email:  ROOTS[:alice][:email],

      role:  Users::Roles::Role.as(:customer),

      password:               ROOTS[:alice][:password],
      password_confirmation:  ROOTS[:alice][:password]
    })

    post  :create,
          {
            phone:    ROOTS[:alice][:phone],
            password: ROOTS[:alice][:password]
          }

    assert_response 302
  end

  protected

    def setup
      super

      @akudinkin = users_users(:akudinkin)
    end

end
