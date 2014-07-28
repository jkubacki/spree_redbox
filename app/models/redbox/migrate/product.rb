class Redbox::Migrate::Product
  include Redbox::Migrate

  PRODUCT_FIELDS = {
      slug: :id,
      meta_description: :description,
      meta_keywords: :keywords,
      tax_category: ['Spree::TaxRate.rate@1.tax_category', 'vat'],
      shipping_category: '#Spree::ShippingCategory.first', # TODO
      can_be_part: 'is_sub_multiproduct?',
      individual_sale: 'is_main_multiproduct?',
      unit_id: :unit,
      # Master variant
      sku: :symbol,
      weight: :weight,
      cost_price: :price_buy,
      cost_currency: "#'PLN'",
      active: :visible,
      index: :index,
      invoice_name: :name_invoice,
      name: :name_storage,
      description: :description,
      redbox_product_id: :product_id
  }

  PRODUCT_FIELDS_CREATE = PRODUCT_FIELDS.merge({
    price: '#Spree::Price.new'
  })

  PRODUCT_FIELDS_UPDATE = PRODUCT_FIELDS.merge({
  })

  def initialize
    @migrate_variant = Redbox::Migrate::Variant.new
  end

  def migrate_product(redbox_product)
    if Spree::Variant.exists?(redbox_product_id: redbox_product.product_id)
      update_product redbox_product
    else
      create_product redbox_product
    end
  end

  private
  # Create product with master variant and check if product have variants (symbol with ^ dash)
  def create_product(redbox_product)
    if redbox_product.has_variants?
      if Spree::Variant.exists?(sku: redbox_product.master_symbol)
        product = Spree::Variant.find_by(sku: redbox_product.master_symbol).product
        @migrate_variant.create_variant(redbox_product, product)
        return product
      end
      product = Spree::Product.new
      update_fields(product, redbox_product, PRODUCT_FIELDS_CREATE)
      product.sku = redbox_product.master_symbol
      product.save
      products = redbox_product.variants
      products.each do |p|
        @migrate_variant.create_variant(p, product)
      end
    else
      product = Spree::Product.new
      update_fields(product, redbox_product, PRODUCT_FIELDS_CREATE)
      product.save
    end
    product.price = Spree::Price.create(amount: redbox_product.price, currency: 'PLN', variant: product.master)
    product
  end

  # Updates product from red-box
  def update_product(redbox_product)
    product = Spree::Variant.where(redbox_product_id: redbox_product.id).first.product
    update_fields(product, redbox_product, PRODUCT_FIELDS_UPDATE)
    @migrate_variant.update_variants product, redbox_product
    product.save
    product
  end

end