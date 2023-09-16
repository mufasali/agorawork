class AddPriceUnitTypeToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :weekly_price_cents, :integer, after: :unit_price_cents, default: 0
    add_column :transactions, :monthly_price_cents, :string, after: :weekly_price_cents, default: 0
    add_column :transactions, :price_unit_type, :string, after: :unit_type
  end
end
