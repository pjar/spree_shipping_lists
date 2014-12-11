module Spree
  module Admin
    class ShippingListsController < ResourceController
      
      respond_to :html

      def show
        @list = ShippingList.find(params[:id]).items
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
