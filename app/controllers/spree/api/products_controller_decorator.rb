Spree::Api::ProductsController.class_eval do
  def update_redbox
    redbox_product = Redbox::Product.find(params[:id])
    migrator = Redbox::Migrate::Product.new
    @product = migrator.migrate_product(redbox_product)
  end
end