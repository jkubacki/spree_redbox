class Redbox::Migrate::Supplier
  include Redbox::Migrate

  SUPPLIER_FIELDS = {
      short_name: :name,
      name: :longName,
      url: :www,
      note: "#''"
  }

  SUPPLIER_FIELDS_CREATE = SUPPLIER_FIELDS.merge({ id: :product_id })

  def migrate_suppliers(redbox_producers = Redbox::Producer.all)
    redbox_producers.each do |producer|
      migrate_supplier producer
    end
  end

  def migrate_supplier(producer)
    if Spree::Supplier.exists?(id: producer.producer_id)
      supplier = Spree::Supplier.find(producer.producer_id)
      update_fields(supplier, producer, SUPPLIER_FIELDS)

    else
      supplier = Spree::Supplier.new
      update_fields(supplier, producer, SUPPLIER_FIELDS_CREATE)
    end
    supplier.save
  end
end