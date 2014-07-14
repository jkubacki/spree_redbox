class Redbox::Migrate::Order
  def migrate_order redbox_order
    puts create_hash(redbox_order).inspect
  end


  def create_hash redbox_order
    puts redbox_order.items
  end
end