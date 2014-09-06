
class ControllerTestBase < ActionController::TestCase

  module RequestHelpers

    extend ActiveSupport::Concern

    def json(user, &block)
      request_json
      authorize_api_access user

      block.call
    end

    def request_json
      @request.env["HTTP_ACCEPT"]   = "application/json"
      @request.env["CONTENT_TYPE"]  = "application/json"
    end

  end

  include RequestHelpers

  protected

    def setup
      @mkrinkin   = users_users(:mkrinkin)
      @akudinkin  = users_users(:akudinkin)
    end

    def session(user)
      case user
        when :mkrinkin
          { user: @mkrinkin.id }
        when :akudinkin
          { user: @akudinkin.id }
        else
          raise "Whom you're talking about?"
      end
    end


    def authorize_api_access(user)
      #
      # NOTE: Since token pertain to the `Performer`s only
      #       we need to convert user to `Performer` model in beforehand
      #
      case user
        when :mkrinkin
          user = @mkrinkin

        when :akudinkin
          user = @akudinkin

        else
          if user.nil?
            deauthorize_api_access
            return
          else
            raise "Whom you're talking about?"
          end
      end

      user = user.becomes(Users::Performer)
      user.create_token unless user.token

      authorize_api_access_with(user.token.value)
    end

  private

    X_AUTH_HEADER = "X_HTTP_AUTHORIZATION"

    def authorize_api_access_with(token)
      @request.env[X_AUTH_HEADER] = "Token token=#{token}"
    end

    def deauthorize_api_access
      @request.env.delete(X_AUTH_HEADER)
    end

    # def gregorian(*args)
    #   Date.new(*args, Date::GREGORIAN)
    # end

end