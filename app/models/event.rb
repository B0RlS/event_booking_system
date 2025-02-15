# Class for creating Events
class Event < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'

  has_many :tickets, dependent: :destroy

  validates :name, :description, :location, :start_time,
            :total_tickets, :available_tickets, :ticket_price_cents, :currency,
            presence: true

  validates :total_tickets, numericality: { only_integer: true, greater_than: 0 }
  validates :available_tickets, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :ticket_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :available_tickets_cannot_exceed_total_tickets

  validate :end_time_after_start_time

  include AASM

  aasm column: 'state' do
    state :active, initial: true
    state :finished
    state :cancelled

    event :finish do
      transitions from: :active, to: :finished, guard: :end_time_reached?
    end

    event :cancel do
      transitions from: :active, to: :cancelled
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

  def end_time_reached?
    end_time.present? && end_time <= Time.current
  end
end
