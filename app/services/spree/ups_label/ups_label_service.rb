module Spree
  module UpsLabel
    class UpsLabelService < ShippingLabelService

      UPS_SERVICE_CODE = 11
      UPS_SERVICE_DESCRIPTION = 'Standard'

      def process_label(shipping_list_item)
        response = label_response(shipping_list_item).labels.first
        tracking_number = response[:tracking_number]
        base64_image = response[:image]['GraphicImage']

        create_label_attachment(shipping_list_item, tracking_number, base64_image)    
      rescue => e
        raise "Something wrong with label => #{e}"
      end

      def create_label_attachment(shipping_list_item, tracking_number, base64_encoded_image)
        label = shipping_list_item.create_label!(tracking_number: tracking_number)
        working_image = Paperclip.io_adapters.for("data:image/gif;base64,#{base64_encoded_image}")
        working_image.original_filename = "label#{tracking_number}.gif"
        label.create_image!(attachment: working_image)
        label
      end

      private

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
end
