
class ControllerTestBase < ActionController::TestCase

  protected

    def setup
      @mike = users_users(:mkrinkin)
      @alex = users_users(:akudinkin)
    end

    def session(user)
      case user
        when :mike
          { user: @mike.id }
        when :alex
          { user: @alex.id }
        else
          raise "Whom you're talking about?"
      end
    end

    def token(user)
      case user
        when :mike
          { user: @mike.id }
        when :alex
          { user: @alex.id }
        else
          raise "Whom you're talking about?"
      end
    end

    # def gregorian(*args)
    #   Date.new(*args, Date::GREGORIAN)
    # end

end