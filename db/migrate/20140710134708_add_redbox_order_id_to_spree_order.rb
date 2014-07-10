class AddRedboxOrderIdToSpreeOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :redbox_order_id, :integer
  end
end
