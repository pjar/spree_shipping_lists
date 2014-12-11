module Spree
  module Api
    class FulfillmentsController < Spree::Api::BaseController

      def start
        @shipment = Spree::Shipment.find_by!(number: params[:id])
        service = ShippingListService.new({shipment: @shipment})
        service.push_shipment_to_shipping_list
        respond_with(@shipment, default_template: :show)
      end
    end
  end
end

