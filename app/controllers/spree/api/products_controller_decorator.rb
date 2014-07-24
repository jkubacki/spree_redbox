Spree::Api::ProductsController.class_eval do
  def show_redbox
    @product = find_product(params[:id])
    expires_in 15.minutes, :public => true
    headers['Surrogate-Control'] = "max-age=#{15.minutes}"
    headers['Surrogate-Key'] = "product_id=1"
  end
end