Spree::Product.class_eval do
  delegate_belongs_to :master, :redbox_product_id
end