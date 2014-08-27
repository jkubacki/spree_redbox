module Spree
  module Admin
    class RedboxProductsController < Spree::Admin::BaseController

      def collection
        super.order(added: :desc)
      end

      def index
        # @products = Redbox::Product.with_hash.limit(5).includes(:colors).select(:id, :name_storage, :image, :symbol, :only_courier, :light_package)
        @products = Redbox::Product.with_hash.limit(5).select(:product_id, :name_storage, :image, :symbol, :only_courier, :light_package)
      end

      def update_multiple
        products = Redbox::Product.find(person_params.keys)
        products.each.with_index do |product|
          person_params[product.id.to_s].each { |key, value| eval "product.#{key} = #{value}" }
          product.save
        end
        redirect_to admin_redbox_products_path
      end

      private

      def person_params
        params[:products].permit!
      end

    end
  end
end