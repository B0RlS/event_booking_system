class Ticket < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :event

  # Possible improvement to create list of availible currencies
  AVAILIBALE_CURRENCIES = %w[USD EUR GBP].freeze

  validates :quantity, presence: true,
                       numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, presence: true,
                          numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :currency, presence: true,
                       inclusion: { in: AVAILIBALE_CURRENCIES,
                                    message: '%<value>s is not a valid currency' }

  validate :booked_state_timestamps, if: -> { aasm.current_state == :booked }
  validate :cancelled_at_presence, if: -> { aasm.current_state == :cancelled }
  validate :pending_state_no_timestamps, if: -> { aasm.current_state == :pending }
  validate :quantity_within_event_availability

  aasm column: 'state' do
    state :pending, initial: true
    state :booked
    state :cancelled
    state :refunded

    event :confirm, before: :set_booked_at do
      transitions from: :pending, to: :booked
    end

    event :cancel, before: :set_cancelled_at do
      transitions from: %i[pending booked], to: :cancelled
    end

    event :refund do
      transitions from: :booked, to: :refunded
    end
  end

  private

  def set_booked_at
    self.booked_at ||= Time.current
  end

  def set_cancelled_at
    self.cancelled_at ||= Time.current
  end

  def booked_state_timestamps
    errors.add(:booked_at, 'must be present when ticket is booked') if booked_at.blank?
    errors.add(:cancelled_at, 'must not be set when ticket is booked') if cancelled_at.present?
  end

  def cancelled_at_presence
    errors.add(:cancelled_at, 'must be present when ticket is cancelled') if cancelled_at.blank?
  end

  def pending_state_no_timestamps
    return unless booked_at.present? || cancelled_at.present?

    errors.add(:base, 'Timestamps should not be set for pending tickets')
  end

  def quantity_within_event_availability
    return if event.blank? || quantity.blank?

    validate_event_ticket_counts
    validate_quantity_availability
  end

  def validate_event_ticket_counts
    return if event.available_tickets.present? && event.total_tickets.present?

    errors.add(:event, 'does not have ticket counts set properly')
  end

  def validate_quantity_availability
    return unless event.available_tickets.present? && quantity > event.available_tickets

    errors.add(:quantity, 'exceeds the available tickets')
  end
end
