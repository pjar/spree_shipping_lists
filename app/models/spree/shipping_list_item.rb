module Spree
  class ShippingListItem < Spree::Base
    belongs_to :shipment
    belongs_to :list, class_name: 'ShippingList', foreign_key: :shipping_list_id
    has_one :label, class_name: 'ShippingLabel', foreign_key: :list_item_id

    validates :shipment, uniqueness: {scope: :shipping_list_id}

    delegate :order, :stock_location, to: :shipment

    def ready?
      label && label.ok?
    end

    def to_package
      ActiveMerchant::Shipping::Package.new(*products_measurements)
    end

    private

    def products_measurements
      collection = shipment.order.line_items.map(&:product)
      weight = collection.map(&:weight).sum
      weight = 500 if weight == 0
      dimmensions = collection.inject([0, 0, 0]) do |result, product|
        result = [
          result, [:height, :width, :depth].map{ |d| product.send(d).presence || 10 }
        ].map(&:sum)
        result
      end

      [weight, dimmensions]
    end
  end
end
