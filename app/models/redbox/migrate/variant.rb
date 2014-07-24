class Redbox::Migrate::Variant

  VARIANT_FIELDS_TO_UPDATE = {name: :name_storage}

  def create_variant(redbox_product, product)
    variant = Spree::Variant.create(
        {product: product}.merge create_hash redbox_product
    )
    variant.price = Spree::Price.create(amount: redbox_product.price, currency: 'PLN', variant: variant)
    redbox_product.combine_id = variant.id
    redbox_product.save
    variant
  end

  def update_variants(product, redbox_product)
    if redbox_product.has_variants?
      updated_variants = []
      redbox_variants = redbox_product.variants
      redbox_variants.each do |redbox_variant|
        if Spree::Variant.exists?(redbox_product_id: redbox_variant.product_id)
          variant = Spree::Variant.find_by(redbox_product_id: redbox_variant.product_id)
          update_fields(variant, redbox_variant, VARIANT_FIELDS_TO_UPDATE)
          variant.save
        else
          variant = create_variant(redbox_variant, product)
        end
        updated_variants << variant
      end
      # check_deleted_variants(product.variants, updated_variants)
    end
  end

  private
  def check_deleted_variants(variants, updated_variants)
    variants.each do |variant|
      found = false
      updated_variants.each do |updated_variant|
        if updated_variant.sku == variant.sku
          found = true
          break
        end
      end
      variant.destroy unless found
    end
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