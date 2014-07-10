class Redbox::Migrate::Order
  def migrate_order redbox_order
    puts create_hash(redbox_order).inspect
  end


  def create_hash redbox_order
    puts order_data.inspect
    {
        redbox_order_id: redbox_order.order_id
    }
  end
end