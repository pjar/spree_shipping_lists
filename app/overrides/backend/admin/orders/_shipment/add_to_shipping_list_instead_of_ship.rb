Deface::Override.new(virtual_path: 'spree/admin/orders/_shipment',
                     name: 'add_to_shipping_list_instead_of_ship_button',
                     replace_contents: '[data-hook="stock-location"]',
                     partial: 'spree/admin/orders/_shipment/add_to_shipping_list')
