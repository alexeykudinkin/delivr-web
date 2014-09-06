module Users

  extend Common::ForceConventionalNaming

  module Roles

    protected

      class Role < ActiveRecord::Base

        class << self;
          def as(type)
            type = type.to_s
            unless type.start_with? "Users::Roles::"
              type = "Users::Roles::#{type.capitalize}"
            end
            find_by(type: type)
          end
        end

        has_many :accounts,
                 :class_name => Users::User,
                 :inverse_of => :role

      end

  end

end
