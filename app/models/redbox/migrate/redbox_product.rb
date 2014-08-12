class Redbox::Migrate::RedboxProduct
  include Redbox::Migrate
  PRODUCT_FIELDS_TO_UPDATE = {
      # Product
      keywords: 'product.meta_keywords',
      vat: 'product.tax_rate.amount.to_f * 100',
      unit: 'product.unit_id',
      # Variant
      symbol: :sku,
      weight: :weight,
      price_buy: 'cost_price.to_f',
      visible: :active,
      index: :index,
      name_invoice: :invoice_name,
      name_storage: :name,
      description: :description,
      combine_id: :id,
      # added: 'created_at.to_i'
  }

  def migrate_product(product)
    if product.has_variants?
      variants = product.variants
    else
      variants = [product.master]
    end
    products = []
    variants.each do |variant|
      products << migrate_variant(variant)
    end
    products
  end

  def migrate_variant(variant)
    product = if variant.redbox_product_id.blank?
      Redbox::Product.create(combine_id: variant.id)
    else
      Redbox::Product.find_by(product_id: variant.redbox_product_id)
    end
    update_fields(product, variant, PRODUCT_FIELDS_TO_UPDATE)
    product.save
    product
  end

end