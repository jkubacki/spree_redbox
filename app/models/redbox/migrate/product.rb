class Redbox::Migrate::Product

  PRODUCT_FIELDS_TO_UPDATE = {unit_id: :unit}

  def initialize
    @migrate_variant = Redbox::Migrate::Variant.new
  end

  def migrate_product(redbox_product)
    if Spree::Variant.exists?(redbox_product_id: redbox_product.product_id)
      update_product redbox_product
      # variant = Spree::Variant.find_by(redbox_product_id: redbox_product.product_id)
      # change = false
      # if redbox_product.name_storage != variant.name
      #   variant.name = redbox_product.name_storage
      #   change = true
      # end
      # if redbox_product.name_invoice != variant.invoice_name
      #   variant.invoice_name = redbox_product.name_invoice
      #   change = true
      # end
      # variant.save if change
    else
      create_product redbox_product
    end
  end

  private
  # Create product with master variant and check if product have variants (symbol with ^ dash)
  def create_product(redbox_product)
    puts "Redbox: #{redbox_product.name} : #{redbox_product.symbol}"
    if redbox_product.has_variants?
      product = Spree::Product.create(
          {shipping_category: Spree::ShippingCategory.first}.merge create_hash(redbox_product, redbox_product.master_symbol)
      )
      products = redbox_product.variants
      products.each do |p|
        @migrate_variant.create_variant(p, product)
      end
    else
      product = Spree::Product.create(
          {shipping_category: Spree::ShippingCategory.first}.merge create_hash(redbox_product)
      )
      redbox_product.combine_id = product.master.id
      redbox_product.save
    end
    puts "Combine: #{product.name} : #{product.sku}"
    puts ''
    product.price = Spree::Price.create(amount: redbox_product.price, currency: 'PLN', variant: product.master)
    return product
  end

  # Updates product from red-box
  def update_product(redbox_product)
    product = Spree::Variant.where(redbox_product_id: redbox_product.id).first.product
    puts product.name
    update_fields(product, redbox_product, PRODUCT_FIELDS_TO_UPDATE)
    @migrate_variant.update_variants product, redbox_product
    product.save
    product
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

  def update_fields(subject, redbox_product, fields)
    fields.each do |field, redbox_field|
      eval "subject.#{field} = redbox_product.#{redbox_field}"
    end
  end

end