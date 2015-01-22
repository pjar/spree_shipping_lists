class CreateSpreeShippingLabels < ActiveRecord::Migration
  def change
    create_table :spree_shipping_labels do |t|
      t.references :shipping_list_item, index: {unique: true}
      t.text :tracking_number
      t.text :api_data_sent
      t.text :api_data_received
      t.string :type
    end
  end
end
