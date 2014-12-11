class CreateSpreeShippingList < ActiveRecord::Migration
  def change
    create_table :spree_shipping_lists do |t|
      t.string :state
      t.references :shipping_method, index: true
      t.boolean :is_ongoing
      t.datetime :closed_at
      t.references :store, index: true
      t.string :number
    end
  end
end
