class TravelsController < ApplicationController

  #
  # TODO: CHOKE UP THIS BREACH ASAP
  #
  skip_before_action :verify_authenticity_token, only: [ :take ]


  restrict_access :show, :index, :new, :create, :take, :status, :active, :taken

  # Shows details travel
  #
  # GET /travels/:id
  def show
    @travel = Travels::Travel.find(whitelist(params, :show))

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @travel, status: 200 }
    end
  end

  # Lists all supplied travels
  #
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

  # Lists taken travels by this user
  #
  # GET /travels/taken
  def taken
    @travels = Travels::Travel.taken.where(performer: current_user)

    respond_to do |format|
      format.html { render "travels/index" }
      format.json { as_json @travels }
    end
  end

  # Lists active (non-completed) travels
  #
  # GET /travels/active
  def active
    @travels = Travels::Travel.actual

    respond_to do |format|
      format.html { render "travels/index" }
      format.json { as_json @travels }
    end
  end

  # Lists travels created by this user
  #
  # GET /travels/created
  def created
    @travels = Travels::Travel.of(current_user)

    respond_to do |format|
      format.html { render "travels/index" }
      format.json { as_json @travels }
    end
  end

  # Gets travel creation form
  #
  # GET /travels/new
  def new
    @travel = Travels::Travel.new

    respond_to do |format|
      format.html # new.html.rb
    end
  end

  # Creates new travel
  #
  # POST /travels
  def create
    attrs   = whitelist(params, :create).merge customer: current_user.becomes(Users::Customer)
    dattrs  = attrs.delete(:destinations_attributes)

    @travel = Travels::Travel.new(attrs)

    dattrs.each_key do |key|
      dattr   = dattrs[key]
      iattrs  = dattr.delete(:items_attributes)

      dest = Travels::Places::Destination.new(dattr)

      iattrs.each_key do |key|
        @travel.items.build(iattrs[key]).destination = dest
      end if iattrs
    end

    # @travel.customer = current_user.becomes(Users::Customer)

    respond_to do |format|
      if @travel.save
        format.html { redirect_to status_travel_path(@travel), notice: "Gracefully created the travel!" }
        format.json { render json: @travel, status: :created, location: @travel }
      else
        format.html { redirect_to new_travel_path, alert: "Failed to create the travel! Errors: #{@travel.errors.full_messages}" }
        format.json { render json: @travel.errors, status: :unprocessable_entity }
      end
    end
  end

  # Takes this travel
  #
  # POST /travels/:id/take
  def take
    sanitized = whitelist(params, :take)
    travel = Travels::Travel.find(sanitized[:id])

    if travel.taken?
      respond_to do |format|
        format.html { redirect_to travel_path(travel), status: :bad_request, notice: "Unfortunately, travel's been already taken!" }
        format.json { redirect_to travel_path(travel), status: :bad_request }
      end
    else
      performer = Users::Performer.find(sanitized[:performer])

      # travel.performer = performer
      # travel.notify(:taken)
      travel.take(performer)

      respond_to do |format|
        if travel.save
          # format.html { redirect_to travel_path(travel), notice: "You've successfully taken the travel!"  }
          format.html {  }
          format.json { render json: @travel, status: :ok, location: @travel }
        else
          raise
        end
      end
    end
  end

  # Completes travel
  #
  # POST /travels/:id/complete
  def complete
    sanitized = whitelist(params, :complete)
    travel = Travels::Travel.find(sanitized[:id])

    unless travel.taken? && travel.performer == current_user.becomes(Users::Performer)
      fail(:any, :bad_request, "Sorry! You're not eligible to complete un-taken travels!")
      return
    end

    respond_to do |format|
      if travel.complete
        format.html { redirect_to status_travel_path(travel) }
        format.json { render json: travel.as_json, status: :ok}
      else
        format.html { redirect_to status_travel_path(travel), alert: "Failed to complete! Errors: #{travel.errors.full_messages}" }
        format.json { render json: travel.as_json, status: :unprocessable_entity }
      end
    end
  end


  # Cancels travel
  #
  # POST /travels/:id/cancel
  def cancel
    sanitized = whitelist(params, :complete)
    travel = Travels::Travel.find(sanitized[:id])

    unless travel.submitted? && travel.customer == current_user.becomes(Users::Customer)
      fail(:any, :bad_request, "Sorry! You're not eligible to cancel travels other than just submitted!")
      return
    end

    respond_to do |format|
      if travel.cancel
        format.html { redirect_to status_travel_path(travel) }
        format.json { render json: travel.as_json, status: :ok }
      else
        format.html { redirect_to status_travel_path(travel), alert: "Failed to complete! Errors: #{travel.errors.full_messages}" }
        format.json { render json: travel.as_json, status: :unprocessable_entity }
      end
    end
  end

  # Queries status for the given travel
  #
  # GET travels/:id/status
  # GET travels/:id/status.json
  def status
    sanitized = whitelist(params, :status)

    @travel = Travels::Travel.find(sanitized[:id])

    respond_to do |format|
      format.html # status.html.erb
      format.json { render json: { status: @travel.state.to_s } }
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
                  { origin_attributes:        [ :address, :coordinates ] },
                  { destinations_attributes:
                      [ :address, :coordinates, {
                        due_date_attributes:  [ :starts, :ends ],
                        items_attributes:     [ :name, :description, :weight ]
                      } ]
                  },
                  { route_attributes:         [ :cost, :length, :duration, :order, :polyline ] }
                )

        when :take then {
            id:         params.require(:id),
            performer:  current_user.id
          }

        when :cancel then {
          id: params.require(:id)
        }

        when :complete then {
          id: params.require(:id)
        }

        when :status then {
            id: params.require(:id)
          }

        else
          raise "Unknown action: #{action}!"
      end
    end


    # JSON APIs helpers

    module JSONHelpers

      def as_json(travels)
        render  json: travels,
                status: 200,
                include: {

                  origin: {
                    only:   [ :id, :address, :coordinates ],
                    except: [ :updated_at, :created_at ]
                  },

                  destinations: {

                    include: {

                      due_date: {
                        methods:  [ :starts_m, :ends_m ],
                        only:     []
                      },

                      items: {
                        only:   [ :name, :weight, :description ],
                        except: [ :updated_at, :created_at ]
                      }

                    },

                    only:   [ :id, :address, :coordinates ],
                    except: [ :updated_at, :created_at ]
                  },

                  route: {
                    only:   [ :cost, :length, :duration, :order, :polyline ]
                  },

                  customer: {
                    only:   [ :id, :name ],
                    except: [ :phone, :password_digest ]
                  },

                  performer: {
                    only:   [ :id, :name ],
                    except: [ :phone, :password_digest ]
                  },

                },

                only:   [ :id ],
                except: [ :created_at, :updated_at ]
      end

    end

    include JSONHelpers

end
