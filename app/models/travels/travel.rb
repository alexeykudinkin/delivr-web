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

    has_one     :state,
                :class_name => State,
                :inverse_of => :travel,
                :autosave   => true

    # Include a handful of utility methods
    # short-circuiting state observation
    include Travels::State::ExportMethods


    belongs_to  :customer,
                :class_name => Users::Customer,
                :inverse_of => :orders


    belongs_to  :performer,
                :class_name => Users::Performer,
                :inverse_of => :orders

    def performer=(performer)
      super
      self.state = State::Instances.get(:taken)
    end


    # Notification system

    has_many    :notifications,
                :class_name => TravelNotification,
                :inverse_of => :travel

    def notify(status)
      case status
        when :taken
          self.notifications << TravelNotification.taken_by(performer)

        else raise "Unknown status!"
      end
    end


    # Initialization

    def self.new(attributes = nil)
      super (attributes || {}).merge({ state: State.new })
    end

    def self.create(attributes = nil, &block)
      super (attributes || {}).merge({ state: State.new }) do
        block
      end
    end


    # Scopes

    scope :of,        -> (owner) { where(customer: owner) }

    scope :submitted, -> { joins(:state).where(states: { completed: false, taken: false, withdrawn: false }) }

    scope :completed, -> { joins(:state).where(states: { completed: true }) }

    scope :taken,     -> { joins(:state).where(states: { taken: true }) }

    scope :withdrawn, -> { joins(:state).where(states: { withdrawn: true }) }


    # Validations

    validates :origin,      :presence => true
    validates :destination, :presence => true

    validates :items,       :presence => true

    validates :customer,    :presence => true

    validates_associated :items

  end

end