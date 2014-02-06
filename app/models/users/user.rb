module Users

  class User < ActiveRecord::Base

    # Basic authentication
    has_secure_password

  end

end