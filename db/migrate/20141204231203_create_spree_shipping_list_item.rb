class CreateSpreeShippingListItem < ActiveRecord::Migration
  def change
    create_table :spree_shipping_list_items do |t|
      t.references :shipment, index: {unique: true}
      t.references :shipping_list, index: true
      t.attachment :label
    end
  end
end
