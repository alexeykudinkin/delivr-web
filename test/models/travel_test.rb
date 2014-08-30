require 'test_helper'

class TravelTest < ActiveSupport::TestCase

  test "test origin properly set" do
    assert_equal @travels[:_1][:origin], @travels[:_1][:this].origin
  end

  test "test performer properly set" do
    assert_equal @travels[:_1][:performer], @travels[:_1][:this].performer
  end

  test "test customer properly set" do
    assert_equal @travels[:_1][:customer], @travels[:_1][:this].customer
  end

  protected

    def setup
      super

      @travels = {
        _1: {
          this:       travels_travels(:_1),

          origin:     travels_places_places(:UNI7911) .becomes(Travels::Places::Origin),
          performer:  users_users(:akudinkin)         .becomes(Users::Performer),
          customer:   users_users(:mkrinkin)          .becomes(Users::Customer)
        }
      }

    end

end
