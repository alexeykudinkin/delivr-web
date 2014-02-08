module Travels

  extend Common::ForceConventionalNaming

  class Travel < ActiveRecord::Base

    has_many    :items,
                :class_name   => Item,
                :inverse_of   => :travel,
                :autosave     => true

    accepts_nested_attributes_for :items,
                                  :reject_if => lambda { |item| item[:weight].blank?      ||
                                                                item[:name].blank?        &&
                                                                item[:description].blank?  }


    belongs_to  :origin,
                :class_name => Travels::Places::Origin,
                :inverse_of => :travel,
                :autosave   => true

    accepts_nested_attributes_for :origin,
                                  :reject_if => lambda { |place|  place[:address].blank?    ||
                                                                  place[:coordinates].blank? }

    belongs_to  :destination,
                :class_name => Travels::Places::Destination,
                :inverse_of => :travel,
                :autosave   => true

    accepts_nested_attributes_for :destination,
                                  :reject_if => lambda { |place|  place[:address].blank?    ||
                                                                  place[:coordinates].blank? }

    belongs_to  :customer,
                :class_name => Users::Customer,
                :inverse_of => :orders

    belongs_to  :performer,
                :class_name => Users::Performer,
                :inverse_of => :orders

  end

end