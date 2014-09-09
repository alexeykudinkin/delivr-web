require 'test_helper'

class TravelTest < ActiveSupport::TestCase

  test "origin properly set" do
    assert_equal @travels[:_1][:origin], @travels[:_1][:this].origin
  end

  test "performer properly set" do
    assert_equal @travels[:_1][:performer], @travels[:_1][:this].performer
  end

  test "customer properly set" do
    assert_equal @travels[:_1][:customer], @travels[:_1][:this].customer
  end

  test "state-log initialized and state properly set" do
    travel = Travels::Travel.create!(@travels[:_1].except(:this))

    assert travel.log.count == 1

    # Following are equal
    assert travel.state.is_a?(Travels::States::Submitted)
    assert travel.submitted?
  end

  test "stress test scope harness" do
    travel = Travels::Travel.create!(@travels[:_1].except(:this))

    assert        Travels::Travel.submitted.count == 1
    assert_equal  Travels::Travel.submitted.first, travel

    travel.log << Travels::States::Taken.new

    assert travel.log.count == 2

    assert        Travels::Travel.submitted.count == 0
    assert        Travels::Travel.taken.count     == 1
    assert_equal  Travels::Travel.taken.first, travel
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
