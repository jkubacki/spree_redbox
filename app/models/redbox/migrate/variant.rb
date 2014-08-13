class Redbox::Migrate::Variant
  include Redbox::Migrate

  VARIANT_FIELDS = {
      sku: :symbol,
      weight: :weight,
      cost_price: :price_buy,
      cost_currency: "#'PLN'",
      track_inventory: '#true',
      active: :visible,
      index: :index,
      invoice_name: :name_invoice,
      name: :name_storage,
      description: :description,
      redbox_product_id: :product_id,
      supplier_id: :producer_id
  }

  VARIANT_FIELDS_CREATE = VARIANT_FIELDS.merge({
    price: '#Spree::Price.new'
  })
  VARIANT_FIELDS_UPDATE = VARIANT_FIELDS

  def initialize
    @migrate_image = Redbox::Migrate::Image.new
  end

  def create_variant(redbox_product, product)
    variant = Spree::Variant.new
    variant.product = product
    update_fields(variant, redbox_product, VARIANT_FIELDS_CREATE.merge(created_at: ['Time.at(@1)', 'added'], tax_category: ['Spree::TaxRate.rate@1.tax_category', 'vat']))
    return nil unless variant.valid?
    variant.save
    update_store_variants variant, redbox_product
    update_stock_item variant, redbox_product
    variant.price = Spree::Price.create(amount: redbox_product.price_brutto, currency: 'PLN', variant: variant)
    @migrate_image.update_variant_images redbox_product, variant
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
      check_deleted_variants(product.variants, updated_variants)
    end
  end

  def update_stock_item(variant, redbox_variant)
    stock_item = Spree::StockItem.find_by(stock_location_id: 1, variant_id: variant.id)
    if stock_item.blank?
      stock_item = Spree::StockItem.create(stock_location_id: 1, variant: variant)
    end
    stock_item.set_count_on_hand(if redbox_variant.on_hand > 0 then redbox_variant.on_hand else 0 end)
    stock_item.backorderable = if redbox_variant.empty_message == 0 then true else false end
    stock_item.save
  end

  def update_store_variants(variant, redbox_variant)
    variant.store_variants.each do |store_variant|
      if store_variant.store.code == 'red'
        store_variant.name = redbox_variant.name
        store_variant.price = redbox_variant.price_brutto
      elsif store_variant.store.code == 'kos'
        store_variant.name = redbox_variant.name_istore
        store_variant.price = redbox_variant.price_istore
      elsif store_variant.store.code == 'ts'
        store_variant.name = redbox_variant.name_eprice
        store_variant.price = redbox_variant.price_eprice
      elsif store_variant.store.code == 't24'
        store_variant.name = redbox_variant.name
        store_variant.price = redbox_variant.price_t24
      end
      store_variant.save
    end
  end

  private
  def update_redbox_variant(product, redbox_variant, is_master = false)
    variant = if is_master
      variant = product.master
      update_fields(variant, redbox_variant, VARIANT_FIELDS_UPDATE.merge(created_at: ['Time.at(@1)', 'added'], tax_category: ['Spree::TaxRate.rate@1.tax_category', 'vat']))
      variant.sku = redbox_variant.master_symbol if product.has_variants?
      update_stock_item variant, redbox_variant
      variant.price = redbox_variant.price_brutto
      variant.save
      update_store_variants variant, redbox_variant
      variant
    elsif Spree::Variant.exists?(redbox_product_id: redbox_variant.product_id, is_master: false)
      variant = Spree::Variant.find_by(redbox_product_id: redbox_variant.product_id, is_master: false)
      update_fields(variant, redbox_variant, VARIANT_FIELDS_UPDATE.merge(created_at: ['Time.at(@1)', 'added'], tax_category: ['Spree::TaxRate.rate@1.tax_category', 'vat']))
      update_stock_item variant, redbox_variant
      variant.price = redbox_variant.price_brutto
      variant.save
      update_store_variants variant, redbox_variant
      variant
    else
      create_variant(redbox_variant, product) unless is_master
    end
    @migrate_image.update_variant_images redbox_variant, variant
    variant
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