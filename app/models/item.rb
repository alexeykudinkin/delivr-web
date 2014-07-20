class Item < ActiveRecord::Base

  # Travel

  belongs_to :travel,
             :class_name => Travels::Travel,
             :inverse_of => :items

  # Destination

  belongs_to :destination,
             :class_name => "Travels::Places::Destination", # Breaking circular dependencies
             :inverse_of => :items

  accepts_nested_attributes_for :destination,
                                :reject_if => lambda { |place|  place[:address].blank?    ||
                                                                place[:coordinates].blank? }

  def self.new(attrs = nil)
      super
  end

  # Validations

  validates :destination, :presence => true
  validates :travel,      :presence => true

end
