module Spree
  module Admin
    class RedboxProductsController < Spree::Admin::BaseController

      def index
        get_data
        category_id = form_params[:id]
        @products = Redbox::Product.within_category(category_id).with_hash.includes(:colors, :ocassions, :styles, :genders, :sizes).select(:product_id, :name_storage, :image, :symbol, :only_courier, :light_package)
      end

      def update_multiple
        Redbox::Product.find(products_params.keys).each.with_index do |product|
          product.update_attributes products_params[product.id.to_s]
        end
        redirect_to admin_redbox_products_path
      end

      private

      def products_params
        params[:products].permit!
      end

      def form_params
        if params[:category]
          params[:category].permit(:id)
        else
          {id: '046'}
        end
      end

      def get_data
        @colors = Redbox::Color.order('name ASC')
        @ocassions = Redbox::Ocassion.order('name ASC')
        @styles = Redbox::Style.order('name ASC')
        @genders = Redbox::Gender.order('name ASC')
        @sizes = Redbox::Size.order('name ASC')
        @categories = Redbox::Category.all_names Redbox::Category.find('046') # przebrania
      end

    end
  end
end