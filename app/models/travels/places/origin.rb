module Travels
  module Places

    extend Common::ForceConventionalNaming

    class Origin < Place

      has_one   :travel,
                :class_name => Travels::Travel,
                :inverse_of => :origin

    end

  end
end
