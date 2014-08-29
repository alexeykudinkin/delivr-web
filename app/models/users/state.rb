module Users

  extend Common::ForceConventionalNaming

  class State < ActiveRecord::Base

    STATES  = [ :active, :inactive ]

    self.table_name = "user_states"

    # Plunges helpers of use inside class possessing state
    module ExportMethods
      extend ActiveSupport::Concern

      included do
        STATES.each do |state|
          class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def #{state.to_s}?
              state.send(:#{state}?)
            end

            def #{state.to_s}!
              s = self.build_state(status: "#{state.to_s}")
              s.save
              s
            end
          RUBY_EVAL
        end
      end
    end


    module Helpers
      extend ActiveSupport::Concern

      included do
        STATES.each do |state|
          class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def #{state.to_s}?
              self.status == :#{state}
            end
          RUBY_EVAL
        end
      end
    end

    include Helpers


    belongs_to :user,
               :class_name => Users::User,
               :inverse_of => :state

    def to_s
      self.status
    end
  end

end
