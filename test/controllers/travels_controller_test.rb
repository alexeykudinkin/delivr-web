require 'test_helper'
require 'controllers/controller_test_base'

class TravelsControllerTest < ControllerTestBase

  # Checks all GETs are reachable

  test "should GETs actions [JSON/HTML]" do

    assert_no_difference("Travels::Travel.count") do
      get :new, {}, session(:akudinkin)
    end

    assert_response :success
    assert_template :new

    assert_not_nil  assigns(:travel)


    [ :status ].each do |action|
      assert_no_difference("Travels::Travel.count") do
        get action, { id: @travel }, session(:akudinkin)
      end
    end

    assert_response :success
    assert_template :status

    assert_not_nil  assigns(:travel)


    [ :taken, :active, :created ].each do |action|
      assert_no_difference("Travels::Travel.count") do
        get action, {}, session(:akudinkin)
      end

      assert_response :success
      assert_template :index

      assert_not_nil  assigns(:travels)
    end

  end

  # POSTs/PATCHs/DELETEs/...

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

  test "should take travel" do
    request_json
    authorize_api_access :akudinkin

    post :take,
         {
           id: @travel.id
         }

    assert_response :success
  end

  test "should NOT cancel travel" do
    request_json
    authorize_api_access :akudinkin

    prev = @travel.state

    post :cancel,
         {
           id: @travel.id
         }

    assert_response :bad_request

    @travel = @travel.reload

    assert_not @travel.cancelled?

    assert_equal @travel.state, prev
  end

  test "should cancel travel" do
    request_json
    authorize_api_access :akudinkin

    @travel.customer = @akudinkin.becomes(Users::Customer)
    @travel.save!

    post :cancel,
         {
           id: @travel.id
         }

    assert_response :success

    @travel = @travel.reload

    # FIXME:  This is deferred bug of test failing during `rake test`
    #         but passing `rake test test/travels_controller_test`
    #
    #         ¯\_(ツ)_/¯

    # puts @travel.state_id
    # raise 'F*CK'

    assert @travel.cancelled?
  end

  test "should NOT complete travel" do

    request_json
    authorize_api_access :akudinkin

    prev = @travel.state

    post :complete,
         {
           id: @travel.id
         }

    assert_response :bad_request

    @travel = @travel.reload

    assert_not @travel.completed?

    assert_equal @travel.state, prev
  end

  test "should complete travel" do
    request_json
    authorize_api_access :akudinkin

    p = @akudinkin.becomes(Users::Performer)

    @travel.take(p)
    @travel.save!

    post :complete,
         {
           id: @travel.id
         }

    assert_response :success

    @travel = @travel.reload

    assert @travel.completed?
  end

  test "should show travel status" do
    get :status,
        {
          id: @travel.id
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

      @travel     = travels_travels(:_1)
      @akudinkin  = users_users(:akudinkin)
    end

end
