module Spree
  class ShippingList < Spree::Base

    has_many :items, class_name: 'ShippingListItem'
    has_many :shipments, through: :items
    has_many :state_changes, as: :stateful

    make_permalink field: :number, length: 11, prefix: 'LW'

    state_machine initial: :pending, use_transactions: false do
      event :ready do
        transition from: :pending, to: :ready, if: lambda { |list|
          # Fix for #2040
          list.determine_state(list.items) == :ready
        }
      end
      after_transition to: :ready, do: :set_closed_at

      event :pend do
        transition from: :ready, to: :pending
      end
      after_transition to: :ready, do: :set_closed_at

      event :ship do
        transition from: [:ready, :canceled], to: :shipped
      end

      event :cancel do
        transition to: :canceled, from: [:pending, :ready]
      end

      event :resume do
        transition from: :canceled, to: :ready, if: lambda { |list|
          list.determine_state(list.items) == :ready
        }
        transition from: :canceled, to: :pending, if: lambda { |list|
          list.determine_state(list.items) != :ready
        }
        transition from: :canceled, to: :pending
      end

      after_transition do |list, transition|
        list.state_changes.create!(
          previous_state: transition.from,
          next_state:     transition.to,
          name:           'shipping_list',
        )
      end
    end

  private

    def determine_state
      items.all?(&:ready?) ? :ready : :pending
    end

    def set_closed_at
      if closed?
        self.closed_at = DateTime.now
      else
        self.closed_at = nil
      end
    end
  end
end

