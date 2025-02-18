class Event < ApplicationRecord
  include AASM

  AVAILIBALE_CURRENCIES = %w[USD EUR GBP].freeze
  AVAILIBALE_STATES = %w[active finished cancelled].freeze
  REQUIRED_KEYS = %i[
    name description location start_time total_tickets available_tickets ticket_price_cents currency
  ].freeze

  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  has_many :tickets, dependent: :destroy

  validates :name, :description, :location, :start_time,
            :total_tickets, :available_tickets, :ticket_price_cents, :currency,
            presence: true
  validates :total_tickets, numericality: { only_integer: true, greater_than: 0 }
  validates :available_tickets, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :ticket_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :state, inclusion: { in: AVAILIBALE_STATES, message: '%<value>s is not a valid state' }
  validates :currency, inclusion: { in: AVAILIBALE_CURRENCIES, message: '%<value>s is not a valid currency' }
  validates :name, uniqueness: { case_sensitive: false, message: 'Event name must be unique' }

  validate :available_tickets_cannot_exceed_total_tickets
  validate :end_time_after_start_time
  validate :start_time_must_be_in_future, on: :create
  validate :end_time_must_be_in_future, on: :create

  aasm column: 'state' do
    state :active, initial: true
    state :finished
    state :cancelled

    event :finish do
      transitions from: :active, to: :finished, guard: :end_time_reached?
    end

    event :cancel, after_commit: :cancel_all_tickets! do
      transitions from: :active, to: :cancelled
    end
  end

  def end_time_reached?
    end_time.present? && end_time <= Time.current
  end

  def decrement_available_tickets!(count = 1)
    with_lock do
      raise Tickets::Errors::TicketOperationError, 'Not enough available tickets' if available_tickets < count

      update!(available_tickets: available_tickets - count)
    end
  end

  def increment_available_tickets!(count = 1)
    with_lock do
      update!(available_tickets: available_tickets + count)
    end
  end

  private

  def available_tickets_cannot_exceed_total_tickets
    return unless available_tickets && total_tickets && available_tickets > total_tickets

    errors.add(:available_tickets, 'cannot be greater than total tickets')
  end

  def end_time_after_start_time
    return unless end_time.present? && start_time.present? && end_time <= start_time

    errors.add(:end_time, 'must be after start time')
  end

  def start_time_must_be_in_future
    return if finished?

    errors.add(:start_time, 'must be in the future') if start_time.present? && start_time < Time.current
  end

  def end_time_must_be_in_future
    return if finished?

    errors.add(:end_time, 'must be in the future') if end_time.present? && end_time < Time.current
  end

  def cancel_all_tickets!
    Ticket.transaction do
      tickets.where(state: %w[booked pending]).each(&:cancel!)
    end
  end
end
