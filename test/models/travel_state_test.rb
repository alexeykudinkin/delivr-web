
require 'test_helper'

class TravelStateTest < ActiveSupport::TestCase

  test "should stress-test travel's state-log" do
    @travel.log << Travels::States::Submitted.new

    assert @travel.log.count == 1

    # Following are equal
    assert @travel.state.is_a?(Travels::States::Submitted)
    assert @travel.submitted?

    @travel.log << Travels::States::Taken.new

    assert @travel.log.count == 2

    # Following are equal
    assert @travel.state.is_a?(Travels::States::Taken)
    assert @travel.taken?

    @travel.log << Travels::States::Completed.new

    assert @travel.log.count == 3

    # Following are equal
    assert @travel.state.is_a?(Travels::States::Completed)
    assert @travel.completed?

    #
    # FIXME:
    #   Push additional tests validating transitions and preserved order
    #
  end

  test "should not allow CANCEL already TAKEN" do
    @travel.log << Travels::States::Submitted.new

    assert @travel.submitted?

    assert @travel.can_cancel?

    p = @akudinkin.becomes(Users::Performer)

    assert @travel.can_take?
    assert @travel.take(p)
    assert @travel.taken?

    assert_equal @travel.performer, p

    assert_not @travel.can_cancel?
  end

  test "should go through [ SUBMITTED, WITHDRAWN ] -> TAKEN and TAKEN -> WITHDRAWN" do
    @travel.log << Travels::States::Submitted.new

    assert @travel.submitted?

    p = @akudinkin.becomes(Users::Performer)

    assert @travel.can_take?
    assert @travel.take(p)
    assert @travel.taken?

    assert_equal @travel.performer, p

    assert @travel.can_withdraw?
    assert @travel.withdraw
    assert @travel.withdrawn?

    assert @travel.can_take?
    assert @travel.take(p)
    assert @travel.taken?

    assert_equal @travel.performer, p
  end

  test "should go through SUBMITTED -> CANCELED" do
    @travel.log << Travels::States::Submitted.new

    assert @travel.submitted?

    assert @travel.can_cancel?
    assert @travel.cancel
    assert @travel.canceled?
  end

  test "should go through TAKEN -> COMPLETED" do
    @travel.log << Travels::States::Submitted.new

    assert @travel.submitted?

    p = @akudinkin.becomes(Users::Performer)

    assert @travel.can_take?
    assert @travel.take(p)
    assert @travel.taken?

    assert_equal @travel.performer, p

    assert @travel.can_complete?
    assert @travel.complete
    assert @travel.completed?
  end

  protected

    def setup
      super

      @travel     = travels_travels(:_1)
      @akudinkin  = users_users(:akudinkin)
    end

end