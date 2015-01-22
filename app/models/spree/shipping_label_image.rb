module Spree
  class ShippingLabelImage < Image

    Paperclip.interpolates :shipping_method do |att, _|
      att.instance.viewable.shipping_list_item.shipment.shipping_method.name.downcase
    end

    has_attached_file :attachment,
                      styles: { mini: '48x48>', small: '100x100>', product: '240x240>', large: '600x600>' },
                      default_style: :product,
                      url: '/spree/shipping_labels/:shipping_method/:id/:style/:basename.:extension',
                      path: ":rails_root/public/spree/shipping_labels/:shipping_method/:id/:style/:basename.:extension",
                      convert_options: { all: '-strip -auto-orient -colorspace sRGB' }
  end
end
