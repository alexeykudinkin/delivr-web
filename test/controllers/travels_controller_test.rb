require 'test_helper'
require 'controllers/controller_test_base'

class TravelsControllerTest < ControllerTestBase

  test "should create travel [JSON]" do
    assert_difference "Travels::Travel.all.count", 1 do
      request_json
      post  :create,
            {
              travel: {
                origin_attributes: {
                  address:      "ul. Zemledelcheskaya 5k2",
                  coordinates:  "(50.6314, 63.3531)"
                },

                destinations_attributes: {

                  _1: {

                    address:      "ul. Universitetskaya 7-9-11",
                    coordinates:  "(50.9014, 63.5531)",

                    due_date_attributes: {
                      starts:     1.hour.from_now,
                      ends:       3.hour.from_now
                    },

                    items_attributes:       [ {
                      name:         "Bouquet 51",
                      description:  "Beautiful Tulips",
                      weight:       2.5
                    } ]
                  }

                },

                route_attributes: {
                  cost:     1000.rubles,
                  length:   15.kilo,
                  duration: 2.hour,
                  order:    "1",
                  polyline: "THEREWOULDBEAPOLYLINE"
                }
              }
            },
            session(:akudinkin)

      assert_response :created
    end
  end

  test "should show travel status" do
    get :status,
        {
          id: @_1.id
        },
        session(:akudinkin)

    assert_response :success
  end

  test "should get new" do
    get :new, {}, session(:akudinkin)

    assert_response :success
  end

  protected

    def setup
      super
      @_1 = travels_travels(:_1)
    end

end
