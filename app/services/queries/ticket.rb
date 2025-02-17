module Queries
  class Ticket < Query
    set_model ::Ticket

    module Scopes
      def by_event(event)
        where(event: event)
      end

      def by_event_id(event_id)
        where(event_id: event_id)
      end

      def by_state(state)
        where(state: state)
      end

      def by_user(user)
        where(user: user)
      end

      def by_user_id(user_id)
        where(user_id: user_id)
      end

      def by_states(states)
        where(state: states)
      end

      def booked
        where(state: 'booked')
      end

      def pending
        where(state: 'pending')
      end

      def cancelled
        where(state: 'cancelled')
      end

      def by_price_range(min, max)
        where(price_cents: min..max)
      end

      def recent
        order(created_at: :desc)
      end

      def oldest
        order(created_at: :asc)
      end
    end
  end
end
