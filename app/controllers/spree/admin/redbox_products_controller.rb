module Spree
  module Admin
    class RedboxProductsController < Spree::Admin::BaseController

      def collection
        super.order(added: :desc)
      end

      def index
        @products = Redbox::Product.with_hash.limit(5).includes(:colors).select(:product_id, :name_storage, :image, :symbol, :only_courier, :light_package)
      end

      def update_multiple
        # Redbox::Product.update(params[:products].keys, params[:products].values)
        puts params.inspect
        redirect_to admin_redbox_products_path
      end

    end
  end
end
