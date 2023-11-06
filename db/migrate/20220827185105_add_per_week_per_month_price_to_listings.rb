class AddPerWeekPerMonthPriceToListings < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :weekly_price_cents, :integer, after: :price_cents
    add_column :listings, :monthly_price_cents, :integer, after: :weekly_price_cents
  end
end
