module Spree
  class ShippingLabelService

    UPS_SERVICE_CODE = 11
    UPS_SERVICE_DESCRIPTION = 'Standard'

    attr_reader :carrier

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
      response = label_response(shipping_list_item).labels.first
      tracking_number = response[:tracking_number]
      base64_image = response[:image]['GraphicImage']

      create_label_attachment(tracking_number, base64_image)    
    rescue => e
      raise "Something wrong with label => #{e}"
    end

    def create_label(tracking_number, base64_encoded_image)
      label = shipping_list_item.create_label!(tracking_number: tracking_number)
      working_image = Paperclip.io_adapters.for("data:image/gif;base64,#{base64_encoded_image}")
      working_image.original_filename = "label#{tracking_number}.gif"
      label.create_image!(attachment: working_image)
      label
    end

    def label_created?(shipping_list_item)
      process_label(shipping_list_item)
      shipping_list_item.label.image.try(:attachment?)
    end

    private

    def build_location(address)
      default_fields = {
        :country   => address.country.iso,
        :state     => fetch_best_state_from_address(address),
        :city      => address.city,
        :zip       => address.zipcode,
        :address1  => address.address1,
        :address2  => address.address2,
      }

      if [:company, :firstname, :lastname].all?{ |field| address.respond_to?(field) }
        default_fields.merge!(:name => "#{address.company}    #{address.firstname} #{address.lastname}")
      end

      ActiveMerchant::Shipping::Location.new(default_fields)
    end

    def fetch_best_state_from_address address
      address.state ? address.state.abbr : address.state_name
    end

    def setup_carrier
      carrier_details = {
        :login => Spree::ActiveShipping::Config[:ups_login],
        :password => Spree::ActiveShipping::Config[:ups_password],
        :key => Spree::ActiveShipping::Config[:ups_key],
        :test => Spree::ActiveShipping::Config[:test_mode]
      }

      if shipper_number = Spree::ActiveShipping::Config[:shipper_number]
        carrier_details.merge!(:origin_account => shipper_number)
      end

      required_shipper_name = Spree::ActiveShipping::Config[:shipper_name].to_str
      carrier_details.merge!(origin_name: required_shipper_name)

      carrier_details.merge!(service_code: UPS_SERVICE_CODE)
      carrier_details.merge!(service_description: UPS_SERVICE_DESCRIPTION)

      @carrier = ActiveMerchant::Shipping::UPS.new(carrier_details)
    end
  end
end
