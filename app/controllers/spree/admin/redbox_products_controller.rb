module Spree
  module Admin
    class RedboxProductsController < Spree::Admin::BaseController

      def index
        get_data
        @products = Redbox::Product.with_hash.limit(2).includes(:colors, :ocassions, :styles, :genders, :sizes).select(:product_id, :name_storage, :image, :symbol, :only_courier, :light_package)
      end

      def update_multiple
        Redbox::Product.find(person_params.keys).each.with_index do |product|
          product.update_attributes person_params[product.id.to_s]
        end
        redirect_to admin_redbox_products_path
      end

      private

      def person_params
        params[:products].permit!
      end

      def get_data
        @colors = Redbox::Color.order('name ASC')
        @ocassions = Redbox::Ocassion.order('name ASC')
        @styles = Redbox::Style.order('name ASC')
        @genders = Redbox::Gender.order('name ASC')
        @sizes = Redbox::Size.order('name ASC')
      end

    end
  end
end