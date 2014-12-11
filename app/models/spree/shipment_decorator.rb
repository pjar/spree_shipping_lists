Spree::Shipment.class_eval do
  has_one :shipping_list_slot, class_name: 'ShippingListItem'
  has_one :shipping_list, through: :shipping_list_slot, source: :list

  def ready_for_fulfillment?
    determine_state(order) == 'ready' && shipping_list.blank?
  end
end
