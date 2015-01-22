module Spree
  class ShippingLabel < ActiveRecord::Base
    belongs_to :shipping_list_item, foreign_key: :list_item_id
    has_one :image, as: :viewable, class_name: 'Spree::ShippingLabelImage'
    
    def ok?
      false
    end
  end
end
