class Redbox::Migrate::Variant
  include Redbox::Migrate

  VARIANT_FIELDS = {
      sku: :symbol,
      weight: :weight,
      cost_price: :price_buy,
      cost_currency: "#'PLN'",
      track_inventory: '#true',
      tax_category: ['Spree::TaxRate.rate@1.tax_category', 'vat'],
      active: :visible,
      index: :index,
      invoice_name: :name_invoice,
      name: :name_storage,
      description: :description,
      redbox_product_id: :product_id
  }

  VARIANT_FIELDS_CREATE = VARIANT_FIELDS.merge({
    price: '#Spree::Price.new'
  })
  VARIANT_FIELDS_UPDATE = VARIANT_FIELDS

  def create_variant(redbox_product, product)
    variant = Spree::Variant.new
    variant.product = product
    update_fields(variant, redbox_product, VARIANT_FIELDS_CREATE)
    variant.save
    update_stock_item variant, redbox_product
    variant.price = Spree::Price.create(amount: redbox_product.price, currency: 'PLN', variant: variant)
    redbox_product.combine_id = variant.id
    redbox_product.save if Rails.env.production?
    variant
  end

  def update_variants(product, redbox_product)
    update_redbox_variant product, redbox_product, true
    updated_variants = []
    if redbox_product.has_variants?
        redbox_product.variants.each do |redbox_variant|
          updated_variants << update_redbox_variant(product, redbox_variant)
        end
        puts updated_variants.inspect
      check_deleted_variants(product.variants, updated_variants)
    end
  end

  private
  def update_redbox_variant(product, redbox_variant, is_master = false)
    if is_master
      variant = product.master
      update_fields(variant, redbox_variant, VARIANT_FIELDS_UPDATE)
      variant.sku = redbox_variant.master_symbol if product.has_variants?
      variant.save
      variant.price = redbox_variant.price
      variant.save
      variant
    elsif Spree::Variant.exists?(redbox_product_id: redbox_variant.product_id, is_master: false)
      variant = Spree::Variant.find_by(redbox_product_id: redbox_variant.product_id, is_master: false)
      update_fields(variant, redbox_variant, VARIANT_FIELDS_UPDATE)
      update_stock_item variant, redbox_variant
      variant.save
      variant.price = redbox_variant.price
      variant.save
      variant
    else
      create_variant(redbox_variant, product) unless is_master
    end
  end

  def update_stock_item(variant, redbox_variant)
    stock_item = Spree::StockItem.find_by(stock_location_id: 1, variant_id: variant.id)
    stock_item.set_count_on_hand(redbox_variant.in_stock)
    stock_item.backorderable = if redbox_variant.empty_message == 0 then true else false end
    stock_item.save
  end

  def check_deleted_variants(variants, updated_variants)
    variants.each do |variant|
      found = false
      updated_variants.each do |updated_variant|
        if updated_variant.id == variant.id
          found = true
          break
        end
      end
      variant.destroy unless found
    end
  end

end