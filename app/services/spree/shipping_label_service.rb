module Spree
  class ShippingLabelService

    attr_reader :carrier

    def self.label_created?(shipping_list_item)
      label_type = shipping_list_item.shipment.shipping_method.name.titleize
      "Spree::#{label_type}Label::#{label_type}LabelService".constantize.
        new.label_created?(shipping_list_item)
    end

    def initialize
      setup_carrier
    end

    def label_response(shipping_list_item)
      package = shipping_list_item.to_package
      order = shipping_list_item.order
      stock_location = shipping_list_item.stock_location

      origin = build_location(stock_location)
      destination = build_location(order.ship_address)
      carrier.create_shipment(origin, destination, [package])
    end

    def process_label(shipping_list_item)
      raise NotImplementedError.new('You have to implement #shipping_list_item')
    end

    def create_label_attachment(shipping_list_item, tracking_number, base64_encoded_image)
      raise NotImplementedError.new('You have to implement #create_label_attachment')
    end

    def label_created?(shipping_list_item)
      process_label(shipping_list_item)
      shipping_list_item.label.image.try(:attachment?)
    end

    private

    def build_location(address)
      default_fields = {
        :phone     => address.phone,
        :address1  => address.address1,
        :address2  => address.address2,
        :city      => address.city,
        :zip       => address.zipcode,
        :state     => fetch_best_state_from_address(address),
        :country   => address.country.iso,
      }

      if [:firstname, :lastname].all?{ |field| address.respond_to?(field) }
        default_fields.merge!(:name => "#{address.firstname} #{address.lastname}")
      end

      address_type = nil
      if address.respond_to?(:company)
        address_type = address.company == 'Paczkomaty' ? 'po_box' : address.company.present? ? 'commercial' : 'residential'
        default_fields.merge!(company_name: address.company)
      else
        address_type = 'commercial' # for origins
      end

      ActiveMerchant::Shipping::Location.new(default_fields.merge({address_type: address_type}))
    end

    def fetch_best_state_from_address address
      address.state ? address.state.abbr : address.state_name
    end

    def setup_carrier
      raise NotImplementedError.new('You have to implement #setup_carrier')
    end
  end
end
