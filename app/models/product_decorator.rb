Spree::Product.class_eval do
  delegate_belongs_to :master, :redbox_product_id
  # before_save :migrate_redbox

  def migrate_redbox
    Redbox::Migrate::RedboxProduct.new.migrate_product self
  end
end