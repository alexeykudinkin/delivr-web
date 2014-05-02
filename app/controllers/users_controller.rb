class UsersController < ApplicationController

  # Request map as a workplace
  requires_map


  def new
    @user = Users::User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @user = Users::User.new(whitelist(params, :create))

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_path(@user) }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @user = Users::User.find(whitelist(params, :show))

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  private

    def whitelist(params, action)
      case action
        when :create
          params.require(:user)
                .permit(
                  :name,
                  :phone,
                  :password,
                  :password_confirmation
                )
        when :show
          params.require(:id)
        else
          raise "Couldn't whitelist unknown action!"
      end
    end

end