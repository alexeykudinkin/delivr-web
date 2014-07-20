module Travels
  module Places

    extend Common::ForceConventionalNaming

    class  Destination < Place

      has_many :items,
               :class_name  => Item,
               :inverse_of  => :destination

      accepts_nested_attributes_for :items,
                                    :reject_if => lambda { |item| item[:name].blank?    ||
                                                                  item[:weight].blank? }

      def self.new(attrs = nil)
        super
      end

      # Validations

      #
      # NOTE: Those validations related with items are disabled to prevent
      #       circular validation-chain-dependencies preventing instances of this (and related) model
      #       to be persisted
      #

      # validates :items, :presence => true

    end

  end
end

