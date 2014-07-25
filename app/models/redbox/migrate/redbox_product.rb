class Redbox::Migrate::RedboxProduct
  PRODUCT_FIELDS_TO_UPDATE = {unit: 'product.unit_id', keywords: 'product.meta_keywords'}

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

  private
  def update_fields(subject, variant, fields)
    fields.each do |field, variant_field|
      eval "subject.#{field} = variant.#{variant_field}"
    end
  end
end