module Spree
  class ShippingListItem < Spree::Base
    belongs_to :shipment
    belongs_to :list, class_name: 'ShippingList', foreign_key: :shipping_list_id

    validates :shipment, uniqueness: {scope: :shipping_list_id}

    def ready?
      false
    end
  end
end
