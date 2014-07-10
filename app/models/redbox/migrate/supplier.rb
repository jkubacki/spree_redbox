class Redbox::Migrate::Supplier
  def migrate_suppliers(redbox_producers = Redbox::Producer.all)
    redbox_producers.each do |producer|
      migrate_supplier producer
    end
  end

  def migrate_supplier(producer)
    Spree::Supplier.create(
        id: producer.producer_id,
        short_name: producer.name,
        name: producer.longName,
        url: producer.www,
        note: ''
    )
  end
end