module Travels

  extend Common::ForceConventionalNaming

  class Travel < ActiveRecord::Base

    #
    # Callbacks
    #

    # FIXME: Could we implement this as a callback?

    # We should establish state for the given travel
    # right before validation
    # before_validation :impose_default_state
    #
    # def impose_default_state
    #   self.state = Travels::State.get(:submitted)
    # end


  def self.new(attributes = nil)
      super (attributes || {}).merge({ state: State.get(:submitted) })
    end

    def self.create(attributes = nil, &block)
      super (attributes || {}).merge({ state: State.get(:submitted) }) do
        block
      end
    end


    #
    # Items
    #

    has_many    :items,
                :class_name => Item,
                :inverse_of => :travel

    # has_many    :items,
    #             :through      => :_t2d,
    #             :class_name   => Item,
    #             :autosave     => true

    accepts_nested_attributes_for :items,
                                  :reject_if => lambda { |item| item[:weight].blank?      ||
                                                                item[:name].blank?        &&
                                                                item[:description].blank?  }

    #
    # Origin
    #

    belongs_to  :origin,
                :class_name => Travels::Places::Origin,
                :inverse_of => :travel,
                :autosave   => true

    accepts_nested_attributes_for :origin,
                                  :reject_if => lambda { |place|  place[:address].blank?    ||
                                                                  place[:coordinates].blank? }

    #
    # Destinations
    #

    has_many :destinations,
             :through     => :items,
             :class_name  => Travels::Places::Destination,
             :autosave    => true

    #
    # NOTE: This is a HACK to allow complex forms involving nested attributes
    #       to be constructed, DO NOT USE it straightforward-ly
    #

    def destinations_attributes=(_)
      raise
    end

    #
    # State
    #

    belongs_to  :state,
                :class_name => State,
                :inverse_of => :travels,
                :autosave   => true

    # Include a handful of utility methods
    # short-circuiting state observation
    include State::ExportMethods


    #
    # Routes
    #

    has_one     :route,
                :class_name => Route,
                :inverse_of => :travel

    accepts_nested_attributes_for :route, :reject_if => lambda { |route|  route[:cost]      .blank?   ||
                                                                          route[:duration]  .blank?   ||
                                                                          route[:length]    .blank?   ||
                                                                          # route[:order]     .blank?   ||
                                                                          route[:polyline]  .blank? }


    # Customer

    belongs_to  :customer,
                :class_name => Users::Customer,
                :inverse_of => :orders


    # Performer

    belongs_to  :performer,
                :class_name => Users::Performer,
                :inverse_of => :orders

    # def performer=(performer)
    #   super
    #   self.state = State.get(:taken)
    # end


    # Notification system

    has_many    :notifications,
                :class_name => Travels::Notifications::TravelNotification,
                :inverse_of => :travel

    def notify(status, *args)
      case status
        when :created
          self.notifications << Notifications::created(self, *args)
        when :taken
          self.notifications << Notifications::taken(performer)
        else
          raise "Unknown status!"
      end
    end

    #
    # FIXME: Replace with proper event-management
    #

    after_commit lambda { |record| record.notify(:created) }, on: :create


    #
    # Travel operations
    #

    module TravelOperations
      extend ActiveSupport::Concern

      def take(_performer)
        self.performer = _performer
        self.state = State.get(:taken)

        saved = self.save
        # FIXME: Replace with proper EM system
        self.notify(:taken)
        saved
      end

      def complete
        self.state = State.get(:completed)
        saved = self.save
        # self.notify(:completed)
        saved
      end

      def cancel
        self.state = State.get(:cancelled)
        saved = self.save
        # self.notify(:cancelled)
        saved
      end

    end

    include TravelOperations


    #
    # Scopes
    #

    scope :of,        -> (owner) { where(customer: owner) }


    scope :completed, -> { joins(:state).where(states: { completed: true }) }

    scope :taken,     -> { joins(:state).where(states: { taken:     true }) }

    scope :withdrawn, -> { joins(:state).where(states: { withdrawn: true }) }

    scope :submitted, -> { joins(:state).where(states: { completed: false }) }
    # scope :submitted, -> { joins(:state).where(states: { completed: false, taken: false, withdrawn: false }) }

    scope :actual,    -> { joins(:state).where(states: { completed: false, taken: false }) }


    #
    # Validations
    #

    validates :origin,        :presence => true

    # validates :destinations,  :presence => true

    # validates :items,         :presence => true

    validates :customer,      :presence => true

    validates :state,         :presence => true

    validates_associated :items

  end

end