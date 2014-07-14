require 'php_serialize'
class Redbox::Order < ActiveRecord::Base
  establish_connection 'redbox'
  self.table_name = 'shop_orders'

  # after_initialize :deserialize_items

  def items
    data = PHP.unserialize(order_data)
    data.each do |product|
      puts product.inspect
    end
  end
end