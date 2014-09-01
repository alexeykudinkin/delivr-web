require 'test_helper'
require 'controllers/controller_test_base'

class PlacesControllerTest < ControllerTestBase

  test "should report courier arrived at a place" do
    @travel.performer = @courier

    assert @travel.performer == @courier

    # We may not bind destination with the travel directly,
    # instead we should bind it through `Travel` <-> `Item`
    # association

    @destination.build_due_date({
      starts: 1.hour.from_now,
      ends:   3.hour.from_now
    })

    # NOTE: This directive isn't reciprocal, due to Rails (4.0.0) not
    #       supporting reciprocals through :has_many associations
    # @item.destination = @destination

    @destination.items  << @item
    @travel.items       << @item

    assert_equal  @destination.travel, @travel
    assert        @travel.destinations.count >= 1

    request_json
    authorize_api_access(:akudinkin)

    post :arrive,
         {
            travel_id:  @travel.id,
            id:         @destination.id,
         }

    assert_response :success

  end

  test "should not allow unauthorized courier arriving at a place" do

    request_json
    authorize_api_access(nil)

    post :arrive,
         {
           travel_id:  @travel.id,
           id:         @destination.id,
         }

    assert_response :unauthorized

  end

  protected

    def setup
      super

      @courier  = users_users(:akudinkin).becomes(Users::Performer)
      @travel   = travels_travels(:_1)

      @destination = travels_places_places(:ZML5K2).becomes(Travels::Places::Destination)

      @item = items(:roses)
    end

end