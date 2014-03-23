class SessionsController < ApplicationController

  requires_map


  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    sanitized = whitelist(params, :new)

    user = Users::User.find_by(phone: sanitized[:phone])

    if user && user.authenticate(sanitized[:password])
      session[:user] = user.id
      redirect_to user_path(user), notice: "Successfully logged in!"
    else
      redirect_to login_path, alert: "Invalid phone or password!"
    end
  end

  def destroy
    session[:user] = nil
    redirect_to login_path, alert: "Successfully logged out!"
  end

  private

    def whitelist(params, action)
      case action
        when :new
          {
            phone:    params.require(:phone),
            password: params.require(:password)
          }
        else
          raise "Couldn't whitelist unknown action!"
      end
    end

end