module Travels
  module Places

    extend Common::ForceConventionalNaming

    class  Destination < Place

      # Travel pertaining to
      # NOTE: No, there is no (more) elegant way of doing "this" (building (one-to-one)
      # through- association through (one-to-many) one)

      def travel
        items.first.travel
      end

      # Items pertaining

      has_many  :items,
                :class_name => "Item",
                :inverse_of => :destination
                # :autosave   => true

      # @DEPRECATED
      #
      # Accepting nested attributes for items would trigger :autosave options causing stack overflow
      # in particular scenarios (for instance, creating new destination would save `Item`s bound , entailing save of a
      # parent (`Travel`) model, which in turn would go all the way down triggering save of an `Item`s belong with its ultimate
      # `Destination` due to :autosave option established)

      # accepts_nested_attributes_for :items,
      #                               :reject_if => lambda { |item| item[:name].blank?    ||
      #                                                             item[:weight].blank? }


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

      validates_length_of :items, minimum: 1

    end

  end
end

