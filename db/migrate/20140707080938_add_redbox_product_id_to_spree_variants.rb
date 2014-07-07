class AddRedboxProductIdToSpreeVariants < ActiveRecord::Migration
  def change
    add_column :spree_variants, :redbox_product_id, :integer
  end
end
