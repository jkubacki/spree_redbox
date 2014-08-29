class Redbox::CategoryTool

  def set_parent(category, parent)
    children = category.children
    new_id = parent.category_id + new_children_number(parent.children)
    Redbox::Product.within_category(category.id).each do |product|
      product.category_id = new_id if product.category_id == category.id
      product.category_id2 = new_id if product.category_id2 == category.id
      product.category_id3 = new_id if product.category_id3 == category.id
      product.save
    end
    Redbox::Category.where(category_id: category.category_id).update_all category_id: new_id
    category.category_id = new_id
    children.each do |child|
      set_parent child, category
    end
    nil
  end

  def new_children_number(children)
    max_id = ''
    children.each do |child|
      suffix = child.number_chunks[-1]
      max_id = suffix if suffix > max_id
    end
    (max_id.to_i + 1).to_s.rjust(3, "0")
  end

  def products(category)
    Redbox::Product.within_category category.id
  end

end