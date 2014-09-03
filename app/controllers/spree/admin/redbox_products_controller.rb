module Spree
  module Admin
    class RedboxProductsController < Spree::Admin::BaseController

      def index
        get_data
        @category_id = form_params[:id]
        @custom = []
        if params.has_key?(:q) and params[:q].has_key?(:custom)
          @custom = params[:q][:custom]
        end
        @q = Redbox::Product.search(params[:q])
        query = "@products = @q.result(distinct: true)
          .within_category(@category_id)
          .with_hash.page(params[:page])
          .per(10).includes(:colors, :ocassions, :styles, :genders, :sizes)
          .select('shop_product.product_id', :name_storage, :image, :symbol, :only_courier, :light_package, :visible)
          .order(visible: :desc, symbol: :asc)"
        if @custom.include?(:without_taxons)
          query += ".without_taxons"
        else
          if @custom.include?(:without_colors)
            query += ".without_colors"
          end
          if @custom.include?(:without_ocassions)
            query += ".without_ocassions"
          end
          if @custom.include?(:without_sizes)
            query += ".without_sizes"
          end
          if @custom.include?(:without_styles)
            query += ".without_styles"
          end
          if @custom.include?(:without_genders)
            query += ".without_genders"
          end
        end
        eval query
        @page = params[:page] || 1
      end

      def update_multiple
        Redbox::Product.find(products_params.keys).each.with_index do |product|
          product.update_attributes products_params[product.id.to_s]
        end
        category_id = update_multiple_params[:category][:id]
        page = update_multiple_params[:page].to_i + 1
        render nothing: true
        # redirect_to admin_redbox_products_path(category: {id: category_id}, page: page)
      end

      private

      def products_params
        params[:products].permit!
      end

      def update_multiple_params
        params[:update_multiple]
      end

      def form_params
        if params[:category]
          params[:category].permit(:id)
        else
          {id: '046'}
        end
      end

      def get_data
        @units = Redbox::Unit.all
        @producers = Redbox::Producer.all
        @colors = Redbox::Color.order('name ASC')
        @ocassions = Redbox::Ocassion.all
        @styles = Redbox::Style.all
        @genders = Redbox::Gender.all
        @sizes = Redbox::Size.all
        @categories = Rails.cache.fetch(:get_categories) { get_categories }
      end

      private
      def get_categories
        Redbox::Category.all_names(Redbox::Category.find('046'))
      end
    end
  end
end