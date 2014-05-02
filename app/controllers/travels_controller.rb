class TravelsController < ApplicationController

  #
  # TODO: CHOKE UP THIS BREACH ASAP
  #
  skip_before_action :verify_authenticity_token, only: [ :take ]


  require_login :show, :index, :new, :create, :take

  # Request map as a workplace
  requires_map


  # GET /travels/:id
  def show
    @travel = Travels::Travel.find(whitelist(params, :show))

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @travel, status: 200 }
    end
  end

  # GET /travels
  def index
    sanitized = whitelist(params, :index)

    # Extract travels
    if sanitized[:user_id]
      # As to Rails 4 doesn't have support for OR operator
      @travels = Travels::Travel.submitted.where("customer_id = ? OR performer_id = ?", sanitized[:user_id], sanitized[:user_id])
    else
      @travels = Travels::Travel.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { as_json @travels }
    end
  end

  # GET /travels/taken
  def taken
    @travels = Travels::Travel.taken.where(performer: current_user)

    respond_to do |format|
      format.html
      format.json { as_json @travels }
    end
  end


  # GET /travels/active
  def active
    @travels = Travels::Travel.submitted

    respond_to do |format|
      format.html
      format.json { as_json @travels }
    end
  end

  # GET /travels/created
  def created
    @travels = Travels::Travel.of(current_user)

    respond_to do |format|
      format.html
      format.json { as_json @travels }
    end
  end

  # GET /travels/new
  def new
    @travel = Travels::Travel.new

    respond_to do |format|
      format.html # new.html.rb
    end
  end

  # POST /travels
  def create
    @travel =
      Travels::Travel.new(
        whitelist(params, :create).merge customer: current_user.becomes(Users::Customer)
      )

    respond_to do |format|
      if @travel.save
        format.html { redirect_to travel_path(@travel), notice: "Gracefully created the travel!" }
        format.json { render json: @travel, status: :created, location: @travel }
      else
        format.html { redirect_to new_travel_path, alert: "Failed to create the travel!" }
        format.json { render json: @travel.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /travels/:id/take
  def take
    sanitized = whitelist(params, :take)
    travel = Travels::Travel.find(sanitized[:id])

    if travel.state.taken?
      respond_to do |format|
        format.html { redirect_to travel_path(travel), status: :bad_request, notice: "Unfortunately, travel's been already taken!" }
        format.json { redirect_to travel_path(travel), status: :bad_request }
      end
    else
      performer = Users::Performer.find(sanitized[:performer])

      travel.performer = performer
      travel.notify(:taken)

      respond_to do |format|
        if travel.save
          format.html { redirect_to travel_path(travel), notice: "You've successfully taken the travel!"  }
          format.json { render json: @travel, status: :ok, location: @travel }
        else
          raise
        end
      end
    end
  end

  private

    def whitelist(params, action)
      case action
        when :show
          params.require(:id)

        when :index
          params.permit(:user_id)

        when :create
          params.require(:travel)
                .permit(
                  { origin_attributes:      [ :address, :coordinates ] },
                  { destination_attributes: [ :address, :coordinates ] },
                  { items_attributes:       [ :name, :description, :weight ] }
                )

        when :take
          {
            id:         params.require(:id),
            performer:  current_user.id
          }

        else
          raise "Couldn't whitelist unknown action!"
      end
    end


    # JSON APIs helpers

    module JSONHelpers

      def as_json(travels)
        render  json: travels,
                status: 200,
                include: {
                  origin:       { only: [ :id, :address, :coordinates ],  except: [ :updated_at, :created_at ] },
                  destination:  { only: [ :id, :address, :coordinates ],  except: [ :updated_at, :created_at ] },
                  customer:     { only: [ :id, :name ],                   except: [ :phone, :password_digest ] },
                  performer:    { only: [ :id, :name ],                   except: [ :phone, :password_digest ] }
                },
                only:   [ :id ],
                except: [ :created_at, :updated_at ]
      end

    end

    include JSONHelpers

end
