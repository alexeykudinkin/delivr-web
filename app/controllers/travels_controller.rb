class TravelsController < ApplicationController

  def show
    @travel = Travel.find(whitelist(params, :show))

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @travel, status: 200 }
    end
  end

  # GET /travels/new
  def new
    @travel = Travel.new

    respond_to do |format|
      format.html # new.html.rb
    end
  end

  # POST /travels
  def create
    @travel = Travel.new(whitelist(params, :create))

    respond_to do |format|
      if @travel.save
        format.html { redirect_to travel_path(@travel), notice: 'Gracefully created!' }
        format.json { render json: @travel, status: :created, location: @travel }
      else
        raise "Fuck you!"
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
                  :origin,
                  :destination,
                  { items_attributes: [ :name, :description, :weight ] }
                )
        else
          raise "Couldn't whitelist unknown action!"
      end
    end
end
