
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

  protected

    def setup
      super
      @travel = travels_travels(:_1)
    end

end