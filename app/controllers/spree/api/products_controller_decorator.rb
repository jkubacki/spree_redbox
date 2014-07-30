Spree::Api::ProductsController.class_eval do
  def update_redbox
    redbox_product = Redbox::Product.find_by(product_id: params[:id])
    if redbox_product.nil?
      raise "Redbox product with id #{params[:id]} do not exists"
    end
    puts redbox_product.inspect

    migrator = Redbox::Migrate::Product.new
    @product = migrator.migrate_product(redbox_product)
  end
end