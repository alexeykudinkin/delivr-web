module Users

  class Adopter < ActiveRecord::Base

    validates :email, presence: { allow_blank: false },
                      format:   { with: /\A([^@\s])@((?:[-a-z0-9]+\\.)[a-z]{2,})\Z/i, on: :save }

  end

end