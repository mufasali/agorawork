class AddQuantityOfListingsToListings < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :quantity_of_listings, :integer, after: :monthly_price_cents
  end
end
