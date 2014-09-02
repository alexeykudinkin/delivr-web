module Communication

  include Common::ForceConventionalNaming

  module Push

    class Subscription < ActiveRecord::Base

      belongs_to  :performer,
                  :class_name   => "Users::Performer", # break circular dependencies
                  :inverse_of   => :subscription

    end

  end

end
