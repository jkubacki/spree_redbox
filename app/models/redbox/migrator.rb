class Redbox::Migrator

  def migrate_product(redbox)
    unless Spree::Variant.where(redbox_product_id: redbox.product_id).blank?
      return  Spree::Variant.where(redbox_product_id: redbox.product_id).first.product
    end
    # throw Exception.new('Product already migrated') unless redbox.combine_id.nil?
    product = create_product(redbox)
    puts product.valid?
    return product
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
  # Create product with master variant and check if product have variants (symbol with ^ dash)
  def create_product(redbox_product)
    if redbox_product.symbol =~ /\^/ && redbox_product.symbol[0] == '#'
      position = redbox_product.symbol =~ /\^/
      master_sku = redbox_product.symbol[0..position]
      product = Spree::Product.create(
          {shipping_category: Spree::ShippingCategory.first}.merge create_hash(redbox_product, master_sku)
      )

      products = Redbox::Product.where('`symbol` LIKE ?', master_sku + '%').order(:symbol)
      products.each do |p|
        create_variant(p, product)
      end
    else
      product = Spree::Product.create(
          {shipping_category: Spree::ShippingCategory.first}.merge create_hash(redbox_product)
      )
    end
    product.price = Spree::Price.create(amount: redbox_product.price, currency: 'PLN', variant: product.master)
    return product
  end

  def create_variant(redbox_product, product)
    variant = Spree::Variant.create(
        {product: product}.merge create_hash redbox_product
    )
    variant.price = Spree::Price.create(amount: redbox_product.price, currency: 'PLN', variant: variant)
    redbox_product.combine_id = variant.id
    redbox_product.save
    variant
  end

  def create_hash(redbox_product, sku = nil)
    if sku.blank?
      sku = redbox_product.symbol
    end
    {redbox_product_id: redbox_product.product_id,
     name: redbox_product.name_storage,
     invoice_name: redbox_product.name_invoice,
     price: Spree::Price.new,
     slug: redbox_product.id,
     sku: sku,
     description: redbox_product.description}
  end

end