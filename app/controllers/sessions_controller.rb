#
# FIXME:  Move this into more generic `AccessController` right after
#         behaviour will be fixed with the unit-tests
#

class SessionsController < ApplicationController

  protect_from_forgery except: :create

  # FIXME: Move this right into views
  # Request map as a workplace
  requires_map


  #
  # Session-management interface
  #

  module Sessions
    def new
      respond_to do |format|
        format.html do
          if authenticated?
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
  end


  #
  # Token-management (REST API) interface
  #

  module Tokens
    # Grant access by supplying requester with the
    # access-token approved
    def grant
      sanitized = whitelist(params, :new)

      user = Users::User.find_by(phone: sanitized[:phone])

      if user && user.authenticate(sanitized[:password])
        unless token = Api::Token.find_by(owner: user)
          token = user.becomes(Users::Performer).create_token
        end

        respond_to do |format|
          format.html { as_json token }
          # format.json { as_json token }
        end
      end
    end

    # Revoke access-token approved earlier
    def revoke
      raise "Implement me!"
    end

    module JSONHelpers

      def as_json(token)
        render  json: { token: token.value, created: token.created_at },
                status: 200
      end
    end

    include JSONHelpers
  end

  # Enable proper sessions- and tokens- management

  include Sessions
  include Tokens


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