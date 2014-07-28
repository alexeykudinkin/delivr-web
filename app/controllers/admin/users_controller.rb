class Admin::UsersController < ApplicationController

  def new
    @user = Users::User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    attrs = whitelist(params, :create)
    attrs[:role] = Users::Roles::Role.as(attrs[:role])

    @user = Users::User.new(attrs)

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_path(@user) }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { redirect_to new_user_path, alert: "Failed to create the user! Errors: #{@user.errors.full_messages}" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # def show
  #   @user = Users::User.find(whitelist(params, :show))
  #
  #   respond_to do |format|
  #     format.html # show.html.erb
  #   end
  # end
  #
  # def adopt
  #   adopters = Users::Adopter.where(email: whitelist(params, :adopt)[:input])
  #
  #   respond_to do |format|
  #     format.js { render json: adopters, status: :ok }
  #   end && return unless adopters.blank?
  #
  #   adopter = Users::Adopter.new(whitelist(params, :adopt))
  #
  #   respond_to do |format|
  #     if adopter.save
  #       format.js { render json: [ adopter ], status: :created }
  #     else
  #       format.js { render json: adopter.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  private

    def whitelist(params, action)
      case action
        when :create
          params.require(:user)
                .permit(
                  :name,
                  :phone,
                  :email,
                  :password,
                  :password_confirmation,
                  :role
                )

        # when :show
        #   params.require(:id)
        #
        # when :adopt
        #   params.require(:adopter)
        #         .permit(:email)

        else
          raise "Couldn't whitelist unknown action!"
      end
    end

end
