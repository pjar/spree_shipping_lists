module Spree
  module Admin
    class ShippingLabelsController < ResourceController
      
      respond_to :html

      def create
        shipping_list_item = ShippingListItem.find(params[:shipping_label][:list_item_id])
        if ShippingLabelService.new.label_created?(shipping_list_item)
          flash[:success] = "OK - label created"
          redirect_to admin_shipping_list_path(shipping_list_item.list)
        else
          flash[:error] = "Something went wrong"
          redirect_to admin_shipping_list_path(shipping_list_item.list)
        end
      end


      def show
        @list = ShippingLabel.find(params[:id]).items
        session[:return_to] = request.url
        @collection = collection
        respond_with(@collection)
      end

    private
      
      def collection
        return @collection if @collection.present?
        params[:q] ||= {}

        params[:q][:s] ||= "created_at asc"
        @collection = @list
        # @search needs to be defined as this is passed to search_form_for
        @search = @collection.ransack(params[:q])
        @collection = @search.result.
              page(params[:page]).
              per(50)
        @collection
      end
    end
  end
end
