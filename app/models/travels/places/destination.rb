module Travels
  module Places

    extend Common::ForceConventionalNaming

    class Destination < Place

      has_one   :travel,
                :class_name => Travels::Travel,
                :inverse_of => :destination

    end

  end
end

