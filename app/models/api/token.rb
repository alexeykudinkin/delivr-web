
module Api

  extend Common::ForceConventionalNaming

  class Token < ActiveRecord::Base

    module GeneratorMethods
      extend ActiveSupport::Concern

      TOKEN_LENGTH = 32

      def generate
        begin
          val = SecureRandom.hex(TOKEN_LENGTH)
        end while self.class.exists? value: val

        self.value = val
      end
    end

    include GeneratorMethods


    # NOTE:
    #   DO NOT replace this with `before_save` since it is cascading through
    #   parental objects right into this one causing it to be saved while it
    #   shouldn't be

    before_create :generate

    belongs_to  :owner,
                :class_name  => "Users::Performer",
                :inverse_of  => :token

  end

end