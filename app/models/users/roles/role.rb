module Users

  extend Common::ForceConventionalNaming

  module Roles

    protected

      class Role < ActiveRecord::Base

        class << self;
          def as(type)
            type = type
            unless type.start_with? "Users::Roles::"
              type = "Users::Roles::#{type}"
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
