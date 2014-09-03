
require 'test_helper'

class TravelStateTest < ActiveSupport::TestCase

  test "should check existing statuses" do
    Travels::State::STATES.each do |s|
      _1 = Travels::State.get(s.to_sym)
      _2 = Travels::State.get(s.to_sym)

      assert_equal _1, _2, "Gotcha! Those two should be equal!"
    end
  end

end