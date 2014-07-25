class Redbox::Converter::Product

  def spree_to_redbox(redbox_id)
    combine = Spree::Variant.find_by(redbox_product_id: redbox_id)
    redbox = Redbox::Product.new
    redbox.product_id = redbox_id
    redbox.storage_name = combine.name
    redbox.shop_id = 1
    redbox.description = combine.description
    redbox.keywords = combine.product.meta_keywords
    redbox.symbol = combine.sku
    redbox.profile_id = 0
    redbox.price_buy = combine.cost_price
    redbox.vat = combine.tax_category.tax_rate.amount
    redbox.weight = combine.weight

    # to add
    # redbox.category_id = combine.redbox.categories[0]
    # redbox.category_id2 = combine.redbox.categories[1]
    # redbox.category_id3 = combine.redbox.categories[2]
    # redbox.name = combine.redbox.name
    # redbox.producer_id = combine.supplier.id
    #redbox.profile_data = get things from properties and Option Types
    # redbox.price = combine.redbox.price
    # redbox.price_promo = combine.redbox.price


  end

end