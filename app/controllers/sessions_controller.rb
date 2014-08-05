class SessionsController < ApplicationController

  protect_from_forgery except: :create

  # Request map as a workplace
  requires_map


  def new
    respond_to do |format|
      format.html do
        if logged_in?
          redirect_to user_path(current_user)
        else
          render # new.html.erb
        end
      end
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
        format.html { redirect_to login_path, :alert => if user.blank?
                                                                       "No user found!"
                                                                     else
                                                                       "Invalid phone or password!"
                                                                     end }
        format.json { redirect_to login_path }
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
          raise "Unknown action: #{action}!"
      end
    end

end