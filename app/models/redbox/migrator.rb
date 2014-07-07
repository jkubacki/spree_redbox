class Redbox::Migrator

  def migrate_product(redbox = Redbox::Product.last)
    create_tools
    product = Spree::Product.new
    product.meta_keywords = @string_decoder.decode(redbox.keywords)

    master = Spree::Variant.new
    master.description = @string_decoder.decode(redbox.description)
    master.sku = redbox.symbol
    master.active = redbox.visible

    puts product.inspect
    puts master.inspect
    'OK'
  end

  def migrate_suppliers(redbox_producers = Redbox::Producer.all)
    redbox_producers.each do |producer|
      migrate_supplier producer
    end
  end

  def migrate_supplier(producer)
    supplier = Spree::Supplier.create(
        id: producer.producer_id,
        short_name: producer.name,
        name: producer.longName,
        url: producer.www,
        note: ''
    )
  end

  private
  def create_tools
    @string_decoder = Redbox::StringDecoder.new
  end

end