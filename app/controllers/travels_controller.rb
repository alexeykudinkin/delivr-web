class TravelsController < ApplicationController

  require_login :show, :index, :new, :create, :take

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
    @travels = Travels::Travel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @travels, status: 200 }
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
    @travel = Travels::Travel.new(whitelist(params, :create))

    respond_to do |format|
      if @travel.save
        format.html { redirect_to travel_path(@travel), notice: 'Gracefully created!' }
        format.json { render json: @travel, status: :created, location: @travel }
      else
        format.html { render action: :new }
        format.json { render json: @travel.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /travels/:id/take
  def take
    sanitized = whitelist(params, :take)

    travel    = Travels::Travel.find(sanitized[:id])
    performer = Users::Performer.find(sanitized[:performer])

    travel.performer = performer

    respond_to do |format|
      if travel.save
        format.json { render json: @travel, status: :ok, location: @travel }
      else
        raise
      end
    end
  end

  private

    def whitelist(params, action)
      case action
        when :show
          params.require(:id)

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
            performer:  params.require(:performer)
          }

        else
          raise "Couldn't whitelist unknown action!"
      end
    end
end
