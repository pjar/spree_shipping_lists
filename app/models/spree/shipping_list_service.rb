module Spree
  class ShippingListService

   attr_reader :shipment, :shipping_list

    def initialize(opts)
      @shipment = opts.fetch(:shipment)
    end

    def push_shipment_to_shipping_list
      create_or_find_list
      add_list_item
    end

    def remove_shipment_from_shipping_list
      shipment.shipping_list_slot.destroy
    end

    def create_or_find_list
      @shipping_list = 
        ShippingList.find_or_create_by(state: 'pending', 
                                       shipping_method_id: shipping_method_determined_from_shipment)
    end

    def add_list_item
      shipping_list.items.create(shipment: shipment)
    end

  private

    def shipping_method_determined_from_shipment
      shipment.shipping_method.id
    end
  end
end
