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

    def initialize(*args)
      super(*args)
      log << Travels::States::Submitted.new
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
    # State log
    #

    # Make self a log (storing `Travels::States::AbstractState`)
    module TravelStateLog
      extend ActiveSupport::Concern

      # Log itself
      def log
        send(:loggables)
      end

      # Actual state being the tail of state-log
      def state
        # FIXME
        #
        # We can't do this actually, otherwise `Travel` validation
        # would fail during new travel instance creation, since custom
        # ordering would trigger database query while it's in inconsistent state (not updated yet)
        # log.order(created_at: :desc).first
        log.last
      end

      included do |base|
        # FIXME: Autoload
        Travels::Logs::Log
        Travels::Logs.make(base, :logs, what: Travels::States::AbstractState)
      end
    end

    include TravelStateLog

    #
    # COMPAT: This is compatibility due to replacing previous travel's `state` model
    #         with the new one (as of v0.1.1)
    #         To be dropped in the next release (so far v0.2)
    #

    # def state
    #   # super || State.get(:submitted)
    #   super
    # end

    # Include a handful of utility methods
    # short-circuiting state observation
    include Travels::States::AbstractState::ExportMethods


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
        # self.state = State.get(:taken)
        self.log << Travels::States::Taken.new

        saved = self.save
        # FIXME: Replace with proper EM system
        self.notify(:taken)
        saved
      end

      def complete
        # self.state = State.get(:completed)
        self.log << Travels::States::Completed.new
        saved = self.save
        # self.notify(:completed)
        saved
      end

      def cancel
        # self.state = State.get(:canceled)
        self.log << Travels::States::Canceled.new
        saved = self.save
        # self.notify(:canceled)
        saved
      end

    end

    include TravelOperations


    #
    # Scopes
    #

    module ScopeHelpers
      extend ActiveSupport::Concern

      module ClassMethods
        def assoc_table_name(assoc)
          reflect_on_association(assoc).table_name
        end

        def assoc_foreign_key(assoc)
          reflect_on_association(assoc).foreign_key
        end
      end
    end

    include ScopeHelpers

    #
    # Scopes
    #

    scope :of, -> (owner) { where(customer: owner) }

    # scope :completed, -> { joins(:states).where(state: State.get(:completed)) }
    # scope :completed, -> { joins(:loggables).where(type: Travels::States::Completed) }
    scope :completed,   -> { _with_latest_logged(Travels::States::Completed) }

    # scope :taken,     -> { joins(:states).where(state: State.get(:taken)) }
    # scope :taken,     -> { joins(:loggables).order(updated_at: :desc).limit(1).where(loggables: { type: Travels::States::Taken }) }
    scope :taken,       -> { _with_latest_logged(Travels::States::Taken) }

    # scope :withdrawn, -> { joins(:states).where(state: State.get(:withdrawn)) }
    # scope :withdrawn, -> { joins(:loggables).where(type: Travels::States::Withdrawn) }
    scope :withdrawn,   -> { _with_latest_logged(Travels::States::Withdrawn) }

    # scope :submitted, -> { joins(:states).where(state: State.get(:submitted)) }
    # scope :submitted, -> { joins(:loggables).where(type: Travels::States::Submitted) }
    scope :submitted,   -> { _with_latest_logged(Travels::States::Submitted) }

    # scope :actual,    -> { joins(:state).where(status: { completed: false, taken: false }) }
    scope :actual,      -> { submitted }

    private

      scope :_with_latest_logged, -> (type) {
        itself    = table_name
        loggables = assoc_table_name(:loggables)
        fk        = assoc_foreign_key(:loggables)

        #
        # FIXME
        #   Those kind of a req strongly demands
        #   index to be involved
        #

        joins(%Q{
          INNER JOIN      #{loggables} lg0 ON (#{itself}.id = lg0.#{fk})
          LEFT OUTER JOIN #{loggables} lg1 ON
          (
            lg0.#{fk} = lg1.#{fk} AND
            lg0.created_at < lg1.created_at
          )
        }).where("lg1.#{fk} IS NULL")
          .where(lg0: { type: type })
      }


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