module Travels
  module Places

    extend Common::ForceConventionalNaming

    class  Destination < Place

      # Items pertaining

      has_many :items,
               :class_name  => Item,
               :inverse_of  => :destination

      accepts_nested_attributes_for :items,
                                    :reject_if => lambda { |item| item[:name].blank?    ||
                                                                  item[:weight].blank? }

      def self.new(attrs = nil)
        super
      end


      # Due dates

      has_one :due_date,
              :class_name => DueDate,
              :inverse_of => :destination

      accepts_nested_attributes_for :due_date,
                                    :reject_if => lambda { |dd| dd[:starts].blank? || dd[:ends].blank? }

      # Validations

      validates :due_date, :presence => true

      #
      # NOTE: This validations related with items are disabled to prevent
      #       circular validation-chain-dependencies preventing instances of this (and related) model
      #       to be persisted
      #

      # validates :items, :presence => true

    end

  end
end

