json.array!(@inventories) do |inventory|
  json.extract! inventory, :id, :product_type_id, :amount, :purchased_price, :purchased_date, :location_id, :status
  json.url inventory_url(inventory, format: :json)
end
