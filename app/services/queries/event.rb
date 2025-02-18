module Queries
  class Event < Query
    set_model ::Event

    module Scopes
      def by_name(name)
        where('LOWER(name) LIKE ?', "%#{name.downcase}%")
      end

      def by_state(state)
        where(state: state)
      end

      def by_location(location)
        where('LOWER(location) LIKE ?', "%#{location.downcase}%")
      end

      def by_start_time(range)
        where(start_time: range)
      end

      def by_end_time(range)
        where(end_time: range)
      end

      def upcoming
        where('start_time > ?', Time.current)
      end

      def past
        where('end_time < ?', Time.current)
      end

      def active
        where(state: 'active')
      end

      def cancelled
        where(state: 'cancelled')
      end

      def finished
        where(state: 'finished')
      end

      def with_available_tickets
        where('available_tickets > 0')
      end

      def by_price_range(min, max)
        where(ticket_price_cents: min..max)
      end

      def by_id(event_id)
        find(event_id)
      end

      def by_ids(event_ids)
        where(id: event_ids)
      end

      def by_ticket(ticket)
        where(id: ticket.event_id)
      end

      def order_by_start_time(order = :asc)
        order(start_time: order)
      end

      def all_with_includes
        includes(:creator, :tickets)
      end

      def cached_all_with_includes
        Rails.cache.fetch('events/all', expires_in: 10.minutes) { all_with_includes }
      end

      def cached_find(id)
        Rails.cache.fetch("events/#{id}", expires_in: 10.minutes) { by_id(id) }
      end
    end
  end
end
