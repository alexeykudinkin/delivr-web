class SessionsController < ApplicationController

  protect_from_forgery except: :create

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

      respond_to do |format|
        format.html { redirect_to user_path(user), status: 302, notice: "Successfully logged in!" }
        format.json { redirect_to user_path(user), status: 302 }
      end
    else
      respond_to do |format|
        format.html { redirect_to login_path, status: 401, alert: "Invalid phone or password!" }
        format.json { redirect_to login_path, status: 401 }
      end
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